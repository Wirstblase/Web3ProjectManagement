//
//  IntroViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 13.06.2023.
//

import UIKit
import web3swift

class IntroViewController: UIViewController {
    
    @IBOutlet weak var mainContractAddressTextField: UITextField!
    
    @IBOutlet weak var rpcServerTextField: UITextField!
    
    @IBOutlet weak var publicAddressTextField: UITextField!
    
    @IBOutlet weak var privateKeyTextField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        continueButton.tintColor = colourThemeLight2
        

        myAddressStringGlobal = publicAddressTextField.text!
        
        myPrivateKeyStringGlobal = privateKeyTextField.text!
        
        mainContractStringGlobal = mainContractAddressTextField.text!
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
