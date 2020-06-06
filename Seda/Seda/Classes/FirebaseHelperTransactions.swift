//
//  Created by The Tigers on 6/5/20.
//

import Firebase
import Foundation

extension FirebaseHelper {
    /// Get the user's current balance
    /// Static function to be called at the beginning to initialize the user's balance
    func getCurrBalance() -> Double {
        var curr_amount: Double = 0
        
        self.user_document.getDocument { (document, error) in
            if let document = document {
                // If balance is unable to be placed in then use -1
                let bal = document.get("balance") as? Double ?? -1
                curr_amount = bal
            }
        }
        
        return curr_amount
    }
    
    /// The user follows through with removing money from their account and giving it to someone else
    func make_transaction(target: String, amount: Double, message: String) -> Bool  {
        let group = DispatchGroup()
        var curr_amount:Double = 0
        group.enter()
        /// Aschronously obtain users blance
        DispatchQueue.global(qos: .userInitiated).async {
            self.user_document.getDocument { (doc, error) in
                guard let fb_bal = doc?.get("balance") as? Double else {
                    print("Could not retrieve user's balance from Firebase")
                    return // Doesn't rtn because within closure
                }
                curr_amount = fb_bal
                group.leave()
            }
        }
        group.wait()
        
        /// Reverse sign of amount because it is being taken out of the account
        if updateBalance(prev_amount: curr_amount, update_amount: (amount * -1)) == true {
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
    
    func updateAccount() {
        /// Retrive current account balance
        let group = DispatchGroup()
        let group2 = DispatchGroup()
        var prev_amount: Double = 0
        var updated_amount: Double = 0  /// Put new amount in here
        
        let queue = DispatchQueue(label: "Current_Balance_Queue")
        queue.async{
            /// Wait for this function somewhere outside of it
            
            group.enter()
            /// Aschronously obtain users blance
            DispatchQueue.global(qos: .userInitiated).async {
                self.user_document.getDocument { (doc, error) in
                    guard let fb_bal = doc?.get("balance") as? Double else {
                        print("Could not retrieve user's balance from Firebase")
                        return // Doesn't rtn because within closure
                    }
                    prev_amount = fb_bal
                }
            }

            DispatchQueue.global(qos: .userInitiated).async {
                self.db.collection("transactions").addSnapshotListener { (querySnapshot, error) in
                    if let err = error {
                        print(err)
                        group2.leave()
                        return
                    } else {
                        guard let documents = querySnapshot?.documents else {
                            print("Could not unwrap querySnapshot in updateAccount()")
                            return
                        }
                        print(documents)
                        for doc in documents {
                            let data = doc.data()
                            if let target = data["target"] as? String, let amount = data["amount"] as? Double, let pending = data["pending"] as? Bool {
                                print(target)
                                if (target == self.username && pending == true){
                                    updated_amount += amount
                                    
                                    /// Update pending to complete
                                    //self.updateTransaction()
                                    doc.reference.updateData([
                                        "pending": false
                                        ]
                                    )
                                }
                            }
                        }
                    }
                    
                    group.leave()
                }
            }
            
            group.wait()
        
            if self.updateBalance(prev_amount: prev_amount, update_amount: updated_amount) == false {
                print("Something very wrong happened with updating the user's balance")
            }
        }
    }
    
    /// Takes the previous amount and the new amount to update the accound
    /// If making a withdarawal hten give a negative number to update_amounts
    func updateBalance(prev_amount: Double, update_amount: Double) -> Bool {
        let new_amount: Double = prev_amount + update_amount
        /// Make sure user has enough money
        if new_amount >= 0 {
            self.user_document.updateData([
                 "balance" : (prev_amount + update_amount)
            ])
            
            /// Update the balance on the profile page
            FirebaseHelper.shared_instance.profile_delegate?.loadFromDB()
            return true
        } else {
            print("User has insufficient funds")
            return false
        }
    }

}
