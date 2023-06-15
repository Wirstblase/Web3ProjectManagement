//
//  ProjectListViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 13.06.2023.
//

import UIKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

class ProjectListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userBalanceLabel: UILabel!
    
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var plusButtonView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userBackgroundView: UIView!
    
    @IBOutlet weak var filterButton: UIButton!
    
    var tableItemCount:BigUInt = BigUInt(0)
    
    struct projectData{
        var name: String
        var address: String
        var yourTokens: String
    }
    
    var projects = [projectData]()
    
    func loadTableItemCount() async{
        
        //Task {
            do {

                let url = URL(string: "http://127.0.0.1:7545")
                
                let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
                
                let web3 = Web3(provider: provider)
                
                let contractAddress = EthereumAddress(mainContractStringGlobal)
                
                let path = Bundle.main.path(forResource: "userManagerABI", ofType: "txt")
                
                let abiString = try String(contentsOfFile: path!)
                
                let contract = web3.contract(abiString, at: contractAddress)
                
                let inputAddress = EthereumAddress(myAddressStringGlobal)
                
                let readOp = contract?.createReadOperation("getNumberOfProjects", parameters: [inputAddress])
                
                readOp?.transaction.from = EthereumAddress(myAddressStringGlobal)
                
                let gasPrice = BigUInt(integerLiteral: 1000000000)
                var transaction = try readOp?.transaction
                transaction?.gasPrice = gasPrice
                
                let response = try await readOp?.callContractMethod()
                
                if let item = response?["0"] {
                    //print("tableItemCount: \(item)")
                    tableItemCount = item as! BigUInt
                } else {
                    print("Item with key '0' not found")
                }
                
            } catch {
                print("error in main task function loadTableItemCount: \(error)")
            }
        //}
        
    }
    
    func loadProfilePicture(){
        Task {
            do {
                
                let url = URL(string: "http://127.0.0.1:7545")
                
                //print("before trying provider")
                
                let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
                
                let web3 = Web3(provider: provider)
                
                let contractAddress = EthereumAddress(mainContractStringGlobal)
                
                let path = Bundle.main.path(forResource: "userManagerABI", ofType: "txt")
                
                let abiString = try String(contentsOfFile: path!)
                
                let contract = web3.contract(abiString, at: contractAddress)
                
                //print(contract.debugDescription)
                
                //let inputAddress = EthereumAddress(myAddressStringGlobal)!
                //let inputParameters: [AnyObject] = [inputAddress]
                let inputAddress = EthereumAddress(myAddressStringGlobal)
                
                let readOp = contract?.createReadOperation("getProfilePicture", parameters: [inputAddress])
                
                readOp?.transaction.from = EthereumAddress(myAddressStringGlobal)
                
                //print("before calling contract")
                
                let gasPrice = BigUInt(integerLiteral: 1000000000)
                var transaction = try readOp?.transaction
                transaction?.gasPrice = gasPrice
                
                let response = try await readOp?.callContractMethod()
                
                let value = response!["0"] as? String
                
                let imageUrlString = value //"https://example.com/image.jpg"

                if let imageUrl = URL(string: imageUrlString!) {
                    DispatchQueue.global().async {
                        if let imageData = try? Data(contentsOf: imageUrl) {
                            DispatchQueue.main.async {
                                if let image = UIImage(data: imageData) {
                                    self.userProfileImageView.image = image
                                }
                            }
                        }
                    }
                }
                
                
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    func loadUsername(){
        
        Task {
            do {
                
                let url = URL(string: "http://127.0.0.1:7545")
                
                //print("before trying provider")
                
                let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
                
                let web3 = Web3(provider: provider)
                
                let contractAddress = EthereumAddress(mainContractStringGlobal)
                
                let path = Bundle.main.path(forResource: "userManagerABI", ofType: "txt")
                
                let abiString = try String(contentsOfFile: path!)
                
                let contract = web3.contract(abiString, at: contractAddress)
                
                //print(contract.debugDescription)
                
                //let inputAddress = EthereumAddress(myAddressStringGlobal)!
                //let inputParameters: [AnyObject] = [inputAddress]
                let inputAddress = EthereumAddress(myAddressStringGlobal)
                
                let readOp = contract?.createReadOperation("getUsername", parameters: [inputAddress])
                
                readOp?.transaction.from = EthereumAddress(myAddressStringGlobal)
                
                //print("before calling contract")
                
                let gasPrice = BigUInt(integerLiteral: 1000000000)
                var transaction = try readOp?.transaction
                transaction?.gasPrice = gasPrice
                
                let response = try await readOp?.callContractMethod()
                
                let value = response!["0"] as? String
                
                userNameLabel.text = value
                
                
            } catch {
                print("error: \(error)")
            }
        }
        
    }
    
    func loadNameForProject(projectAddress: EthereumAddress) async -> String{
        do {

            let url = URL(string: "http://127.0.0.1:7545")
            
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            
            let web3 = Web3(provider: provider)
            
            let contractAddress = projectAddress
            
            let path = Bundle.main.path(forResource: "projectContractABI", ofType: "txt")
            
            let abiString = try String(contentsOfFile: path!)
            
            let contract = web3.contract(abiString, at: contractAddress)
            
            let inputAddress = EthereumAddress(myAddressStringGlobal)
            
            let readOp = contract?.createReadOperation("projectName", parameters: [])
            
            readOp?.transaction.from = EthereumAddress(myAddressStringGlobal)
            
            let gasPrice = BigUInt(integerLiteral: 1000000000)
            var transaction = try readOp?.transaction
            transaction?.gasPrice = gasPrice
            
            let response = try await readOp?.callContractMethod()
            
            print(response)
            
            if let item = response?["0"] {
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
    
    func loadTokensForProject(projectAddress: EthereumAddress) async -> BigUInt{
        
        do {

            let url = URL(string: "http://127.0.0.1:7545")
            
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            
            let web3 = Web3(provider: provider)
            
            let contractAddress = projectAddress
            
            let path = Bundle.main.path(forResource: "projectContractABI", ofType: "txt")
            
            let abiString = try String(contentsOfFile: path!)
            
            let contract = web3.contract(abiString, at: contractAddress)
            
            let inputAddress = EthereumAddress(myAddressStringGlobal)
            
            let readOp = contract?.createReadOperation("balances", parameters: [inputAddress])
            
            readOp?.transaction.from = EthereumAddress(myAddressStringGlobal)
            
            let gasPrice = BigUInt(integerLiteral: 1000000000)
            var transaction = try readOp?.transaction
            transaction?.gasPrice = gasPrice
            
            let response = try await readOp?.callContractMethod()
            
            print(response)
            
            if let item = response?["0"] {
                //print("tokens for address \(projectAddress.address): \(item)")
                return item as! BigUInt
                //tableItemCount = item as! BigUInt
            } else {
                print("Item with key '0' not found")
            }
            
        } catch {
            print("error in main task function loadTableData: \(error)")
        }
        
        return BigUInt(0)
        
    }
    
    func loadTableData(index: BigUInt) async{
    
        //Task {
            do {

                let url = URL(string: "http://127.0.0.1:7545")
                
                let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
                
                let web3 = Web3(provider: provider)
                
                let contractAddress = EthereumAddress(mainContractStringGlobal)
                
                let path = Bundle.main.path(forResource: "userManagerABI", ofType: "txt")
                
                let abiString = try String(contentsOfFile: path!)
                
                let contract = web3.contract(abiString, at: contractAddress)
                
                let inputAddress = EthereumAddress(myAddressStringGlobal)
                
                let readOp = contract?.createReadOperation("getProjectAddress", parameters: [inputAddress,index-BigUInt(1)])
                
                readOp?.transaction.from = EthereumAddress(myAddressStringGlobal)
                
                let gasPrice = BigUInt(integerLiteral: 1000000000)
                var transaction = try readOp?.transaction
                transaction?.gasPrice = gasPrice
                
                let response = try await readOp?.callContractMethod()
                
                if let item = response?["0"] {
                    //print("contract address: \(item)")
                    
                    var newTableRow:projectData = projectData(name: "", address: "", yourTokens: "")
                    
                    newTableRow.yourTokens = await loadTokensForProject(projectAddress: item as! EthereumAddress).formatted()
                    
                    newTableRow.name = await loadNameForProject(projectAddress: item as! EthereumAddress)
                    
                    newTableRow.address = (item as! EthereumAddress).address
                    
                    projects.append(newTableRow)
                    
                    let newIndexPath = IndexPath(row: projects.count-1, section: 0)
                    tableView.insertRows(at: [newIndexPath], with: .fade)
                    
                    //tableView.reloadData()
                    
                    
                    print(newTableRow)
                    //tableItemCount = item as! BigUInt
                } else {
                    print("loadTableData: Item with key '0' not found")
                }
                
            } catch {
                print("error in main task function loadTableData: \(error)")
            }
        //}
        
        
    }
    
    func loadBalance(){
        
        Task {
            do {
                
                let url = URL(string: "http://127.0.0.1:7545")
                
                let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
                
                let web3 = Web3(provider: provider)
                
               
                let inputAddress = EthereumAddress(myAddressStringGlobal)
                
                let balanceResult = try await web3.eth.getBalance(for: inputAddress!)
                
                let divisor: Double = 1000000000000000000 // The divisor to achieve the desired decimal places

                var formattedValue = String(format: "%.2f", Double(balanceResult) / divisor)
                formattedValue = "\(formattedValue) ETH"
                //if let balance = balanceResult{
                //print("balance: \(formattedValue)")
                userBalanceLabel.text = formattedValue
                
                
                
            } catch {
                print("error: \(error)")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userBackgroundView.layer.cornerRadius = 30
        
        plusButtonView.layer.cornerRadius = 30
        
        tableView.delegate = self
        tableView.dataSource = self
        
        filterButton.tintColor = colourThemeLight2
        
        loadUsername()
        loadProfilePicture()
        loadBalance()
        
        Task{
            
            await loadTableItemCount()
            
            if(tableItemCount > BigUInt(0)){
                
                //print("in loop")
                
                for i in stride(from: BigUInt(0), to: tableItemCount, by: 1){
                    //print("loops")
                    await loadTableData(index: i+1)
                }
                
            }
            
        }
        
        
    }
    
    @IBAction func plusButtonPress(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "projectListCell", for: indexPath) as! projectListTableViewCell
        
        let project = projects[indexPath.row]
        
        cell.projectTitleLabel.text = project.name
        cell.viewBg.layer.cornerRadius = 20
        cell.tokensLabel.text = "\(project.yourTokens)"
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedContractStringGlobal = projects[indexPath.row].address
        performSegue(withIdentifier: "loadProjectFeedSegue", sender: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
