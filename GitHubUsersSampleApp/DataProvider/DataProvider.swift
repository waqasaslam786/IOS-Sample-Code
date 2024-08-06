//
//  DataProvider.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 07/03/2021.
//

import Foundation
import CoreData

class UserDataProvider {
    
    var persistanceContainer = CoreDataStack.shared.persistentContainer
    
    var viewContext: NSManagedObjectContext {
        return persistanceContainer.viewContext
    }
    
    init() {
    }
    
    func fetchUserList(fetchNextRecords: Bool = false, callback: @escaping (Result<Bool, AppError>) -> Void) {
        
        var params: Parameters = ["since":"0"]
        if fetchNextRecords {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            request.fetchLimit = 1

            let predicate = NSPredicate(format: "id == max(id)")
            request.predicate = predicate

            var maxValue: Int32? = nil
            do {
                let result = try self.viewContext.fetch(request).first
                maxValue = (result as AnyObject).id
            } catch {
                print("Unresolved error in retrieving max personId value \(error)")
            }
            
            params = maxValue != nil ? ["since":"\(maxValue ?? 0)"] : ["since":"0"]
        }
        
        
        UserService.shared.fetchUsers(params: params) { result in
            switch result {
            case .success(let data):
                let taskContext = self.persistanceContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil

                let dataSynced = self.syncUsersData(with: data, taskContext: taskContext)
                callback(.success(dataSynced))
                break
            case .failure(let error):
                switch error {
                case .CanNotProcessData:
                    print("Cannot process the data received from server.")
                case .NoDataAvailable:
                    print("No data is available")
                case .ServerError:
                    print("Server not responding at the moment. Please try later.")
                case .other:
                    print(error.localizedDescription)
                    
                }
                callback(.failure(error))
            }
        }
    }
    
    fileprivate func syncUsersData(with userRMs: [UserResponseModel], taskContext: NSManagedObjectContext) -> Bool {
        var successfull = false
        taskContext.performAndWait {
//            let matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
//            let userIds = userRMs.map { $0.id }.compactMap { $0 }
//            matchingEpisodeRequest.predicate = NSPredicate(format: "userIds in %@", argumentArray: [userIds])
//
//            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
//            batchDeleteRequest.resultType = .resultTypeObjectIDs
//
//            // Execute the request to de batch delete and merge the changes to viewContext, which triggers the UI update
//            do {
//                let batchDeleteResult = try taskContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
//
//                if let deletedObjectIDs = batchDeleteResult?.result as? [NSManagedObjectID] {
//                    NSManagedObjectContext.mergeChanges(fromRemoteContextSave: [NSDeletedObjectsKey: deletedObjectIDs],
//                                                        into: [self.persistanceContainer.viewContext])
//                }
//            } catch {
//                print("Error: \(error)\nCould not batch delete existing records.")
//                return
//            }
//            
            // Create new records.
            for userRM in userRMs{
                guard let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: taskContext) as? User else {
                    print("Error: Failed to create a new Film object!")
                    return
                }
                do {
                    try user.update(with: userRM)
                } catch {
                    print("Error: \(error)\nThe quake object will be deleted.")
                    taskContext.delete(user)
                }
            }
            // Save all the changes just made and reset the taskContext to free the cache.
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            successfull = true
        }
        return successfull
    }
    
    func getUsers() -> [User]? {
        let usersRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let fetchedData = try self.viewContext.fetch(usersRequest)
            return fetchedData as? [User]
        } catch {
            print("Error: \(error)\nCould not load existing records.")
            return nil
        }
    }
    
    func fetchUser(userName: String, callback: @escaping (Result<User, AppError>) -> Void) {
        
        let params: Parameters = [:]
        
        UserService.shared.fetchUserDetail(userName: userName, params: params) { result in
            switch result {
            case .success(let data):
                let taskContext = self.persistanceContainer.newBackgroundContext()
                taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                taskContext.undoManager = nil

                if let dataFetched = self.syncUserData(with: data, taskContext: taskContext) {
                    callback(.success(dataFetched))
                }else{
                    callback(.failure(.NoDataAvailable))
                }
                break
            case .failure(let error):
                switch error {
                case .CanNotProcessData:
                    print("Cannot process the data received from server.")
                case .NoDataAvailable:
                    print("No data is available")
                case .ServerError:
                    print("Server not responding at the moment. Please try later.")
                case .other:
                    print(error.localizedDescription)
                    
                }
                callback(.failure(error))
            }
        }
    }
    
    fileprivate func syncUserData(with userRM: UserResponseModel, taskContext: NSManagedObjectContext) -> User? {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        request.fetchLimit = 1

        let predicate = NSPredicate(format: "id == %i", userRM.id!)
        request.predicate = predicate

        do {
            let fetchedData = try self.viewContext.fetch(request).first as! User
            try fetchedData.update(with: userRM)
            if taskContext.hasChanges {
                do {
                    try taskContext.save()
                } catch {
                    print("Error: \(error)\nCould not save Core Data context.")
                }
                taskContext.reset() // Reset the context to clean up the cache and low the memory footprint.
            }
            return fetchedData
        } catch {
            print("Unresolved error in retrieving max personId value \(error)")
        }
        return nil
    }
}
