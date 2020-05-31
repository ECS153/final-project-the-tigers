//
//  Created by Ryland Sepic on 5/30/20.
//

import UIKit
import Firebase

class AcceptFriendViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    
    var request:Request? = nil
  
    var crypto:Crypto? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func yes_pressed(_ sender: Any) {
        let db = Firestore.firestore()
        let ref = db.collection("friend_requests")
        
        let pub_key = crypto?.generatePublicKey()
        
       
        
        goBack()
    }
    
    @IBAction func no_pressed(_ sender: Any) {
        goBack()
    }
    
    func goBack() {
        navigationController?.popToRootViewController(animated: true)
    }
}
