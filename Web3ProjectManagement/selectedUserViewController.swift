//
//  selectedUserViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 18.06.2023.
//
import UIKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

class selectedUserViewController: UIViewController {
    
    @IBOutlet weak var transferButton: UIButton!
    
    @IBOutlet weak var userBgView: UIView!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var yourTokenLabel: UILabel!
    
    @IBOutlet weak var selectedTokenLabel: UILabel!
    
    @IBOutlet weak var selectedAddressTextView: UITextView!
    
    @IBOutlet weak var selectedUserAddressTextView: UITextView!
    
    var selectedUserName = ""
    var selectedUserImage = ""
    var selectedUserTokens = BigUInt(0)
    var yourTokens = BigUInt(0)
    
    
    func getTokenCountForAddress(inputAddress: EthereumAddress) async -> BigUInt{
        let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "balances", parameters: [inputAddress])
        
        print("getUserCount: \(response)")
        
        if let item = response["0"] {
            
            return item as! BigUInt
            
        } else {
            print("getUserCount: Item with key '0' not found")
            return BigUInt(0)
        }
        
    }
    
    func getProfilePictureForAddress(inputAddress: EthereumAddress) async -> String {
        
        let response = await getDataFromSmartContract(contractAddress: EthereumAddress(mainContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "userManagerABI", contractFunctionToCallString: "getProfilePicture", parameters: [inputAddress])
        
        
        
        if let item = response["0"] {
            
            return item as! String
            
        } else {
            print("getProfilePicture: Item with key '0' not found")
            return""
        }
        
    }
    
    
    
    func getUserNameForAddress(inputAddress: EthereumAddress) async -> String {
        let response = await getDataFromSmartContract(contractAddress: EthereumAddress(mainContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "userManagerABI", contractFunctionToCallString: "getUsername", parameters: [inputAddress])
        
        print("getUsername: \(response)")
        
        if let item = response["0"] {
            
            return item as! String
            
        } else {
            print("getUsername: Item with key '0' not found")
            return "error"
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userBgView.layer.cornerRadius = 30
        
        Task{
            selectedUserTokens = await getTokenCountForAddress(inputAddress: EthereumAddress(selectedUserStringGlobal)!)
            
            yourTokens = await getTokenCountForAddress(inputAddress: EthereumAddress(myAddressStringGlobal)!)
            
            selectedUserName = await getUserNameForAddress(inputAddress: EthereumAddress(selectedUserStringGlobal)!)
            
            selectedUserImage = await getProfilePictureForAddress(inputAddress: EthereumAddress(selectedUserStringGlobal)!)
            
            selectedUserAddressTextView.text = "\(selectedUserName)'s address: \(selectedUserStringGlobal)"
            
            userNameLabel.text = selectedUserName
            
            if let imageUrl = URL(string: selectedUserImage) {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async {
                            if let image = UIImage(data: imageData) {
                                self.userImageView.image = image
                            }
                        }
                    }
                }
            }
            
            yourTokenLabel.text = "\(selectedUserName) owns \(selectedUserTokens.description) of \(selectedProjectNameGlobal)"
            
            selectedTokenLabel.text = "while you own \(yourTokens.description) of \(selectedProjectNameGlobal)"
            
            transferButton.tintColor = colourThemeLight2
        }
        
    }

}
