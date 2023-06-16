//
//  projectMembersTableViewCell.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 16.06.2023.
//

import UIKit

class projectMembersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var memberNameLabel: UILabel!
    
    @IBOutlet weak var tokenLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
