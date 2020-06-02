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
                    
                    self.updateAccount(user: self.userEmail)
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let userHomeVC = storyboard.instantiateViewController(identifier: Constants.userHomePage) as! UserHomeViewController
                        
                    userHomeVC.userEmail = self.userEmail
                    self.navigationController?.pushViewController(userHomeVC, animated: true)
                }
            }
        }
    }
    
    /*
     * This is where the user account is updated
     * We cannot update accounts with Firebase unless they are logged into
     * Do any updates necessary in here for when the user logs back in
     */
    func updateAccount(user: String) {
        // Get current user
        let curr_user = Auth.auth().currentUser
        guard let uid = curr_user?.uid else {
            print("TransactionVC: unable to unwrap uid")
            return
        }
        
        let db = Firestore.firestore()
        /// Update the friend requests
        db.collection("friend_requests").addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print(err)
            } else {
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        if let sender = data["sender"] as? String, let target = data["target"] as? String, let docID = data["docID"] as? String, let friend_pub_key = data["target_public_key"] as? String, let user_pub_key = data["sender_public_key"] as? String, let pending = data["pending"] as? Bool {
                            print("Friend request pending between \(user) \(target)")
                            if (sender == user){
                                let data = [
                                    "user_public_key" : user_pub_key,
                                    "friend_public_key" : friend_pub_key
                                ]
                                
                                db.collection("users").document("\(uid)").collection("friends").document(target).setData(data)
                                
                                if (pending == false) {
                                    print("Delete friend request \(docID)")
                                    
                                    let delete_queue = DispatchQueue(label: "delete_queue")
                                    let group = DispatchGroup()
                                    
                                    delete_queue.async {
                                        group.enter()
                                        // dispatch image retreival from Firebase on a global thread.
                                        // NOTE: Ideally the friend request should be deleted from DB
                                        DispatchQueue.global(qos: .userInitiated).async {
                                            db.collection("users").document("\(docID)").delete() { err in
                                                if let err = err {
                                                    print("Error removing document: \(err)")
                                                } else {
                                                    print("Document successfully removed!")
                                                }
                                                
                                                group.leave()
                                            }
                                        }
                                        
                                        group.wait()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
