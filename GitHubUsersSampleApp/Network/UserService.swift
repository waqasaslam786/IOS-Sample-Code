//
//  UserService.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 07/03/2021.
//

import Foundation

class UserService: NSObject, Requestable {
    
    class var shared : UserService {
        struct Static {
            static let instance : UserService = UserService()
        }
        return Static.instance
    }
    
//    fileprivate let laundryUrl = "https://api.pennlabs.org/laundry/rooms"
//
//    public var movies: [User]?
//
//    // Prepare the service
    
//    func prepare(callback: @escaping([Movie]?,Bool) -> Void) {
//
//        let filePath = Bundle.main.url(forResource: "movie", withExtension: "json")
//
//        let originalContents = try? Data(contentsOf: filePath!)
//
//        let movies = try? JSONDecoder().decode([Movie].self, from: originalContents!)
//
//        callback(movies!, false)
//    }
    
    func fetchUsers(params: Parameters, callback: @escaping (Result<[UserResponseModel], AppError>) -> Void) {
        
        print("UserService - fetchUsers")
        getRequest(path: APIEndpoint.users, params: params) { (result) in
            switch result {
                case .success(let data):
                    print("UserService - fetchUsers - success")
                    do {
                        let mappedModel = try JSONDecoder().decode([UserResponseModel].self, from: data as! Data)
                        callback(.success(mappedModel))
                    }catch {
                        callback(.failure(error as! AppError))
                    }
                case .failure(let error):
                    print("UserService - fetchUsers - failure - \(error.localizedDescription)")
                    callback(.failure(error))
            }
        }
    }
    
    func fetchUserDetail(userName: String, params: Parameters, callback: @escaping (Result<UserResponseModel, AppError>) -> Void) {
        
        print("UserService - fetchUsers")
        getRequest(path: "\(APIEndpoint.users)/\(userName)", params: params) { (result) in
            switch result {
                case .success(let data):
                    print("UserService - fetchUsers - success")
                    do {
                        let mappedModel = try JSONDecoder().decode(UserResponseModel.self, from: data as! Data)
                        callback(.success(mappedModel))
                    }catch {
                        callback(.failure(.CanNotProcessData))
                    }
                case .failure(let error):
                    print("UserService - fetchUsers - failure - \(error.localizedDescription)")
                    callback(.failure(error))
            }
        }
    }
}
