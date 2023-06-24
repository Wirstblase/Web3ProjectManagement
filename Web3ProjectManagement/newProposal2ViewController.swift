//
//  newProposal2ViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 16.06.2023.
//

import UIKit

class newProposal2ViewController: UIViewController, newProposal3ViewControllerDelegate {

    @IBOutlet weak var proposalContentTextView: UITextView!
    
    weak var delegate: newProposal3ViewControllerDelegate?
    
    func didFinishNewProposal3ViewController() {
        print("newProposal2ViewController got the delegate call")
        if delegate == nil {
            print("newProposal2ViewController's delegate is nil")
        } else {
            delegate?.didFinishNewProposal3ViewController()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextStepPress(_ sender: Any) {
        
        newProposalContentGlobal = proposalContentTextView.text
        
        performSegue(withIdentifier: "proposalStep3Segue", sender: nil)
        
    }
    
    // In newProposal2ViewController
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("newProposal2ViewController will disappear")
        
        if isMovingFromParent || isBeingDismissed {
            print("newProposal2ViewController is calling delegate method")
            delegate?.didFinishNewProposal3ViewController()
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? newProposal3ViewController {
                vc.delegate = self
                print("newProposal2ViewController set delegate for newProposal3ViewController")
                delegate?.didFinishNewProposal3ViewController() // call the delegate method here
            }
    }
    

}
