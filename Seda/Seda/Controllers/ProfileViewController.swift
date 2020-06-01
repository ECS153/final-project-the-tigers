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
    
    var uid:String = ""
    var userEmail:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username.text = userEmail
        loadFromDB()
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
