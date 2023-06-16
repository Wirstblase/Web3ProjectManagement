//
//  proposalViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 15.06.2023.
//

import UIKit
import WebKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

class proposalViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var textViewSmall: UITextView!
    
    var successfullySubmitted = false
    
    var selectedProposal: Proposal?
    
    var selectedProposalIndex: BigUInt?
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    @IBOutlet weak var costLabel: UILabel!
    
    @IBOutlet weak var webViewBig: WKWebView!
    
    @IBOutlet weak var webViewSmall: WKWebView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var yesButton: UIButton!
    
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    func getContent() async -> String{
        
        //MARK: this will be deprecated and replaced with getProposalContent([index])
        do{
            let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "proposals", parameters: [selectedProposalIndex!])
            
            return response["1"] as! String
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

            //let parameters: [AnyObject] = [selectedProposalIndex! as AnyObject,voteValue as AnyObject]
            
            let writeTx = contract?.createWriteOperation("vote", parameters: [selectedProposalIndex,voteValue], extraData: Data())
            
            var transaction = try writeTx!.transaction
            
            transaction.gasLimit = try await web3.eth.estimateGas(for: transaction)
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
    
    func submitVote(voteValue: Bool) async{
        
        do{
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            let transaction = try await createTransaction()
            let result = try await web3.eth.send(transaction)
            
            submitButton.isEnabled = false
            balanceLabel.text = "vote sent successfully!"

        print("submitVote result: \(result)")
    } catch {
        print("error in submitVote:: \(error)")
    }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBalance()
        
        noButton.tintColor = colourVoteRed
        yesButton.tintColor = colourVoteGreen
        
        submitButton.isEnabled = false
        
        self.navigationItem.title = selectedProposal?.description
        
        Task{
            
            let content = await getContent()
            
            if(content.hasPrefix("<!Doctype html>")){
                
                if(selectedProposal?.executed == true){
                    
                    webViewBig.isUserInteractionEnabled = true
                    webViewBig.isHidden = false
                    
                    
                    webViewBig?.loadHTMLString(content, baseURL: nil)
                    
                    
                } else {
                    
                    
                    webViewSmall?.loadHTMLString(content , baseURL: nil)
                    
                    
                }} else {
                    
                    textViewSmall.isHidden = false
                    textViewSmall.isSelectable = true
                    textViewSmall.isEditable = false
                    textViewSmall.text = content
                    
                    webViewBig.isHidden = true
                    webViewSmall.isHidden = true
                    webViewBig.isUserInteractionEnabled = false
                    webViewSmall.isUserInteractionEnabled = false
                    
                    if(selectedProposal?.executed == true) {
                        bottomView.isHidden = true
                        bottomView.isUserInteractionEnabled = false
                    }
                    
                }
            
        }
        
    }
    
    var voteValue = false
    
    func voteSubmitted(){
        submitButton.isEnabled = false
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        if(successfullySubmitted == true){
            costLabel.text = "vote submitted!"
        }
    }
    
    @IBAction func noButtonPress(_ sender: Any) {
        submitButton.isEnabled = true
        submitButton.tintColor = colourVoteRed
        
        voteValue = false
    }
    
    @IBAction func yesButtonPress(_ sender: Any) {
        submitButton.isEnabled = true
        submitButton.tintColor = colourVoteGreen
        
        voteValue = true
        
    }
    
    @IBAction func submitButtonPress(_ sender: Any) {
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        submitButton.tintColor = colourThemeLight2
        submitButton.setTitle("submitting...", for: .normal)
        Task{
            await submitVote(voteValue: voteValue)
        }
    }
    

}
