//
//  Created by Ryland Sepic on 5/30/20.
//

import UIKit
import Firebase

class FriendCell: UITableViewCell {
    var actionBlock = { }

    func userPressedCell() { // some action like button tap in cell occured
        actionBlock()
    }
}

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var user:String = ""
    var crypto:Crypto? = Crypto.shared_instance
    var requests:[Request] = []
    var user_id:String = ""
    
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var search_bar: UITextField!
    @IBOutlet weak var add_friend_button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round button
        add_friend_button.layer.cornerRadius = 5
        add_friend_button.layer.borderWidth = 1
            
        friendsTable.allowsSelection = true
        friendsTable.delegate = self
        friendsTable.dataSource = self
        
        loadFriends()
        
        friendsTable.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
    }
    
    @IBAction func add_friend(_ sender: Any) {
        guard let searchText = search_bar.text else {
            print("Could not unwrap text")
            return
        }
        
        guard let pub_key = crypto?.generatePublicKey() else {
            print("Could not obtain public key")
            return
        }
                
        /// Send friend request
        let db = Firestore.firestore()
        
        let request_ref = db.collection("friend_requests").addDocument(data:
            [
                "sender" : self.user,
                "sender_public_key" : pub_key,
                "target": (searchText),
                "pending" : true

            ]) { (error) in
            
            if let err = error {
                print(err)
            } else {
                print("Success delivering friend request")
            }
        }
        
        // Get current user
        let curr_user = Auth.auth().currentUser
        guard let uid = curr_user?.uid else {
            print("TransactionVC: unable to unwrap uid")
            return
        }
        db.collection("friend_requests").document("\(request_ref.documentID)").updateData([
            "docID": "\(request_ref.documentID)"
        ])
        
        db.collection("users").document("\(uid)").updateData([
            "friend_requests": FieldValue.arrayUnion(["\(request_ref.documentID)"])
        ])
        
        loadFriends()
    } // @IBAction func add_friend()
    
    /// Loads the table by searching friend request
    /// Then finding which friends this user in involved with
    func loadFriends() {
        let db = Firestore.firestore()
        db.collection("friend_requests")
            .addSnapshotListener { (querySnapshot, error) in
          
            if let err = error {
                print(err)
            } else {
                if let documents = querySnapshot?.documents {
                    for doc in documents {
                        let data = doc.data()
                        if let sender = data["sender"] as? String, let target = data["target"] as? String, let docID = data["docID"] as? String, let friend_pub_key = data["sender_public_key"] as? String, let pending = data["pending"] as? Bool {
                            print("loadFriends \(self.user) \(target)")
                            if (target == self.user) {
                                print(pending)
                                let newRequest = Request(name: "\(sender)", docID, friend_pub_key)
                                //print("New Request \(newRequest)")
                                if self.requests.contains(where: { $0.name == newRequest.name}) == true || pending == false {
                                    continue
                                } else {
                                    self.requests.append(newRequest)
                                }
                                
                                DispatchQueue.main.async {
                                    self.friendsTable.reloadData()
                                    let indexPath = IndexPath(row: self.requests.count - 1, section: 0)
                                    self.friendsTable.scrollToRow(at: indexPath, at: .top, animated: false)
                                }
                            }
                            
                            if (self.user == sender) {
                                let newRequest = Request(name: "\(target)", docID, friend_pub_key)
                               
                                if self.requests.contains(where: {$0.name == newRequest.name}) == true || pending == false {
                                    continue
                                } else {
                                    self.requests.append(newRequest)
                                }
                                
                                DispatchQueue.main.async {
                                    self.friendsTable.reloadData()
                                    let indexPath = IndexPath(row: self.requests.count - 1, section: 0)
                                    self.friendsTable.scrollToRow(at: indexPath, at: .top, animated: false)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let req = requests[indexPath.row]
        let cell  = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell
        cell.textLabel?.text = "You have a pending request with " + req.name

        
        cell.actionBlock = { [unowned self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let acceptFriendVC = storyboard.instantiateViewController(identifier: "AcceptFriendVC") as! AcceptFriendViewController
            acceptFriendVC.request = self.requests[indexPath.row]
            acceptFriendVC.crypto = self.crypto
            self.navigationController?.pushViewController(acceptFriendVC, animated: true)
        }
        
        return cell
    }
    
    /*
     * Delegate function to recognize row selection. Segues to selected posting.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ViewPostingVC = storyboard.instantiateViewController(identifier: "AcceptFriendVC") as! AcceptFriendViewController
        
        ViewPostingVC.modalPresentationStyle = .fullScreen
        ViewPostingVC.request = requests[indexPath.row]
        ViewPostingVC.crypto = self.crypto
        
        self.navigationController?.pushViewController(ViewPostingVC, animated: true)
    }
    
} // class FriendsVC






