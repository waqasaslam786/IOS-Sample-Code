//
//  User.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 06/03/2021.
//

import Foundation
import CoreData

enum UserViewModelType {
   case note
   case normal
   case inverted
   case siteAdmin
   
}

extension User {
 
    var modelType: UserViewModelType {
        if self.siteAdmin {
            return . siteAdmin
        }else if !self.note!.isEmpty {
            return .note
        }else if true {
            return .inverted
        }else {
            return .normal
        }
    }
    
    func update(with userRM: UserResponseModel) throws {
        login = userRM.login
        id = userRM.id ?? 0
        nodeID = userRM.nodeID
        avatarURL = userRM.avatarURL
        gravatarID = userRM.gravatarID
        url = userRM.url
        htmlURL = userRM.htmlURL
        followingURL = userRM.followingURL
        followersURL = userRM.followersURL
        gistsURL = userRM.gistsURL
        starredURL = userRM.starredURL
        subscriptionURL = userRM.subscriptionURL
        organizationURL = userRM.organizationURL
        reposURL = userRM.reposURL
        eventsURL = userRM.eventsURL
        receivedEventsURL = userRM.receivedEventsURL
        type = userRM.type
        siteAdmin = userRM.siteAdmin ?? false
        name = userRM.name
        company = userRM.company
        blog = userRM.blog
        location = userRM.location
        email = userRM.email
        hireable = userRM.hireable ?? false
        bio = userRM.bio
        twitterUsername = userRM.twitterUsername
        piblicRepos = userRM.piblicRepos ?? 0
        publicGists = userRM.publicGists ?? 0
        followers = userRM.followers ?? 0
        following = userRM.following ?? 0
        createdAt = userRM.createdAt
        updatedAt = userRM.updatedAt
    }

}
