//
//  TransactionDetailsViewController.swift
//  Seda
//
//  Created by Ryland Sepic on 6/7/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit

class TransactionDetailsViewController: UIViewController {
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var receiver: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var message: UILabel!
    
    var transaction:Transaction? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let t = transaction else {
            return
        }
        
        sender.text = "Send from " + t.sender
        receiver.text = "Received by " + t.target
        amount.text = "Amount: " + String(format: "%.2f", t.amount)
        message.text = t.message
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
