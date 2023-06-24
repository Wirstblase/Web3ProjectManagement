//
//  yourProfileViewController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 19.06.2023.
//

import UIKit
import CoreImage.CIFilterBuiltins

protocol yourProfileViewControllerDelegate: AnyObject{
    func didFinishYourProfileViewController()
}

class yourProfileViewController: UIViewController {

    @IBOutlet weak var addressLabel: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: yourProfileViewControllerDelegate?
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = Data(string.utf8)
        let filter = CIFilter.qrCodeGenerator()

        filter.setValue(data, forKey: "inputMessage")
        
        if let qrCodeImage = filter.outputImage {
            let scaleX = imageView.frame.size.width / qrCodeImage.extent.size.width
            let scaleY = imageView.frame.size.height / qrCodeImage.extent.size.height
            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = myAddressStringGlobal
        // Do any additional setup after loading the view.
        let qrCodeImage = generateQRCode(from: myAddressStringGlobal)
        imageView.image = qrCodeImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if isMovingFromParent || isBeingDismissed{
            delegate?.didFinishYourProfileViewController()
        }
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
