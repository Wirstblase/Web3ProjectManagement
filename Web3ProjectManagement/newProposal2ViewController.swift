//
//  newProposal2ViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 16.06.2023.
//

import UIKit

class newProposal2ViewController: UIViewController {

    @IBOutlet weak var proposalContentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextStepPress(_ sender: Any) {
        
        newProposalContentGlobal = proposalContentTextView.text
        
        performSegue(withIdentifier: "proposalStep3Segue", sender: nil)
        
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
