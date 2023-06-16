//
//  newProposal1ViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 16.06.2023.
//

import UIKit

class newProposal1ViewController: UIViewController {

    @IBOutlet weak var proposalTitleTextField: UITextField!
    
    @IBOutlet weak var nextStepButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextStepPress(_ sender: Any) {
        
        newProposalTitleGlobal = proposalTitleTextField.text!
        
        performSegue(withIdentifier: "proposalStep2Segue", sender: nil)
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
