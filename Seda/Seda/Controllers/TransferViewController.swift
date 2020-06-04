//
//  Created by The Tigers on 6/4/20.
//

import UIKit

class TransferViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var pay: UIButton!
    
    var recipient: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amount.keyboardType = UIKeyboardType.decimalPad // Want the user to add numbers
        self.label.text = "Paying: " + self.recipient
    }
    
    
    @IBAction func pay_pressed(_ sender: Any) {
        guard let money = Int(amount.text ?? "-1"), let mess = message.text else {
            print("Did not type information correctly")
            return
        }
        
        FirebaseHelper.shared_instance.make_transaction(target: self.recipient, amount: money, message: mess)
        
        /// Locate view controller in stack
        guard let vc = navigationController?.viewControllers.filter({$0 is ProfileViewController}).first else {
            print("Cannot return to view controller")
            return
        }
   
        navigationController?.popToViewController(vc, animated: true)
    }
}
