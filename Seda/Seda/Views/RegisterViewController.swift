//
//  RegisterViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/11/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    var userEmail:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        self.warningLabel.text = nil
        if let email = emailText.text, let password = passwordText.text {
            
            self.userEmail = email
            
            // @seda.com satisfired Firebase's requirement of an email address
            // without the user needing to input their email
            Auth.auth().createUser(withEmail: email + "@seda.com", password: password) { authResult, error in
                if let err = error {
                    print(err)
                    self.warningLabel.text =  err.localizedDescription
                } else {
                    // Obtain unique user ID from Firebase
                    guard let uid = authResult?.user.uid else {
                        print("Error obtaining user ID.")
                        return
                    }
                    
                    self.createUser(uid: uid, name: email)
                    //navigate to the next page
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let userHomeVC = storyboard.instantiateViewController(identifier: Constants.userHomePage) as! UserHomeViewController
                        
                    userHomeVC.userEmail = self.userEmail
                    self.navigationController?.pushViewController(userHomeVC, animated: true)
                }
            }
        }
    }
    
    /*
     * Take the unique user ID and creates a user in the Firebase database
     */
    func createUser(uid: String, name: String) {
        
        let db = Firestore.firestore()
        
        db.collection("users").document(uid).setData([
            "username" : name,
            "balance" : 0.01, // Adding a penny to confirm something was added
            "stripeId" : "none",
            "uid": uid
        ]) { error in
            if error != nil {
                print("Error initializing user account")
            } else {
                print("Account created!")
            }
        }
    }
    
} // RegisterViewController

    
