//
//  ChatViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/19/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageText: UITextField!
    
    var messages: [Message] = [
        Message(sender: "test2@seda.com", body: "hidafjoewf"),
        Message(sender: "test2@seda.com", body: "hidafjoewfj")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.chatPrototypeCell)
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
    }
    

}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCell(withIdentifier: Constants.chatPrototypeCell, for: indexPath) as! MessageTableViewCell
        cell.messageLabel?.text = messages[indexPath.row].body
        return cell
    }

    
}

