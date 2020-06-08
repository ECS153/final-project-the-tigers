//
//  Created by The Tigers on 6/4/20.
//

import UIKit

class TransferViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var pay: UIButton!
    
    var crypto:Crypto? = nil
    var recipient: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amount.keyboardType = UIKeyboardType.decimalPad // Want the user to add numbers
        self.label.text = "Paying: " + self.recipient
        self.amount.delegate = self
    }
    
    
    @IBAction func pay_pressed(_ sender: Any) {
        guard let money = Double(amount.text ?? "-1"), let mess = message.text else {
            print("Did not type information correctly")
            return
        }
        
        let encryption_queue = DispatchQueue(label: "balance_queue")
        
        encryption_queue.async {
            /// Run this on background thread

            FirebaseHelper.shared_instance.make_transaction(target: self.recipient, amount: money, message: mess) { success in
                /// Update UI on main thread
                DispatchQueue.main.async {
                    if success == false {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let alert = UIAlertController(title: "Insufficient funds", message: "Looks like you need to add more funds", preferredStyle: .alert)
                        
                        /// User can chose to add more money
                        alert.addAction(UIAlertAction(title: "Add funds", style: .cancel) { _ in
                            let addMoneyVC = storyboard.instantiateViewController(identifier: "LoadBalanceVC") as! LoadBalanceViewController
                            self.navigationController?.pushViewController(addMoneyVC, animated: true)
                        })
                        
                        /// User can continue
                        alert.addAction(UIAlertAction(title: "Continue", style: .default))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                
                    /// Locate view controller in stack and bring user back to their profile
                    guard let vc = self.navigationController?.viewControllers.filter({$0 is ProfileViewController}).first else {
                        print("Cannot return to view controller")
                        return
                    }
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
        }
    }
    
    /// Text field deleagte function for making sure the user cannot add anymore than two decimal places
    /// Also stops user from being able to add things that are not numbers
    /// Source: https://stackoverflow.com/questions/45443289/how-to-limit-the-textfield-entry-to-2-decimal-places-in-swift-4
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var num_dec_dig: Int = 0
        
        guard let prev_text = textField.text else {
            print("Some type of error in the textField function")
            return true // Return true if the text needs to be replaced in some way
        }
        
        guard let ranger = Range(range, in: prev_text) else {
            print("Some kind of error inside textField function")
            return true
        }

        let new_text = prev_text.replacingCharacters(in: ranger, with: string)
        
        let is_num = (Double(new_text) != nil) || new_text.isEmpty // Make sure that numbers are what was actually entered
        let num_of_decimals = new_text.components(separatedBy: ".").count - 1 // Stop user from being able to add in mulitple decimal places
        
        // This portion makes sure that the number only goes to the hundreth place
        if let decimal_index = new_text.firstIndex(of: ".") {
            num_dec_dig = new_text.distance(from: decimal_index, to: new_text.endIndex) - 1
        } else {
            num_dec_dig = 0
        }

        return num_of_decimals <= 1 && num_dec_dig <= 2 && is_num
    }
}
