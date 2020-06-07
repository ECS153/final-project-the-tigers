//
// Created by the Tigers on 4 June 2020
//

import Firebase
import Foundation

/// Shared instance gets created at the beginning of the application execution
/// This retrieves the data once from Firebase and stores it for the remainder of the program
/// The purpose of this helper is to make as few calls from Firebase as possible
/// This steamlines the process as well as smoothens multithreading operations when data needs to be retrieved and updated

class FirebaseHelper {
    /// privae(set): only modifiable within the class but readable outside of it
    static private(set) var shared_instance: FirebaseHelper!
    
    /// Firebase variables
    let db:Firestore
    let user_document: DocumentReference
    var money_listener: ListenerRegistration?
    
    /// Object variables
    var curr_balance: Double
    let uid:String
    let username:String
    
    /// Delegate
    var profile_delegate: refreshProfile?   // Store delgate for ProfileViewController so it can be updated later
    
    private init(_ name: String) {
        self.uid = FirebaseHelper.get_uid()
        self.db = Firestore.firestore()
        self.username = name
        self.user_document = db.collection("users").document(self.uid)
        self.curr_balance = 0
        self.money_listener = nil
    }
    
    static func initialize(_ username: String) {
        self.shared_instance = FirebaseHelper(username)
        
        var curr_amount:Double = 0
        FirebaseHelper.shared_instance.user_document.getDocument { (document, error) in
            if let document = document {
                // If balance is unable to be placed in then use -1
                let bal = document.get("balance") as? Double ?? -1
                curr_amount = bal
            }
            self.shared_instance.curr_balance = curr_amount
            print("Inialize \(shared_instance.curr_balance)")
            FirebaseHelper.shared_instance.updateAccount()  // Retrieve the transfers given to this user while they were logged out
            FirebaseHelper.shared_instance.updateFriends()  // Let this user know if somone accepted their friend request
        }
    }
    
    /// Take the unique user ID and creates a user in the Firebase database
    static func createUser(_uid: String, _name: String) {
        let database = Firestore.firestore()
        database.collection("users").document(_uid).setData([
            "username" : _name,
            "balance" : 0.00,
            "stripeId" : "none",
            "uid": _uid
        ]) { error in
            if error != nil {
                print("Error initializing user account")
            } else {
                print("Account created!")
            }
        }
    }
    
    func detatch_listeners() {
        FirebaseHelper.shared_instance.money_listener?.remove()
    }
    
    static func get_uid () -> String {
        let cur_user = Auth.auth().currentUser
        guard let uid = cur_user?.uid else {
            print("This user does not have a uid")
            return ""
        }
    
        return uid
    }
    
    /*
     * This is where the user account is updated
     * We cannot update accounts with Firebase unless they are logged into
     * Do any updates necessary in here for when the user logs back in
     */
    func updateFriends() {
        /// Update the friend requests
        db.collection("friend_requests").addSnapshotListener { (querySnapshot, error) in
            if let err = error {
                print(err)
            } else {
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        if let sender = data["sender"] as? String, let target = data["target"] as? String, let docID = data["docID"] as? String, let friend_pub_key = data["target_public_key"] as? String, let user_pub_key = data["sender_public_key"] as? String, let pending = data["pending"] as? Bool {
                            if (sender == self.username){
                                let data = [
                                    "user_public_key" : user_pub_key,
                                    "friend_public_key" : friend_pub_key
                                ]
                               
                                self.db.collection("users").document("\(self.uid)").collection("friends").document(target).setData(data)
                               
                                if (pending == false) {
                                    let delete_queue = DispatchQueue(label: "delete_queue")
                                    let group = DispatchGroup()
                                   
                                    delete_queue.async {
                                        group.enter()
                                        // dispatch retreival from Firebase on a global thread.
                                        // NOTE: Ideally the friend request should be deleted from DB
                                        DispatchQueue.global(qos: .userInitiated).async {
                                                self.db.collection("users").document("\(docID)").delete() { err in
                                                    if let err = err {
                                                        print("Error removing document: \(err)")
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
                } // update account()
            } // class FirebaseHelper
        }
    }
} // class FirebaseHelper



