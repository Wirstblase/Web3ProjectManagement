//
//  proposalsTableViewCell.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 14.06.2023.
//

import UIKit

class proposalsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var fgView: UIView!
    
    @IBOutlet weak var proposalTitleLabel: UILabel!
    
    @IBOutlet weak var proposalStatusLabel: UILabel!
    
    @IBOutlet weak var proposalIssuerNameLabel: UILabel!
    
    @IBOutlet weak var proposalIssuerAddressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            if selected {
                UIView.animate(withDuration: 0.1, animations: {
                    self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { (_) in
                    UIView.animate(withDuration: 0.1, animations: {
                        self.transform = CGAffineTransform.identity
                    })
                }
            }
        }

}
