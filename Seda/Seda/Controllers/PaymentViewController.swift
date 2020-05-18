//
//  PaymentViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/17/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit
import Stripe
import CardScan

class PaymentViewController: UIViewController {

    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    @IBOutlet weak var cardNumberLabel: UILabel!
    
    var scanStats: ScanStats?
    var number: String?
    var expiration: String?
    var name: String?
    var cardImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardNumberLabel.text = format(number: self.number ?? "")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func payPressed(_ sender: UIButton) {
    }
    
    func format(number: String) -> String {
        if number.count == 16 {
            return format16(number: number)
        } else if number.count == 15 {
            return format15(number: number)
        } else {
            return number
        }
    }
    
    func format15(number: String) -> String {
        var displayNumber = ""
        for (idx, char) in number.enumerated() {
            if idx == 4 || idx == 10 {
                displayNumber += " "
            }
            displayNumber += String(char)
        }
        return displayNumber
    }
    
    func format16(number: String) -> String {
        var displayNumber = ""
        for (idx, char) in number.enumerated() {
            if (idx % 4) == 0 && idx != 0 {
                displayNumber += " "
            }
            displayNumber += String(char)
        }
        return displayNumber
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
