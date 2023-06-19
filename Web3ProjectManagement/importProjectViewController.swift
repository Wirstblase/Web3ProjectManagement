//
//  importProjectViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 17.06.2023.
//

import UIKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

class importProjectViewController: UIViewController {
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var gasFeeLabel: UILabel!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet weak var projectAddressTextField: UITextField!
    
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var importButton: UIButton!
    
    func loadNameForProject(projectAddress: EthereumAddress) async -> String{
        do {
            
            let response = await getDataFromSmartContract(contractAddress: projectAddress, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "projectName", parameters: [])
            
            print(response)
            
            if let item = response["0"] {
                //print("name for project with address \(projectAddress.address): \(item)")
                //tableItemCount = item as! BigUInt
                return item as! String
            } else {
                print("Item with key '0' not found")
            }
            
        } catch {
            print("error in main task function loadTableData: \(error)")
        }
        return "error"
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

            let parameters: [AnyObject] = [EthereumAddress(projectAddressTextField.text!) as AnyObject]
            
            let writeTx = contract?.createWriteOperation("addProjectAddress", parameters: parameters, extraData: Data())
            
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
    
    func importProject() async{
        do{
            
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            let transaction = try await createTransaction()
            let result = try await web3.eth.send(transaction)
            
            
            
            importButton.isEnabled = false
            
        } catch {
            print("error in importProject \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkButton.tintColor = colourThemeLight2
        importButton.tintColor = colourThemeLight2
        
        statusTextView.text = ""
        
        loadBalance()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func estimateButtonPress(_ sender: Any) {
        if(projectAddressTextField.text == ""){
            statusTextView.text = "project address cannot be empty"
        } else {
            gasFeeLabel.text = "estimated gas fee: estimating..."
            Task{
                let transaction = await createTransaction()
                
                let gasLimit = transaction.gasLimit //bigUInt
                
                var formattedValue = formatEthereumBalance(gasLimit)
                
                gasFeeLabel.text = "estimated gas fee: \(formattedValue) ETH"
            }
        }
    }
    
    @IBAction func checkButtonPress(_ sender: Any) {
        if(projectAddressTextField.text == ""){
            statusTextView.text = "project address cannot be empty"
        } else {
            Task{
                let projName = await loadNameForProject(projectAddress: EthereumAddress(projectAddressTextField.text!)!)
                statusTextView.text = "the selected address leads to a project called: \(projName)"
            }
        }
        
    }
    
    @IBAction func importButtonPress(_ sender: Any) {
        if(projectAddressTextField.text == ""){
            statusTextView.text = "project address cannot be empty"
        } else {
            statusTextView.text = "importing.."
            Task{
                importButton.isEnabled = false
                checkButton.isEnabled = false
                projectAddressTextField.isEnabled = false
                
                await importProject()
                statusTextView.text = "Request sent! The project will appear on the list once the transaction gets approved. You can safely leave this page by swiping down"
                importButton.setTitle("done", for: .normal)
            }
            
        }
    }

}
