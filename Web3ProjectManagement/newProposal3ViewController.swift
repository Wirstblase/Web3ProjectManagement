//
//  newProposal3ViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 16.06.2023.
//

import UIKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

protocol newProposal3ViewControllerDelegate: AnyObject{
    func didFinishNewProposal3ViewController()
}

class newProposal3ViewController: UIViewController {
    @IBOutlet weak var estimateButton: UIButton!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var proposalTitleLabel: UILabel!
    
    @IBOutlet weak var proposalContentTextView: UITextView!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var gasFeeLabel: UILabel!
    
    @IBOutlet weak var statusTextView: UITextView!
    
    weak var delegate: newProposal3ViewControllerDelegate?
    
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

            let parameters: [AnyObject] = [newProposalTitleGlobal as AnyObject, newProposalContentGlobal as AnyObject]
            
            let writeTx = contract?.createWriteOperation("propose", parameters: parameters, extraData: Data())
            
            var transaction = try writeTx!.transaction
            
            //print("before estimate gas")
            
            //transaction.gasLimit = try await web3.eth.estimateGas(for: transaction)
            var gasLimit: BigUInt = try await web3.eth.estimateGas(for: transaction)
            print("estimated gas limit: \(gasLimit * 50)")
            if(gasLimit * 50 > BigUInt(6721975)){
                gasLimit = BigUInt(5000000)
            } else {
                gasLimit = gasLimit * BigUInt(50)
            }
            
            var gasPrice: BigUInt = try await web3.eth.gasPrice()
            
            let gasLimit2 = BigUInt(gasLimit.description)
            print(gasLimit2)
            
            transaction.gasPrice = gasPrice
            transaction.gasLimit = gasLimit2!//BigUInt(5000000)//gasLimit
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
    
    func createNewProposal() async{
        
        do{
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            let transaction = try await createTransaction()
            let result = try await web3.eth.send(transaction)
            
            statusTextView.text = "Request sent! Your new project will appear on the list once the transaction gets approved. You can safely leave this page by swiping down"
            
            sendButton.isEnabled = false
            

        print("create new project call: \(result)")
    } catch {
        print("error in createNewProject: \(error)")
    }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBalance()
        
        proposalTitleLabel.text = newProposalTitleGlobal
        
        proposalContentTextView.text = newProposalContentGlobal
        
        statusTextView.text = ""
        
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
    
    @IBAction func sendButtonPress(_ sender: Any) {
        
        sendButton.isEnabled = false
        statusTextView.text = "sending..."
        Task{
            await createNewProposal()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("delegate tag, proposal view 3 will disappear")
        
        if isMovingFromParent || isBeingDismissed{
            delegate?.didFinishNewProposal3ViewController()
        }
        
    }
    
    /*override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent || isBeingDismissed{
            delegate?.didFinishNewProposal3ViewController()
        }
    }*/
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
