//
//  TargetRequestViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/20/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit

class TargetRequestViewController: UIViewController {

    @IBOutlet weak var targetTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func startPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatVC = storyboard.instantiateViewController(identifier: Constants.chatPage) as! ChatViewController
        self.navigationController?.pushViewController(chatVC, animated: true)
        if let targetUser = targetTextField.text{
            chatVC.targetUser = targetUser
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
