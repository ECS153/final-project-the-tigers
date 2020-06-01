//
//  ProfileViewController.swift
//  Seda
//
//  Created by Ryland Sepic on 5/17/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseFirestore

class ProfileViewController: UIViewController {
    @IBOutlet weak var balance: UILabel!
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var friends_button: UIButton!
    
    var uid:String = ""
    var userEmail:String = ""
    var crypto:Crypto? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        let icon = UIImage(named: "friends_icon")
        friends_button.setImage(icon, for: .normal)
        friends_button.imageView?.contentMode = .scaleAspectFit

        username.text = userEmail
        crypto = Crypto(userEmail)
        loadFromDB()
    }
    
    @IBAction func friend_button_pressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendVC = storyboard.instantiateViewController(identifier: "FriendsViewController") as! FriendsViewController
        friendVC.user = userEmail
        friendVC.crypto = crypto
        friendVC.user_id = uid
        self.navigationController?.pushViewController(friendVC, animated: true)
    }
    
    @IBAction func add_money(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addMoneyVC = storyboard.instantiateViewController(identifier: "CardScanVC") as! ScanCardViewController
        
        self.navigationController?.pushViewController(addMoneyVC, animated: true)
    }
    
    /*
     * Load user's information from Firebase
     */
    func loadFromDB() {
        let cur_user = Auth.auth().currentUser
        guard let uid = cur_user?.uid else {
            print("This user does not have a uid")
            return
        }
        
        // Use the inputted username to access DB
        let db = Firestore.firestore()
        let users = db.collection("users").document(uid)
        
        users.getDocument { (document, error) in
            if let document = document {
                // If balance is unable to be placed in then use -1
                let bal = document.get("balance") as? Double ?? -1
                self.balance.text = "$" + String(format: "%.2f", bal)
            }
        }
    } // loadFromDB()
}
