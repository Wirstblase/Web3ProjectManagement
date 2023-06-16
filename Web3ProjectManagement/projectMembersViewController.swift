//
//  projectMembersViewController.swift
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

class projectMembersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    struct User{
        var address: EthereumAddress
        var username: String
        var tokens: BigUInt
        var profilePictureLink: String
    }
    
    var userCount: BigUInt = 0
    
    var users = [User]()
    
    @IBOutlet weak var addMemberButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    func getUsers(){
        
        Task{
            await getUserCount()
            
            if(userCount > BigUInt(0)){
                for i in stride(from: BigUInt(0), to: userCount, by: 1){
                    
                    let address = await getUserAddressAtIndex(index: i+1)
                    let username = await getUserNameForAddress(inputAddress: address)
                    let tokens = await getTokenCountForAddress(inputAddress: address)
                    let profilePictureLink = await getProfilePictureForAddress(inputAddress: address)
                    var user = User(address: address, username: username, tokens: tokens, profilePictureLink: profilePictureLink)
                    
                    users.append(user)
                    
                    let newIndexPath = IndexPath(row: users.count-1, section: 0)
                    tableView.insertRows(at: [newIndexPath], with: .automatic)
                    //tableView.reloadData()
                    
                    
                }
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUsers()

        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func getUserCount() async{
        
            let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "getTokenHolderCount", parameters: [])
            
            
            
            if let item = response["0"] {
                
                print("getUserCount: \(item)")
                userCount = item as! BigUInt
                
            } else {
                print("getUserCount: Item with key '0' not found")
                
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
    
    func getUserAddressAtIndex(index: BigUInt) async -> EthereumAddress{
        
        var index1 = index - BigUInt(1)
        
        print("getting user address at index: \(index1)")
        
        let response = await getDataFromSmartContract(contractAddress: EthereumAddress(selectedContractStringGlobal)!, urlString: "http://127.0.0.1:7545", abiFilename: "projectContractABI", contractFunctionToCallString: "getTokenHolderAtIndex", parameters: [index1])
        
        print("getUserAddressAtIndex: \(response)")
        
        if let item = response["0"] {
            
            return item as! EthereumAddress
            
        } else {
            print("getUserAddressAtIndex: Item with key '0' not found")
            return EthereumAddress("")!
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberTableCell", for: indexPath) as! projectMembersTableViewCell
        
        cell.bgView.layer.cornerRadius = 20
        cell.memberNameLabel.text = users[indexPath.row].username
        
        if let imageUrl = URL(string: users[indexPath.row].profilePictureLink) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async {
                        if let image = UIImage(data: imageData) {
                            cell.profileImageView.image = image
                        }
                    }
                }
            }
        }
        
        cell.tokenLabel.text = users[indexPath.row].tokens.description
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

}
