//
//  TargetRequestViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/20/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit
import FirebaseFirestore

class TargetRequestViewController: UIViewController {

    @IBOutlet weak var targetTextField: UITextField!
    @IBOutlet weak var warningLabel: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func startPressed(_ sender: UIButton) {
        if let targetUser = targetTextField.text{
            self.warningLabel.text = ""
            checkUser(targetUser)
        }
    }
    
    func checkUser(_ targetUser: String) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print(err)
            } else {
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        if let username = data["username"] as? String {
                            if username == targetUser {
                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                let chatVC = storyboard.instantiateViewController(identifier: Constants.chatPage) as! ChatViewController
                                self.navigationController?.pushViewController(chatVC, animated: true)
                                chatVC.targetUser = targetUser
                            } else {
                                self.warningLabel.text = "User Not Found"
                            }
                        }
                    }
                }
            }
        }
    }
}
