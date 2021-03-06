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

protocol refreshProfile {
    func loadFromDB()
}

class ProfileViewController: UIViewController, refreshProfile {
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var friends_button: UIButton!
    @IBOutlet weak var send_money_button: UIButton!
    var uid:String = ""
    var userEmail:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        username.text = userEmail
        FirebaseHelper.shared_instance.profile_delegate = self
        loadFromDB()
    }
    
    @IBAction func view_history(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hisVC = storyboard.instantiateViewController(identifier: "HistoryVC") as! HistoryTableViewController
        self.navigationController?.pushViewController(hisVC, animated: true)
    }
    

    @IBAction func friend_button_pressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let friendVC = storyboard.instantiateViewController(identifier: "FriendsViewController") as! FriendsViewController
        friendVC.user = userEmail
        friendVC.user_id = uid
        self.navigationController?.pushViewController(friendVC, animated: true)
    }
    
    @IBAction func add_money(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addMoneyVC = storyboard.instantiateViewController(identifier: "CardScanVC") as! ScanCardViewController
        
        self.navigationController?.pushViewController(addMoneyVC, animated: true)
    }
    
    @IBAction func send_money_pressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let transactionVC = storyboard.instantiateViewController(identifier: "TransactionVC") as! TransactionViewController
        self.navigationController?.pushViewController(transactionVC, animated: true)
    }
   
    /*
     * Load user's balance
     */
    func loadFromDB() {
        DispatchQueue.main.async {
            self.balance.text = "$" + String(format: "%.2f", FirebaseHelper.shared_instance.curr_balance)
        }
    } // loadFromDB()
}
