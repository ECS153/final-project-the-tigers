//
//  ChatViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/19/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore

class ChatViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageText: UITextField!
    
    var targetUser:String = ""
    
    let db = Firestore.firestore()
    var crypto:Crypto? = nil
    var messages: [Message] = []
    var friend_pub_key:String = ""
    var my_pub_key:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.chatPrototypeCell)
        crypto = Crypto.shared_instance
        loadMessages()
    }
    
    func loadMessages() {
        db.collection("messages")
            .order(by: "time")
            .addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let err = error {
                print(err)
            } else {
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        if let sender = data["sender"] as? String, let body = data["body"] as? String, let target = data["target"] as? String {
                            if (sender == Auth.auth().currentUser?.email && target == (self.targetUser + "@seda.com"))
                                || (target == Auth.auth().currentUser?.email && sender == (self.targetUser + "@seda.com")){
                                
                                /// Try three steps of decrytption
                                /// 1. Decrypt with friends public key
                                /// 2. Decrypt with your own key
                                /// 3. Assume this is clear text sent without encryption and just display it
                                if let clearText = self.crypto?.decrypt(dataString: body) {
                                    let newMessage = Message(sender: sender, body: clearText)
                                    self.messages.append(newMessage)
                                } else if let senderBody = data["senderBody"] as? String, let clearText = self.crypto?.decrypt(dataString: senderBody){
                                    let newMessage = Message(sender: sender, body: clearText)
                                    self.messages.append(newMessage)
                                } else {
                                    let newMessage = Message(sender: sender, body: body)
                                    self.messages.append(newMessage)
                                }
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        let encryption_queue = DispatchQueue(label: "encryption_queue")
        let group = DispatchGroup()
        
        guard let message_text = self.messageText.text else {
            return
        }
        
        // Run this in a separate thread because Firebase is slower than the function
        encryption_queue.async {
            // Use the inputted username to access DB
            let users = FirebaseHelper.shared_instance.user_document.collection("friends").document(self.targetUser)
               
            group.enter()
            // dispatch image retreival from Firebase on a global thread.
            DispatchQueue.global(qos: .userInitiated).async {
                users.getDocument { (document, error) in
                    if let document = document {
                        // If balance is unable to be placed in then use -1
                        guard let bal = document.get("friend_public_key") as? String, let bal_mine = document.get("user_public_key") as? String else {
                            group.leave()
                            return
                        }
                        self.friend_pub_key = bal
                        self.my_pub_key = bal_mine
                    }
                    
                    group.leave()
                }
            }
            
            group.wait()
            
            /// If encryption is in place then send encrypted message
            /// Else just send plain text
            if let friendsKey = self.crypto?.convertStringToKey(keyRaw: self.friend_pub_key),
                let myPubKey = self.crypto?.convertStringToKey(keyRaw: self.my_pub_key),
                let messageBody = self.crypto?.encrypt(friendsKey, clearText: message_text),
                let senderBody = self.crypto?.encrypt(myPubKey, clearText: message_text)
            {
                if let messageSender = Auth.auth().currentUser?.email {
                    
                    FirebaseHelper.shared_instance.db.collection("messages").addDocument(data: ["sender" : messageSender,
                                                                 "body": messageBody,
                                                                 "senderBody" : senderBody,
                                                                 "time": Date().timeIntervalSince1970,
                                                                 "target": (self.targetUser + "@seda.com")]) { (error) in
                        if let err = error {
                            print(err)
                        } else {
                            DispatchQueue.main.async {
                                self.messageText.text = ""
                            }
                        }
                    }
                } // if messageSender
            } else {
                if let messageSender = Auth.auth().currentUser?.email {
                    FirebaseHelper.shared_instance.db.collection("messages")
                        .addDocument(data: [
                            "sender" : messageSender,
                             "body": message_text,
                             "senderBody" : message_text,
                             "time": Date().timeIntervalSince1970,
                             "target": (self.targetUser + "@seda.com")])
                    { (error) in
                        if let err = error {
                            print(err)
                        } else {
                            DispatchQueue.main.async {
                                self.messageText.text = ""
                            }
                        }
                    }
                } // if messageSender
            } // if true then cipher text else clearText
        } // async queue
    } // func
} // class

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        let cell  = tableView.dequeueReusableCell(withIdentifier: Constants.chatPrototypeCell, for: indexPath) as! MessageTableViewCell
        cell.messageLabel?.text = message.body
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftPersonImageView.isHidden = true
            cell.personImageView.isHidden = false
            cell.messageView.backgroundColor = UIColor.orange
            cell.messageLabel.textColor = UIColor.white
        } else {
            cell.leftPersonImageView.isHidden = false
            cell.personImageView.isHidden = true
            cell.messageView.backgroundColor = UIColor.systemGray4
            cell.messageLabel.textColor = UIColor.black
        }
        return cell
    }

    
}

