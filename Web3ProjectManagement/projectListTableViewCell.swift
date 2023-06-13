//
//  projectListTableViewCell.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 13.06.2023.
//

import UIKit

class projectListTableViewCell: UITableViewCell {

    @IBOutlet weak var viewBg: UIView!
    
    @IBOutlet weak var projectTitleLabel: UILabel!
    
    @IBOutlet weak var tokensLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
