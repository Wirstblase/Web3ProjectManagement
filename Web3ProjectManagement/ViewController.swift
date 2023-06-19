//
//  ViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 12.06.2023.
//

import UIKit
import web3swift
import Web3Core
import BigInt
import Network
import Foundation

var web3GlobalAddress = "http://127.0.0.1:7545"
var myAddressStringGlobal = " "
var myPrivateKeyStringGlobal = ""
var mainContractStringGlobal = ""
var selectedContractStringGlobal = ""

var selectedUserStringGlobal = ""
var selectedProjectNameGlobal = ""

var userNameStringGlobal = ""

var newProposalTitleGlobal:String = ""
var newProposalContentGlobal:String = ""

func UIColorFromRGB(rgbValue: UInt) -> UIColor {
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

let colourThemeLight2 = UIColorFromRGB(rgbValue: 0xC9ADA7)

let colourVoteGreen = UIColorFromRGB(rgbValue: 0x1f8038)
let colourVoteRed = UIColorFromRGB(rgbValue: 0x80201f)

func formatEthereumBalance(_ balance: BigUInt) -> String {
    let ethereumValue: Double = Double(balance) / 1_000_000_000_000_000_000 // Convert balance to ETH value
    let ethereumString: String
    
    if ethereumValue >= 1.0 {
        ethereumString = String(format: "%.2f", ethereumValue) // Show 2 decimals for balances >= 1 ETH
    } else {
        let decimalsToShow = max(4 - Int(log10(ethereumValue)), 0) // Calculate number of decimals to show
        ethereumString = String(format: "%.*f", decimalsToShow, ethereumValue)
    }
    
    return ethereumString
}

func getBalanceStringFormatted(inputAddress: EthereumAddress, urlString:String) async -> String{
    
    
        do {
            
            let url = URL(string: urlString)
            
            let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
            
            let web3 = Web3(provider: provider)
            
            let balanceResult = try await web3.eth.getBalance(for: inputAddress)
            
            let divisor: Double = 1000000000000000000 // The divisor to achieve the desired decimal places

            var formattedValue = String(format: "%.2f", Double(balanceResult) / divisor)
            formattedValue = "\(formattedValue) ETH"
            
            formattedValue = "\(formatEthereumBalance(balanceResult)) ETH"
            
            return formattedValue
            
            
        } catch {
            print("error: \(error)")
            return("error")
        }
    
    
}

func getDataFromSmartContract(contractAddress: EthereumAddress, urlString: String, abiFilename: String, contractFunctionToCallString: String, parameters: [Any] ) async -> [String:Any]{
    do {

        print("in get data from smart contract function")
        
        let url = URL(string: urlString)
        
        let provider = try await Web3HttpProvider(url: url!, network: Networks.Custom(networkID: 5777))
        
        let web3 = Web3(provider: provider)
        
        let path = Bundle.main.path(forResource: abiFilename, ofType: "txt")
        
        let abiString = try String(contentsOfFile: path!)
        
        let contract = web3.contract(abiString, at: contractAddress)
        
        let inputAddress = EthereumAddress(myAddressStringGlobal)
        
        let readOp = contract?.createReadOperation(contractFunctionToCallString, parameters: parameters)
        
        readOp?.transaction.from = EthereumAddress(myAddressStringGlobal)
        
        let gasPrice = BigUInt(integerLiteral: 1000000000)
        var transaction = try readOp?.transaction
        transaction?.gasPrice = gasPrice
        
        let response = try await readOp?.callContractMethod()
        
        //print("GET TOKEN CALL\(String(describing: response))")
        
        return response ?? ["error": "error"]
        
        /*if let item = response?["0"] {
            //print("name for project with address \(projectAddress.address): \(item)")
            //tableItemCount = item as! BigUInt
            return item as! String
        } else {
            print("Item with key '0' not found")
        }*/
        
    } catch {
        print("error in main task function loadTableData: \(error)")
    }
    return ["error": "error"]
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        performSegue(withIdentifier: "showLoginPage", sender: self)
    }


}

