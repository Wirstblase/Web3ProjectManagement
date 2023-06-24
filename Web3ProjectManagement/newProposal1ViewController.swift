//
//  newProposal1ViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 16.06.2023.
//

import UIKit

class newProposal1ViewController: UIViewController, newProposal3ViewControllerDelegate {

    @IBOutlet weak var proposalTitleTextField: UITextField!
    
    @IBOutlet weak var nextStepButton: UIButton!
    
    weak var delegate: newProposal3ViewControllerDelegate?
    
    func didFinishNewProposal3ViewController() {
        print("newProposal1ViewController got the delegate call")
        if delegate == nil {
            print("newProposal1ViewController's delegate is nil")
        } else {
            delegate?.didFinishNewProposal3ViewController()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextStepPress(_ sender: Any) {
        
        newProposalTitleGlobal = proposalTitleTextField.text!
        
        performSegue(withIdentifier: "proposalStep2Segue", sender: nil)
    }
    
    // In newProposal1ViewController
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("newProposal1ViewController will disappear")
        
        if isMovingFromParent || isBeingDismissed {
            print("newProposal1ViewController is calling delegate method")
            delegate?.didFinishNewProposal3ViewController()
        }
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? newProposal2ViewController {
                vc.delegate = self
                print("newProposal1ViewController set delegate for newProposal2ViewController")
                delegate?.didFinishNewProposal3ViewController() // call the delegate method here
            }
    }
    

}
