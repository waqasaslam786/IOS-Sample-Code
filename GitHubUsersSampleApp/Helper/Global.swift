//
//  Global.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 07/03/2021.
//

import Foundation

class Global {
    class var shared : Global {
        struct Static {
            static let instance : Global = Global()
        }
        return Static.instance
    }
    
    #if DEBUG
    let environment: EnvironmentProtocol = AppURL.development
    #else
    let environment: EnvironmentProtocol = AppURL.production
    #endif

    
}
