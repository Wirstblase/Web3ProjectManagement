//
//  proposalViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 15.06.2023.
//
//  refactor 1

import UIKit
import WebKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

class proposalViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var textViewSmall: UITextView!
    
    var tokenHolderCount:BigUInt = 0
    
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
    
    var hasVoted = false
    
    func getContent() async -> String{
        
        //MARK: this will be deprecated and replaced with getProposalContent([index])
        do{
            let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "proposals", parameters: [selectedProposalIndex!])
            
            print("Sender: \(myAddressStringGlobal) getContent:  \(response)")
            
            return response["1"] as! String
        }
        
        
    }
    
    func getVotedStatus() async{
        
        do{
            
            let url = URL(string: "http://127.0.0.1:7545")
            
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            
            let web3 = Web3(provider: provider)
            
            let contractAddress = EthereumAddress(selectedContractStringGlobal)
            
            print("contract address: \(selectedContractStringGlobal)")
            
            let path = Bundle.main.path(forResource: "projectContractABI", ofType: "txt")
            
            let abiString = try String(contentsOfFile: path!)
            
            let contract = web3.contract(abiString, at: contractAddress)
            
            let inputAddress = EthereumAddress(myAddressStringGlobal)
            
            let readOp = contract?.createReadOperation("hasVoted", parameters: [selectedProposalIndex!,inputAddress])
            
            readOp?.transaction.from = EthereumAddress(myAddressStringGlobal)
            
            let gasPrice = BigUInt(integerLiteral: 1000000000)
            var transaction = try readOp?.transaction
            transaction?.gasPrice = gasPrice
            
            let response = try await readOp?.callContractMethod()
            
            //print("hasVoted response for \(selectedProposalIndex!): \(response)")
            
            do {
                print("hasVoted response=\(response)")
                hasVoted = response!["0"] as! Bool
                print("hasVoted = \(hasVoted)")
            } catch {
                print("cannot get response[0] in hasVoted")
            }
            
        } catch {
            print("error in getVotedStatus: \(error)")
        }
    

        //let response = await getDataFromSmartContract(contractAddress: EthereumAddress(myAddressStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "hasVoted", parameters: [BigUInt(0),EthereumAddress("0x3c78EDB97934A126382B34036788A5eef1cB71F5")])
        
            //print("hasVoted response for \(selectedProposalIndex!): \(response)")
        
            /*if let item = response["0"] {
                hasVoted = item as! Bool
                print("hasVoted: \(item)")
            } else {
                print("hasVoted: Item with key '0' not found")
            }*/

        
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
    
    
    func createTransaction() async -> Result<CodableTransaction, Error>{
        
        
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
            
            /*var gasLimit: BigUInt = try await web3.eth.estimateGas(for: transaction)
            print("estimated gas limit: \(gasLimit * 50)")
            if(gasLimit * 50 > BigUInt(6721975)){
                gasLimit = BigUInt(5000000)
            } else {
                gasLimit = gasLimit * BigUInt(50)
            }*/
            let gasLimit = BigUInt(5000000)
            
            transaction.gasLimit = gasLimit
            transaction.gasPrice = try await web3.eth.gasPrice()
            transaction.from = EthereumAddress(myAddressStringGlobal)
            transaction.nonce = try await web3.eth.getTransactionCount(for: EthereumAddress(myAddressStringGlobal)!)
            
            
            print("gas limit: \(try await web3.eth.estimateGas(for: transaction))")
            print("gas price: \(try await web3.eth.gasPrice())")

            //print("createTransaction: \(transaction)")
            return .success(transaction)
        } catch {
            print("error in createTransaction: \(error)")
            return .failure(error)
        }
        
    }
    
    func submitVote(voteValue: Bool) async{
        
        do{
            let url = URL(string: "http://127.0.0.1:7545")
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            let web3 = Web3(provider: provider)
            //let transaction = try await createTransaction()
            
            let result = await createTransaction()
            switch result {
            case .success(let transaction):
                
                let result = try await web3.eth.send(transaction)
                
                submitButton.isEnabled = false
                balanceLabel.text = "vote sent successfully!"
                
                // use transaction
            case .failure(let error):
                // handle error
                if(error.localizedDescription.contains("Already voted")){
                    balanceLabel.text = "you already voted!"
                } else {
                    balanceLabel.text = "error"
                }
            }
            
            

        print("submitVote result: \(result)")
    } catch {
        print("error in submitVote:: \(error)")
    }
        
    }
    
    func estimateCost() async{
        costLabel.text = "estimated gas fee: estimating..."
        
            //let transaction = await createTransaction()
            
            let result = await createTransaction()
            switch result {
            case .success(let transaction):
                let gasLimit = transaction.gasLimit //bigUInt
                
                var formattedValue = formatEthereumBalance(gasLimit)
                
                costLabel.text = "estimated gas fee: \(formattedValue) ETH"
                // use transaction
            case .failure(let error):
                // handle error
                
                print("error: \(error)")
                balanceLabel.text = error.localizedDescription
                
                /*if(selectedProposal?.votingDone == false){
                    
                    print("error: \(error.localizedDescription)")
                    
                    if(error.localizedDescription.contains("Already voted")){
                        
                        balanceLabel.text = "already voted!!!"
                        
                        costLabel.text = "waiting for all members to vote"
                        //estimateButton.isEnabled = false
                        
                        noButton.isEnabled = false
                        yesButton.isEnabled = false
                        submitButton.isEnabled = false
                        
                    } else {
                        balanceLabel.text = "error"
                    }
                    
                }*/
                
            }
            
            
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadBalance()
        
        noButton.tintColor = colourVoteRed
        yesButton.tintColor = colourVoteGreen
        
        submitButton.isEnabled = false
        
        self.navigationItem.title = selectedProposal?.description
        
        bottomView.isHidden = true
        bottomView.isUserInteractionEnabled = false
        
        Task{
            
            let content = await getContent()
            await getVotedStatus()
            
            if(content.hasPrefix("<!Doctype html>")){
                
                if(selectedProposal?.executed == true || selectedProposal?.totalVoters == tokenHolderCount){
                    
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
                    
                    if(selectedProposal?.votingDone == false){
                        
                        if(hasVoted == true){
                            bottomView.isHidden = true
                            bottomView.isUserInteractionEnabled = false
                        } else {
                            bottomView.isHidden = false
                            bottomView.isUserInteractionEnabled = true
                        }
                        
                    } else {
                        
                        bottomView.isHidden = true
                        bottomView.isUserInteractionEnabled = false
                        
                    }
                    
                    /*if(selectedProposal?.votingDone == false){
                        await estimateCost()
                    }
                    
                    if(selectedProposal?.votingDone == true) {
                        bottomView.isHidden = true
                        bottomView.isUserInteractionEnabled = false
                    } else {
                        bottomView.isHidden = false
                        bottomView.isUserInteractionEnabled = true
                    }*/
                    
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
    
    @IBAction func estimateButtonPress(_ sender: Any) {
        Task {
            await estimateCost()
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
        submitButton.setTitle("submitting...\(voteValue) vote", for: .normal)
        Task{
            await submitVote(voteValue: voteValue)
            submitButton.setTitle("done", for: .normal)
        }
    }
    

}
