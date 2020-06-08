//
// Created by the Tigers on 4 June 2020
//

/// This file is a helper that stores contstanct information related to the current logged in user
///

import Firebase
import Foundation

extension FirebaseHelper {
    func addFriend(pub_key: String, friend_name: String) {
        /// Send friend request
        db.collection("users").getDocuments { (querySnapshot, error) in
            if let err = error {
                print(err)
            } else {
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        if let username = data["username"] as? String {
                            if username == friend_name {
                                let request_ref = self.db.collection("friend_requests").addDocument(data: [
                                    "sender" : self.username,
                                    "sender_public_key" : pub_key,
                                        "target": friend_name,
                                        "pending" : true
                                ]) { (error) in
                                    if let err = error {
                                        print(err)
                                    } else {
                                        print("Success delivering friend request")
                                    }
                                } // request_ref
                                
                                self.db.collection("friend_requests").document("\(request_ref.documentID)").updateData([
                                    "docID": "\(request_ref.documentID)"
                                ])
                                    
                                self.db.collection("users").document("\(self.uid)").updateData([
                                    "friend_requests": FieldValue.arrayUnion(["\(request_ref.documentID)"])
                                ])
                                
                                return
                            } else {
                                /// User does not exist
                            } // else
                        }
                    }
                }
            } // if else
        } // db.collection for username
    } // func
    
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
    
    func reject_request(docID: String) {
        db.collection("friend_requests").document("\(docID)").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
} // extension FirebaseHelper

