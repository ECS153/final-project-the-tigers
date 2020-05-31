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
            "target_public_key": pub_key
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
        navigationController?.popViewController(animated: true)
    }
}
