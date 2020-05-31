//
//  Created by Ryland Sepic on 5/30/20.
//

import Foundation
import Firebase


/// DJ's function from TargetRequestVC
/// Returns TRUE or FALSE depending on whether the user was found or not
func checkUserHelper(_ targetUser: String) -> Bool {
    let db = Firestore.firestore()
    var rtnVal:Bool = false
    
    db.collection("users").addSnapshotListener { (querySnapshot, error) in
        if let err = error {
            print(err)
        } else {
            if let documents = querySnapshot?.documents {
                for doc in documents {
                    let data = doc.data()
                    if let username = data["username"] as? String {
                        if username == targetUser {
                            print("User detected")
                            rtnVal = true
                        }
                    }
                }
            }
        }
    } // db.collection()
    
    return rtnVal
}

func getUID() -> String {
    // Get current user
    let curr_user = Auth.auth().currentUser
    guard let uid = curr_user?.uid else {
        print("TransactionVC: unable to unwrap uid")
        return ""
    }
    
    return uid
}

func retrieveFriendsKey(targetUser:String) -> String{
    let uid = getUID()
    var friend_pub_key:String = ""
    let database = Firestore.firestore()
    let uidRef = database.collection("users").document(uid) //.collection("friends").document(targetUser)
    
    let fb_queue = DispatchQueue(label: "fb_queue")
    let group = DispatchGroup()
    
       
    DispatchQueue.global(qos: .userInitiated).async {
        uidRef.getDocument { (document, error) in
            if let err = error {
                print(err)
                group.leave()
            }
            
            if let document = document {
                // If balance is unable to be placed in then use -1
               // guard let data = document.get("friend_public_key") as? String else {
                guard let data = document.get("balance") as? String else {
                    return
                }
                friend_pub_key = data
            }
        }
        
        group.leave()
    }
    
    group.wait()
    
    return friend_pub_key
}

func loadFriends(user: String) {
    let db = Firestore.firestore()
    db.collection("friend_requests")
        .addSnapshotListener { (querySnapshot, error) in
      
        if let err = error {
            print(err)
        } else {
            if let documents = querySnapshot?.documents {
                for doc in documents {
                    let data = doc.data()
                    if let sender = data["sender"] as? String, let target = data["target"] as? String, let docID = data["docID"] as? String, let friend_pub_key = data["sender_public_key"] as? String {
                        print("Going well \(user) \(target)")
                        if (target == user){
                            
                            let newRequest = Request(name: sender, docID, friend_pub_key)
                            print("New Request \(newRequest)")
                //            self.requests.append(newRequest)
                            
                        }
                    }
                }
            }
        }
    }
}

