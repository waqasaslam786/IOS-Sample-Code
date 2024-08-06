//
//  UserDetailViewController.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 07/03/2021.
//

import UIKit

class UserDetailViewController: UIViewController {
    
    //MARK: Internal Properties
    var userDetail: User!
    
    let viewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(userDetail.description)
    }
    
    
    
}
