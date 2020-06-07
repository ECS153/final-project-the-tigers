//
//  Created by The Tigers on 6/5/20.
//

import Firebase
import Foundation

extension FirebaseHelper {
    /// The user follows through with removing money from their account and giving it to someone else
    func make_transaction(target: String, amount: Double, message: String) -> Bool  {
        /// Reverse sign of amount because it is being taken out of the account
        if updateBalance(update_amount: (amount * -1)) == true {
            /// Add the transaction to user data
            let doc_ref = db.collection("transactions").addDocument(data: [
                    "sender": self.username,
                    "target" : target,
                    "amount" : amount,
                    "message" : message,
                    "time" : Date().timeIntervalSince1970,
                    "pending" : true
                ]
            )
            
            /// Add the transaction the user was involved with to their transaction array
            user_document.updateData([
                "transactions" : FieldValue.arrayUnion(["\(doc_ref.documentID)"])
            ])
            
            return true
        }
            
        /// Insufficient funds
        return false
    } // func
    
    func update_account() {
        
    }
    
    /// Accomplish 4 tasks
    ///     Add up the new transactions that involve this user
    ///     Upadate the transaction, as it is no longer pending
    ///     Add the transaction to their account (for their history)
    ///     Update their balance
    func updateAccount() {
        /// Retrive current account balance
        print("Calling update account")
        let group = DispatchGroup()
        var updated_amount: Double = 0  /// Put new amount in here
        
        FirebaseHelper.shared_instance.money_listener = FirebaseHelper.shared_instance.db.collection("transactions").whereField("pending", isEqualTo: true).addSnapshotListener { querySnapshot, error in
            if let err = error {
                print(err)
                group.leave() /// Don't deadlock
                return
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("Could not unwrap querySnapshot in updateAccount()")
                    return
                }
                
                for doc in documents {
                    let data = doc.data()
                    if let target = data["target"] as? String, let amount = data["amount"] as? Double, let pending = data["pending"] as? Bool {
                        if (target == FirebaseHelper.shared_instance.username && pending == true){
                            /// Update pending to complete
                            self.user_document.updateData([
                                "transactions" : FieldValue.arrayUnion(["\(doc.documentID)"])
                            ])
                            
                            if amount != 0 {
                                if FirebaseHelper.shared_instance.updateBalance(update_amount: amount) == false {
                                    print("Something very wrong happened with updating the user's balance")
                                } // if
                            }
                            
                            doc.reference.updateData(["pending": false])
                            return  /// Snapshot queury will be launched again after updateData is done
                        }
                    }
                } // for
            } // if else
        } // addSnapshotListener {}
    } // func updateAccount()
    
    /// Takes the previous amount and the new amount to update the accound
    /// If making a withdarawal hten give a negative number to update_amounts
    func updateBalance(update_amount: Double) -> Bool {
        let new_amount: Double = FirebaseHelper.shared_instance.curr_balance + update_amount
        
        /// Make sure user has enough money
        if new_amount >= 0 {
            FirebaseHelper.shared_instance.curr_balance = new_amount /// Update the balance stored with the shared instance
            self.user_document.updateData([
                "balance" : FirebaseHelper.shared_instance.curr_balance
            ])
            
            print("Updated user's balance: \(update_amount) -> \(new_amount)")
            /// Update the balance on the profile page
            FirebaseHelper.shared_instance.profile_delegate?.loadFromDB()
            return true
        } else {
            print("User has insufficient funds")
            return false
        }
    }

}
