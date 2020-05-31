//
//  Created by Ryland Sepic on 5/30/20.
//

import UIKit
import Firebase

class Request {
    var name:String
    var docID:String
    var friend_pub_key:String
    
    init(name: String, _ doc: String, _ friend_pub_key: String) {
        self.name = name
        self.docID = doc
        self.friend_pub_key = friend_pub_key
    }
}

class FriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var user:String = ""
    var crypto:Crypto? = nil
    var requests:[Request] = []
    var user_id:String = ""
    
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var search_bar: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFriends()
        
        friendsTable.allowsSelection = true
        friendsTable.delegate = self
        friendsTable.dataSource = self
        
        friendsTable.register(FriendCell.self, forCellReuseIdentifier: "FriendCell")
       
        //friendsTable.register(UINib(nibName: "FriendCell", bundle: nil), forCellReuseIdentifier: "FriendCell")
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
     
    } // @IBAction func add_friend()
    
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
                        if let sender = data["sender"] as? String, let target = data["target"] as? String, let docID = data["docID"] as? String, let friend_pub_key = data["sender_public_key"] as? String {
                            print("Going well \(self.user) \(target)")
                            if (target == self.user){
                                
                                let newRequest = Request(name: sender, docID, friend_pub_key)
                                print("New Request \(newRequest)")
                                self.requests.append(newRequest)
                                
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
        cell.textLabel?.text = "You have a friend request from " + req.name
       
        cell.accessoryType = .detailDisclosureButton
        
        cell.actionBlock = { [unowned self] in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let acceptFriendVC = storyboard.instantiateViewController(identifier: "AcceptFriendVC") as! AcceptFriendViewController
            acceptFriendVC.request = self.requests[indexPath.row]
            acceptFriendVC.crypto = self.crypto
            self.navigationController?.pushViewController(acceptFriendVC, animated: true)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let acceptFriendVC = storyboard.instantiateViewController(identifier: "AcceptFriendVC") as! AcceptFriendViewController
        acceptFriendVC.request = self.requests[indexPath.row]
        acceptFriendVC.crypto = self.crypto
        self.navigationController?.pushViewController(acceptFriendVC, animated: true)
    }
    
    // If user touches the friend request
    private func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let acceptFriendVC = storyboard.instantiateViewController(identifier: "AcceptFriendVC") as! AcceptFriendViewController
        acceptFriendVC.request = requests[indexPath.row]
        acceptFriendVC.crypto = self.crypto
        self.navigationController?.pushViewController(acceptFriendVC, animated: true)
    }
} // class FriendsVC

class FriendCell: UITableViewCell {
    var actionBlock = { }

    func userPressedCell() { // some action like button tap in cell occured
        actionBlock()
    }
}




