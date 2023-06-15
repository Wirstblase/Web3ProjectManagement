//
//  customNavigationController.swift
//  Web3ProjectManagement
//
//  Created by Suflea Marius on 15.06.2023.
//

import UIKit

class customNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationItem.backBarButtonItem?.tintColor = colourThemeLight2
        // Do any additional setup after loading the view.
        self.navigationBar.tintColor = colourThemeLight2
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
