//
//  UserTableViewCell.swift
//  GitHubUsersSampleApp
//
//  Created by Khurram Bilal Nawaz on 07/03/2021.
//

import Foundation
import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var picture: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    var userItem: User? {
        
        didSet {
            
            if let user = userItem {
                
                self.titleLabel.text = user.login ?? ""
                
                self.picture.setImage(withImageURL: user.avatarURL ?? "", placeholderImage: nil, size: .original)
                
                self.picture.contentMode = .scaleToFill
            }
        }
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
