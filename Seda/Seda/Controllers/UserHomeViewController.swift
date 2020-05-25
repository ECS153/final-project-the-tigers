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
    
    var userEmail:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //hide Back Button on the navigation bar
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
