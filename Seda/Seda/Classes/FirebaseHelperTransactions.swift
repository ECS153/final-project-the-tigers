//
//  Created by The Tigers on 6/5/20.
//

import Firebase
import Foundation

extension FirebaseHelper {
    /// 1. Get public key corresponding to the target
    func encryptData(target: String, crypto: Crypto, completionHandler: @escaping (_ their_key: SecKey) -> Bool) {
        user_document.collection("friends").document(target).getDocument { document, error in
            if let err = error {
                print(err)
            } else {
                if let document = document {
                    guard let t_key = document.get("friend_public_key") as? String, let m_key = document.get("user_public_key") as? String else {
                        return
                    }
                    
                    guard let their_key = crypto.convertStringToKey(keyRaw: t_key), let  my_key = crypto.convertStringToKey(keyRaw: m_key) else {
                        print("Could not unwrap keys")
                        return
                    }
                    
                    completionHandler(their_key)
                }
            }
        }
    }
    
    /// The user follows through with removing money from their account and giving it to someone else
    func make_transaction(target: String, amount: Double, message: String, crypto: Crypto) -> Bool  {
        /// Reverse sign of amount because it is being taken out of the account
        if updateBalance(update_amount: (amount * -1)) == true {
            /// Add the transaction to user data
            encryptData(target: target, crypto: crypto) { their_key in
                let data = [
                    "sender": self.username,
                    "target" : target,
                    "amount" : amount,
                    "message" : crypto.encrypt(their_key, clearText: message) ?? "Error",
                    "time" : Date().timeIntervalSince1970,
                    "pending" : true
                    ] as [String : Any]
                
                let doc_ref = self.db.collection("transactions").addDocument(data: data)
                
                /// Add the transaction the user was involved with to their transaction array
                self.user_document.collection("transactions").addDocument(data: data)
                
                return true
            }
            
            return true
        }
        
        /// Insufficient funds
        return false
    } // func
    
    /// Accesses the transactions stored within this user's account info in Firebase
    /// When this function is finished then the completion handler is executed where the local array is added to the
    /// array in the view controller
    func get_history (completionHandler: @escaping (_ transactions: [Transaction] ) -> Void) {
        var transactions:[Transaction] = []
        
        user_document.collection("transactions").getDocuments { querySnapshot, error in
            if let err = error {
                print(err)
            } else {
                guard let documents = querySnapshot?.documents else {
                    print("Could not unwrap querySnapshot in updateAccount()")
                    return
                }
                
                for doc in documents {
                    let data = doc.data()
                    if let amount = data["amount"] as? Double,
                        let sender = data["sender"] as? String,
                        let target = data["target"] as? String,
                        let message = data["message"] as? String,
                        let pending = data["pending"] as? Bool {
                        
                        let t = Transaction(amount: amount, sender: sender, target: target, message: message)
                        transactions.append(t)
                    }
                }
            }
                
            completionHandler(transactions)
        }
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
                    if let target = data["target"] as? String,
                        let amount = data["amount"] as? Double,
                        let message = data["message"] as? String,
                        let pending = data["pending"] as? Bool  {
                        if (target == FirebaseHelper.shared_instance.username && pending == true){
                            self.user_document.collection("transactions").addDocument(data: data)
                            
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
