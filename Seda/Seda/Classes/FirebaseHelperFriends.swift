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
} // extension FirebaseHelper

