//
//  Created by Ryland Sepic on 6/3/20.
//

import Firebase
import UIKit

class TransactionViewController: UITableViewController {
    var friends:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFriends()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "tableCell")
    }
    
    func loadFriends() {
        let uid = FirebaseHelper.shared_instance.uid
        let db = Firestore.firestore()
        db.collection("users").document(uid).collection("friends").getDocuments() { (querySnapshot, error) in
            if let err = error {
                print(err)
            } else {
                guard let document = querySnapshot else {
                    print("Transaction.loadFriends(): Could not unwrap the query snapshot")
                    return
                }
                
                for doc in document.documents {
                    self.friends.append(doc.documentID)
                }

                DispatchQueue.main.async {
                    /// Make sure there is something in friends and then update the table
                    if self.friends.count > 0 {
                        self.tableView.reloadData()
                        let indexPath = IndexPath(row: self.friends.count - 1, section: 0)
                        self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let req = friends[indexPath.row]
        let cell  = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath)
        cell.textLabel?.text = req
        
        return cell
    }
    
    /*
     * Delegate function to recognize row selection. Segues to selected posting.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let transferVC = storyboard.instantiateViewController(identifier: "TransferVC") as! TransferViewController
        transferVC.recipient = friends[indexPath.row]
    
        self.navigationController?.pushViewController(transferVC, animated: true)
    }
}
