//
//  Created by Ryland Sepic on 5/30/20.
//

import UIKit
import Firebase

class AcceptFriendViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    
    var request:Request? = nil
    var crypto:Crypto? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let req = request else {
            print("Could not unwarp request type")
            return
        }
        
        titleLabel.text = "Accept friend request from " + req.name
        
    }
    
    @IBAction func yes_pressed(_ sender: Any) {
        let db = Firestore.firestore()
        
        guard let pub_key = crypto?.generatePublicKey() else{
            return
        }
        
        guard let req = request else {
            return
        }
        
        db.collection("friend_requests").document(req.docID).updateData([
            "target_public_key": pub_key,
            "pending": false
        ])
        
        // Get current user
        let curr_user = Auth.auth().currentUser
        guard let uid = curr_user?.uid else {
            print("TransactionVC: unable to unwrap uid")
            return
        }
        
        let data = [
            "user_public_key" : pub_key,
            "friend_public_key" : req.friend_pub_key
        ]
        
        db.collection("users").document("\(uid)").collection("friends").document(req.name).setData(data)
        goBack()
    }
    
    @IBAction func no_pressed(_ sender: Any) {
        removeFriendRequest()
        
        goBack()
    }
    
    func removeFriendRequest() {
        let db = Firestore.firestore()
        guard let req = request else {
            return
        }
        
        db.collection("friend_requests").document(req.docID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func goBack() {
        //navigationController?.popViewController(animated: true)
        /// Locate view controller in stack and bring user back to their profile
        guard let vc = self.navigationController?.viewControllers.filter({$0 is ProfileViewController}).first else {
            print("Cannot return to view controller")
            return
        }
        self.navigationController?.popToViewController(vc, animated: true)
    }
}
