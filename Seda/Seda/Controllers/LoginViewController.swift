//
//  LoginViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/11/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    var userEmail:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        self.warningLabel.text = nil
        if let email = emailText.text, let password = passwordText.text {
            
            self.userEmail = email // So the email can be accessed within the closure
            
            Auth.auth().signIn(withEmail: email + "@seda.com", password: password) { authResult, error in
                if let err = error {
                    print(err)
                    self.warningLabel.text =  err.localizedDescription
                    self.emailText.text = ""
                    self.passwordText.text = ""
                } else {
                    //navigate to the next page
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let profileVC = storyboard.instantiateViewController(identifier: "ProfileVC") as! ProfileViewController
                        
                    profileVC.userEmail = self.userEmail
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        }
    }
    

}
