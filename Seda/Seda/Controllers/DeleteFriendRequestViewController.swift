//
//  DeleteFriendRequestViewController.swift
//  Seda
//
//  Created by Ryland Sepic on 6/7/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit

class DeleteFriendRequestViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    var request:Request? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let req = request else {
            print("Could not unwarp request type")
            return
        }
        
        label.text = "Delete friend request to " + req.name
    }
    

    @IBAction func delete_button(_ sender: Any) {
        guard let req = request else {
            print("Could not unwarp request type")
            return
        }
        
        FirebaseHelper.shared_instance.reject_request(docID: req.docID)
        
        /// Locate view controller in stack and bring user back to their profile
        guard let vc = self.navigationController?.viewControllers.filter({$0 is ProfileViewController}).first else {
            print("Cannot return to view controller")
            return
        }
        self.navigationController?.popToViewController(vc, animated: true)
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
