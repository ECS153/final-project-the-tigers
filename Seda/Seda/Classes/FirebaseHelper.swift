//
// Created by the Tigers on 4 June 2020
//

/// This file is a helper that stores contstanct information related to the current logged in user
/// 

import Firebase

class FirebaseHelper {
    /// privae(set): only modifiable within the class but readable outside of it
    static private(set) var shared_instance: FirebaseHelper!
    let uid:String
    let db:Firestore
    let username:String
    let user_document: DocumentReference
    var profile_delegate: refreshProfile?   // Store delgate for ProfileViewController so it can be updated later
    
    private init(_ name: String) {
        self.uid = FirebaseHelper.get_uid()
        self.db = Firestore.firestore()
        self.username = name
        self.user_document = db.collection("users").document(self.uid)
    }
    
    static func initialize(_ username: String) {
        self.shared_instance = FirebaseHelper(username)
     }
    
    static func get_uid () -> String {
        let cur_user = Auth.auth().currentUser
        guard let uid = cur_user?.uid else {
            print("This user does not have a uid")
            return ""
        }
    
        return uid
    }
    
    func make_transaction(target: String, amount: Int, message: String) {
        /// Add the transaction to user data
        user_document.collection("transactions").addDocument(data: [
                "sender": self.username,
                "target" : target,
                "amount" : amount,
                "message" : message,
                "time" : Date().timeIntervalSince1970
            ]
        )
        
        let encryption_queue = DispatchQueue(label: "balance_queue")
        let group = DispatchGroup()
        
        encryption_queue.async {
            group.enter()
            /// Update the user's balance
            /// Run this asychronously and make sure that the balance is retrieved before it is updated
            var prev_amount: Int = 0
            self.user_document.getDocument { (doc, error) in
                guard let fb_bal = doc?.get("balance") as? Int else {
                    print("Could not retrieve user's balance from Firebase")
                    return
                }
                prev_amount = fb_bal
                group.leave()
            }
            
            group.wait()
            self.user_document.updateData([
                 "balance" : (prev_amount - amount)
            ])
            
            /// Update the balance on the profile page
            FirebaseHelper.shared_instance.profile_delegate?.loadFromDB()
        }
    }
}


