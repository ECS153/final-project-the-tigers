//
//  UserHomeViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/19/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit
import Firebase

class UserHomeViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var walletButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIButton!
    var userEmail:String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        walletButton.applyGradient(colors: [UIColorFromRGB(0x00b09b).cgColor,UIColorFromRGB(0x96c93d).cgColor])
        //hide Back Button on the navigation bar
        chatButton.applyGradient(colors: [UIColorFromRGB(0xA6EAFF).cgColor,UIColorFromRGB(0x12D8FA).cgColor,UIColorFromRGB(0x1FA2FF).cgColor])
        logoutButton.applyGradient(colors: [UIColorFromRGB(0xFF512F).cgColor,UIColorFromRGB(0xEF4746).cgColor,UIColorFromRGB(0xDD2476).cgColor])
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func myWalletPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(identifier: Constants.profilePage) as! ProfileViewController
            
        profileVC.userEmail = self.userEmail
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @IBAction func chatPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let targetRequestVC = storyboard.instantiateViewController(identifier: Constants.targetRequestPage) as! TargetRequestViewController
        self.navigationController?.pushViewController(targetRequestVC, animated: true)
        
    }
    
    @IBAction func logOutPressed(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
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
