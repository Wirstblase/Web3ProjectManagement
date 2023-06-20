//
//  transferTokensViewController.swift
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

class transferTokensViewController: UIViewController {

    @IBOutlet weak var userBgView: UIView!
    
    @IBOutlet weak var userTokenLabel: UILabel!
    
    @IBOutlet weak var tokenTextField: UITextField!
    
    @IBOutlet weak var plusButton: UIButton!
    
    @IBOutlet weak var minusButton: UIButton!
    
    @IBOutlet weak var selectedUserLabel: UILabel!
    
    @IBOutlet weak var selectedImageView: UIImageView!
    
    @IBOutlet weak var ethBalanceLabel: UILabel!
    
    @IBOutlet weak var gasFeeLabel: UILabel!
    
    @IBOutlet weak var transferButton: UIButton!
    
    @IBOutlet weak var swipeDownLabel: UILabel!
    
    var tokenCount = BigUInt(0)
    
    var sure: Bool = false
    
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
                
                ethBalanceLabel.text = "your balance: \(formattedValue)"
                
                
                
            } catch {
                print("error: \(error)")
            }
        }
        
    }
    
    func createTransaction() async -> CodableTransaction{
        
        print("createTransaction called")

        do {
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            let contractAddress = EthereumAddress(selectedContractStringGlobal)
            let path = Bundle.main.path(forResource: "projectContractABI", ofType: "txt")
            let abiString = try String(contentsOfFile: path!)
            let contract = web3.contract(abiString, at: contractAddress)

            let privateKeyData = Data(hex: myPrivateKeyStringGlobal)
            let keystore = try EthereumKeystoreV3(privateKey: privateKeyData, password: "web3swift")
            let keystoreManager = KeystoreManager([keystore!])
            web3.addKeystoreManager(keystoreManager)

            let parameters: [AnyObject] = [EthereumAddress(selectedUserStringGlobal) as AnyObject, tokenCount as AnyObject]
            
            let writeTx = contract?.createWriteOperation("transfer", parameters: parameters, extraData: Data())
            
            var transaction = try writeTx!.transaction
            
            /*var gasLimit: BigUInt = try await web3.eth.estimateGas(for: transaction)
            print("estimated gas limit: \(gasLimit * 50)")
            if(gasLimit * 50 > BigUInt(6721975)){
                gasLimit = BigUInt(5000000)
            } else {
                gasLimit = gasLimit * BigUInt(50)
            }*/
            
            transaction.gasLimit = BigUInt(6721975) //future work: implement safe algorithm for this
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
    
    func sendTokens() async{
        do{
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            let transaction = try await createTransaction()
            let result = try await web3.eth.send(transaction)
            
            transferButton.isEnabled = false
            plusButton.isEnabled = false
            minusButton.isEnabled = false
            

        print("sendTokens call: \(result)")
    } catch {
        print("error in sendTokens: \(error)")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userBgView.layer.cornerRadius = 20

        transferButton.tintColor = colourThemeLight2
        plusButton.tintColor = colourThemeLight2
        minusButton.tintColor = colourThemeLight2
        
        loadBalance()
        
        Task {
            userTokenLabel.text = "you own: \(await getTokenCountForAddress(inputAddress: EthereumAddress(myAddressStringGlobal)!)) tokens"
            
            selectedUserLabel.text = await getUserNameForAddress(inputAddress: EthereumAddress(selectedUserStringGlobal)!)
            let selectedUserImage = await getProfilePictureForAddress(inputAddress: EthereumAddress(selectedUserStringGlobal)!)
            
            if let imageUrl = URL(string: selectedUserImage) {
                DispatchQueue.global().async {
                    if let imageData = try? Data(contentsOf: imageUrl) {
                        DispatchQueue.main.async {
                            if let image = UIImage(data: imageData) {
                                self.selectedImageView.image = image
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @IBAction func estimateButtonPress(_ sender: Any) {
        gasFeeLabel.text = "estimated gas fee: estimating..."
        
        Task{
            let transaction = await createTransaction()
            
            let gasLimit = transaction.gasLimit //bigUInt
            
            var formattedValue = formatEthereumBalance(gasLimit)
            
            gasFeeLabel.text = "estimated gas fee: \(formattedValue) ETH"
        }
    }
    
    @IBAction func plusButtonPress(_ sender: Any) {
        tokenCount = BigUInt(Int(tokenTextField.text!)!) + BigUInt(1)
        tokenTextField.text = tokenCount.description
    }
    
    @IBAction func minusButtonPress(_ sender: Any) {
        tokenCount = BigUInt(Int(tokenTextField.text!)!) - BigUInt(1)
        tokenTextField.text = tokenCount.description
    }
    
    @IBAction func transferButtonPress(_ sender: Any) {
        tokenCount = BigUInt(Int(tokenTextField.text!)!)
        
        Task{
            
            let userTokenCount = await getTokenCountForAddress(inputAddress: EthereumAddress(myAddressStringGlobal)!)
            
            print("userTokenCount: \(userTokenCount), tokenCount: \(tokenCount), senderAddress: \(myAddressStringGlobal), recipientAddress: \(selectedUserStringGlobal)")
            
            if(tokenCount >= userTokenCount)
                {
                
                    ethBalanceLabel.text = "cannot send more than \((userTokenCount-BigUInt(1)).description) tokens"
                    
            }  else {
                
                if(sure == true){
                    
                    transferButton.tintColor = colourThemeLight2
                    transferButton.setTitle("sending...", for: .normal)
                    
                    await sendTokens()
                    
                    swipeDownLabel.text = "swipe down to exit"
                    ethBalanceLabel.text = "tokens sent!"
                    gasFeeLabel.text = "you can safely exit this page"
                    transferButton.setTitle("sent", for: .normal)
                    tokenTextField.isEnabled = false
                    
                    userTokenLabel.text = "you now own: \(await getTokenCountForAddress(inputAddress: EthereumAddress(myAddressStringGlobal)!)) tokens"
                    
                } else {
                    
                    transferButton.setTitle("are you sure?", for: .normal)
                    transferButton.tintColor = colourVoteRed
                    
                    sure = true
                    
                }
            }
        }
    }

}
