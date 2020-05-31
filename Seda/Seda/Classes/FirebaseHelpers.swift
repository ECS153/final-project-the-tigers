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

