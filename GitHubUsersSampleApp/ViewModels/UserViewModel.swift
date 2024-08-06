//
//  UserViewModel.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 06/03/2021.
//

import Foundation
import UIKit

protocol UserViewModelProtocol {
    
    var userDidChanges: ((Bool, Bool) -> Void)? { get set }
    var userFetched: ((User) -> Void)? { get set }
    
    func fetchUserList(nextBatch: Bool)
    func fetchUserDetail(userName: String)
}
class UserViewModel: UserViewModelProtocol {

    //MARK: - Internal Properties
    
    var userDidChanges: ((Bool, Bool) -> Void)?
    var userFetched: ((User) -> Void)?
    
    private var users: [User]? {
        didSet {
            self.userDidChanges!(true, false)
        }
    }
    
    private var dataProvider: UserDataProvider = UserDataProvider()
    
    func fetchUserList(nextBatch: Bool) {

        if nextBatch {
            self.dataProvider.fetchUserList(fetchNextRecords: nextBatch) { (result) in
                switch result {
                case .success(let fetchNStoreDone):
                    if fetchNStoreDone {
                        self.users = self.dataProvider.getUsers()
                    }
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
        }else {
            if let fetchedData = self.dataProvider.getUsers() {
                if fetchedData.count == 0 {
                    self.dataProvider.fetchUserList { (result) in
                        switch result {
                        case .success(let fetchNStoreDone):
                            if fetchNStoreDone {
                                self.users = self.dataProvider.getUsers()
                            }
                        case.failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }else{
                    self.users = fetchedData
                }
            }else {
                self.dataProvider.fetchUserList(fetchNextRecords: nextBatch) { (result) in
                    switch result {
                    case .success(let fetchNStoreDone):
                        if fetchNStoreDone {
                            self.users = self.dataProvider.getUsers()
                        }
                    case.failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    

    func getUsers(_ searchQuery: String? = nil) -> [User] {

        if let query = searchQuery {
            return self.users?.filter({
                if let loginName = $0.login {
                    return loginName.contains(query)
                }else{
                    return false
                }
            }) ?? []
//                                        ($0.login?.contains(query) ?? $0.login?.isEmpty)}) ?? []
        }else{
            return self.users ?? []
        }

    }
    
    func fetchUserDetail(userName: String) {
        self.dataProvider.fetchUser(userName: userName) { (result) in
            switch result {
            case .success(let fetchUser):
                self.userFetched!(fetchUser)
            case.failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
