//
//  newProjectViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 15.06.2023.
//

import UIKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

protocol newProjectViewControllerDelegate: AnyObject{
    func didFinishNewProjectViewController()
}

class newProjectViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var projectNameField: UITextField!
    
    @IBOutlet weak var userBalanceLabel: UILabel!
    
    @IBOutlet weak var gasFeeLabel: UILabel!
    
    @IBOutlet weak var statusTextField: UITextView!
    
    weak var delegate: newProjectViewControllerDelegate?
    
    func loadBalance(){
        
        Task {
            do {
                
                
                let formattedValue = await getBalanceStringFormatted(inputAddress: EthereumAddress(myAddressStringGlobal)!, urlString: web3GlobalAddress)
                
                userBalanceLabel.text = "your balance: \(formattedValue)"
                
                
                
            } catch {
                print("error: \(error)")
            }
        }
        
    }
    
    func createTransaction() async -> CodableTransaction{
        let projectName = projectNameField.text! as String
        
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

            let parameters: [AnyObject] = [projectName as AnyObject]
            
            let writeTx = contract?.createWriteOperation("createProject", parameters: parameters, extraData: Data())
            
            var transaction = try writeTx!.transaction
            
            //transaction.gasLimit = try await web3.eth.estimateGas(for: transaction)
            transaction.gasLimit = BigUInt(6721975) //future work implement better algorithm
            
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
    
    func createNewProject() async {
        
        do{
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            let transaction = try await createTransaction()
            let result = try await web3.eth.send(transaction)
            
            statusTextField.text = "Request sent! Your new project will appear on the list once the transaction gets approved. You can safely leave this page by swiping down"
            
            createButton.isEnabled = false
            

        print("create new project call: \(result)")
    } catch {
        print("error in createNewProject: \(error)")
    }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        statusTextField.text = ""
        
        projectNameField.delegate = self
        //projectNameField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        loadBalance()
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
    
    @IBAction func createButtonPress(_ sender: Any) {
        createButton.isEnabled = false
        statusTextField.text = "creating project ..."
        Task {
            await createNewProject()
            
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed{
            delegate?.didFinishNewProjectViewController()
        }
        
    }
    

    

}
