//
//  addUserViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 18.06.2023.
//

import UIKit

class addUserViewController: UIViewController {
    
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet weak var cameraButton: UIButton!
    
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var addressTextField: UITextField!
    
    @IBOutlet weak var projectAddressTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectAddressTextView.text = "\(selectedContractStringGlobal)"
        
        continueButton.tintColor = colourThemeLight2
        cameraButton.tintColor = colourThemeLight2

    }
    
    @IBAction func continueButtonPress(_ sender: Any) {
        
        if(addressTextField.text == ""){
            statusTextView.text = "The user address cannot be empty"
        } else if(addressTextField.text?.count == 42){
            selectedUserStringGlobal = addressTextField.text!
            performSegue(withIdentifier: "continueAdding", sender: self)
        } else {
            statusTextView.text = "Please input a valid Ethereum address"
        }
        
    }

}
