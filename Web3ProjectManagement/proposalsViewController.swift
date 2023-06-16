//
//  proposalsViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 14.06.2023.
//

import UIKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

struct Proposal{
    var description: String
    var content: String
    var executed: Bool
    var currentVote: BigInt
    var voteCount: BigUInt
    var issuerAddress: EthereumAddress
}

class proposalsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var plusButtonView: UIView!
    
    @IBOutlet weak var totalProposalsLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var tokenOwnLabel: UILabel!
    
    @IBOutlet weak var projectNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var proposalCount: BigUInt = 0
    
    var tokenHolderCount: BigUInt = 0
    
    var selectedProposalIndex: BigUInt = 99
    
    var selectedProposal:Proposal?
    
    var proposals = [Proposal]()
    
    func getProposalCount() async{
        
            let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "getProposalCount", parameters: [])
            
            if let item = response["0"] {
                
                proposalCount = item as! BigUInt
                
                let item1: String = (item as! BigUInt).description
                
                totalProposalsLabel.text = "\(item1) total proposals:" //haha
        
                
            } else {
                print("getProposalCount: Item with key '0' not found")
                totalProposalsLabel.text = "proposals:"
            }
        
    }
    
    func getProjectName() {
        
        Task{
            let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "projectName", parameters: [])
            
            //print(response)
            
            if let item = response["0"] {
                
                projectNameLabel.text = item as! String
                
            } else {
                print("getProjectName: Item with key '0' not found")
                projectNameLabel.text = "failed to fetch project name"
            }
        }
        
    }
    
    func getProjectTokens() {
        
        Task{
            let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "balances", parameters: [EthereumAddress(myAddressStringGlobal)!])
            
            if let item = response["0"] {
                tokenOwnLabel.text = "you own \(item) out of 100 tokens"
                progressView.setProgress(mapValueToProgressBar(Float(item as! BigUInt)), animated: true)
            } else {
                print("getProjectTokens: Item with key '0' not found")
                tokenOwnLabel.text = "failed to fetch your token balance"
            }
        }

    }
    
    func getTokenHolderCount(){
    
        Task{
            let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "getTokenHolderCount", parameters: [])
            
            if let item = response["0"] {
                tokenHolderCount = item as! BigUInt
                print("tokenHolderCount: \(tokenHolderCount)")
            } else {
                print("getTokenHolderCount: Item with key '0' not found")
            }
        }
        
    }
    
    func loadTableData(index: BigUInt) async{
        
        print(selectedContractStringGlobal)
        
        let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "proposals", parameters: [index-BigUInt(1)])
            
            print("response: \(response), index: \(index-BigUInt(1))")
            
            /*
             response: ["1": "I propose internet freedom >:(", "description": "Internet freedom", "_success": true, "executed": false, "2": false, "4": 0, "3": 0, "content": "I propose internet freedom >:(", "currentVote": 0, "voteCount": 0, "0": "Internet freedom"], index: 0
             
             var description: String
             var content: String
             var executed: Bool
             var currentVote: BigInt
             var voteCount: BigUInt
             */
            //do {
            let description = response["0"] as! String
            let success = response["2"] as! Bool
            let currentVote = response["3"] as! BigInt
            let voteCount = response["4"] as! BigUInt
            let issuerAddress = EthereumAddress(myAddressStringGlobal)! //response["5"] as! EthereumAddress //TODO: implement this in smart contract
        
            print("loadTableData: description: \(description), success: \(success), currentVote: \(currentVote), voteCount: \(voteCount)")
            
        let proposal:Proposal = Proposal(description: description, content: "", executed: success, currentVote: currentVote, voteCount: voteCount, issuerAddress: issuerAddress)
        
            proposals.append(proposal)
        let newIndexPath = IndexPath(row: proposals.count-1, section: 0)
        tableView.insertRows(at: [newIndexPath], with: .fade)
            
            //} catch {
            //    print("error parsing table data lol")
            //}
        
    }
    
    func mapValueToProgressBar(_ value: Float) -> Float {
        let minValue: Float = 0.1
        let maxValue: Float = 1.0
        
        let mappedValue = (maxValue - minValue) * (value / 100.0) + minValue
        return mappedValue
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressView.setProgress(0, animated: false)
        
        getProjectName()
        getProjectTokens()
        getTokenHolderCount()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        plusButtonView.layer.cornerRadius = 30
        
        Task{
            
            await getProposalCount()
            
            if(proposalCount > BigUInt(0)){
                
                for i in stride(from: BigUInt(0), to: proposalCount, by: 1){
                    
                    await loadTableData(index: i+1)
                    
                }
                
            }
            
            
        }

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proposalCell", for: indexPath) as! proposalsTableViewCell
        
        let proposal = proposals[indexPath.row]
        
        cell.proposalTitleLabel.text = proposal.description
        
        print("tokenHolderCount: \(tokenHolderCount), proposal.currentVote: \(proposal.currentVote)")
        
        //MARK: must fix
        
        if(tokenHolderCount > proposal.currentVote){
            if(proposal.executed == false){
                cell.proposalStatusLabel.text = "pending.. \(proposal.voteCount)/\(tokenHolderCount) votes"
                cell.bgView.backgroundColor = UIColorFromRGB(rgbValue: 0x9A8C98)
                
            }
        } else if(tokenHolderCount == proposal.voteCount){
            if(proposal.executed == true){
                cell.proposalStatusLabel.text = "approved"
                cell.bgView.backgroundColor = UIColorFromRGB(rgbValue: 0x1f8038)
            } else {
                cell.proposalStatusLabel.text = "rejected"
                cell.bgView.backgroundColor = UIColorFromRGB(rgbValue: 0x80201f)
            }
        }
        
        cell.proposalIssuerAddressLabel.text = ""
        cell.proposalIssuerNameLabel.text = ""
        
        cell.bgView.layer.cornerRadius = 20
        cell.fgView.layer.cornerRadius = 20
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return proposals.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProposal = proposals[indexPath.row]
        
        selectedProposalIndex = BigUInt(indexPath.row)
        
        performSegue(withIdentifier: "openVoteSegue", sender: self)
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if(segue.identifier == "openVoteSegue"){
            let destinationVC = segue.destination as! proposalViewController
            destinationVC.selectedProposal = selectedProposal
            
            destinationVC.selectedProposalIndex = selectedProposalIndex
        }
        
    }
    

}
