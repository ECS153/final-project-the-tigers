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
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.chatPrototypeCell)
        
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
                        if let sender = data["sender"] as? String, let body = data["body"] as? String {
                            if sender == Auth.auth().currentUser?.email || sender == (self.targetUser + "@seda.com"){
                                let newMessage = Message(sender: sender, body: body)
                                self.messages.append(newMessage)
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
        if let messageBody = messageText.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection("messages").addDocument(data: ["sender" : messageSender, "body": messageBody, "time": Date().timeIntervalSince1970]) { (error) in
                if let err = error {
                    print(err)
                } else {
                    DispatchQueue.main.async {
                        self.messageText.text = ""
                    }
                }
            }
        }
    }
    

}

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

