//
//  ViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 12.06.2023.
//

import UIKit

var web3GlobalAddress = "HTTP://127.0.0.1:7545"
var myAddressStringGlobal = ""
var myPrivateKeyStringGlobal = ""
var mainContractStringGlobal = ""
var selectedContractStringGlobal = ""

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        performSegue(withIdentifier: "showLoginPage", sender: self)
    }


}

