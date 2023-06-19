//
//  editProfileViewController.swift
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

class editProfileViewController: UIViewController {
    
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBOutlet weak var profilePictureTextField: UITextField!
    
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var gasFeeLabel: UILabel!
    
    func getProfilePictureForAddress(inputAddress: EthereumAddress) async -> String {
        
        let response = await getDataFromSmartContract(contractAddress: EthereumAddress(mainContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "userManagerABI", contractFunctionToCallString: "getProfilePicture", parameters: [inputAddress])
        
        
        
        if let item = response["0"] {
            
            return item as! String
            print("getProfilePicture: \(item)")
            
        } else {
            print("getProfilePicture: Item with key '0' not found")
            return""
        }
        
        
    }
    
    func loadBalance(){
        
        Task {
            do {
                
                
                let formattedValue = await getBalanceStringFormatted(inputAddress: EthereumAddress(myAddressStringGlobal)!, urlString: web3GlobalAddress)
                
                balanceLabel.text = "your balance: \(formattedValue)"
                
                
                
            } catch {
                print("error: \(error)")
            }
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
    
    func createTransaction() async -> CodableTransaction{
        
        print("createTransaction called")

        do {
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            let contractAddress = EthereumAddress(mainContractStringGlobal)
            let path = Bundle.main.path(forResource: "userManagerABI", ofType: "txt")
            let abiString = try String(contentsOfFile: path!)
            let contract = web3.contract(abiString, at: contractAddress)

            let privateKeyData = Data(hex: myPrivateKeyStringGlobal)
            let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: "web3swift")
            let keystoreManager = KeystoreManager([keystore!])
            web3.addKeystoreManager(keystoreManager)

            let parameters: [AnyObject] = [usernameTextField.text as AnyObject, profilePictureTextField.text as AnyObject]
            
            let writeTx = contract?.createWriteOperation("setUser", parameters: parameters, extraData: Data())
            
            var transaction = try writeTx!.transaction
            
            var gasLimit: BigUInt = try await web3.eth.estimateGas(for: transaction)
            print("estimated gas limit: \(gasLimit * 50)")
            if(gasLimit * 50 > BigUInt(6721975)){
                gasLimit = BigUInt(5000000)
            } else {
                gasLimit = gasLimit * BigUInt(50)
            }
            
            transaction.gasLimit = gasLimit
            transaction.gasPrice = try await web3.eth.gasPrice()
            transaction.from = EthereumAddress(myAddressStringGlobal)
            transaction.nonce = try await web3.eth.getTransactionCount(for: EthereumAddress(myAddressStringGlobal)!)
            
            
            print("gas limit: \(try await web3.eth.estimateGas(for: transaction))")
            print("gas price: \(try await web3.eth.gasPrice())")

            //print("createTransaction: \(transaction)")
            return transaction
        } catch {
            print("error in createTransaction: \(error)")
        }
        return "error" as! CodableTransaction//error handling handled in caller
    }
    
    func updateUserInfo() async{
        do{
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            let transaction = try await createTransaction()
            let result = try await web3.eth.send(transaction)
            
            statusTextView.text = "Request sent! Your new username / profile picture will update once the transaction gets approved, you can safely go back"
            
            usernameTextField.isEnabled = false
            profilePictureTextField.isEnabled = false
            
            updateButton.isEnabled = false
            

        print("create new project call: \(result)")
    } catch {
        print("error in createNewProject: \(error)")
    }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBalance()
        
        updateButton.tintColor = colourThemeLight2
        
        Task{
            usernameTextField.text = await getUserNameForAddress(inputAddress: EthereumAddress(myAddressStringGlobal)!)
            profilePictureTextField.text = await getProfilePictureForAddress(inputAddress: EthereumAddress(myAddressStringGlobal)!)
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func estimateButtonPress(_ sender: Any) {
        Task{
            gasFeeLabel.text = "estimated gas fee: estimating..."
            
            let transaction = await createTransaction()
            
            let gasLimit = transaction.gasLimit //bigUInt
            
            var formattedValue = formatEthereumBalance(gasLimit)
            
            gasFeeLabel.text = "estimated gas fee: \(formattedValue) ETH"
        }
    }
    
    @IBAction func updateButtonPress(_ sender: Any) {
        
        updateButton.isEnabled = false
        statusTextView.text = "updating..."
        Task{
            await updateUserInfo()
            loadBalance()
        }
        
    }
    

}
