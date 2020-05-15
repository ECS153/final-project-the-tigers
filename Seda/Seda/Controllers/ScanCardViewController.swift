//
//  ScanViewController.swift
//  Seda
//
//  Created by Josh Steubs on 5/13/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit
import CardScan

class ScanCardViewController: UIViewController, ScanDelegate {
    
    @IBOutlet weak var scanCardButton: UIButton!
    @IBOutlet weak var cardNumberLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanCardButton.layer.cornerRadius = 25;
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func scanCardButtonIsPressed(_ sender: UIButton) {
        guard let vc = ScanViewController.createViewController(withDelegate: self) else {
            print("This device is incompatible with CardScan")
            return
        }
    
        self.present(vc, animated: true)
    }

    func userDidSkip(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
    
    func userDidCancel(_ scanViewController: ScanViewController) {
        self.dismiss(animated: true)
    }
    
    func userDidScanCard(_ scanViewController: ScanViewController, creditCard: CreditCard) {
        let number = creditCard.number
        let expiryMonth = creditCard.expiryMonth
        let expiryYear = creditCard.expiryYear
        cardNumberLabel.text = cardNumberLabel.text! + number
        
        // If you're using Stripe and you include the CardScan/Stripe pod, you
      // can get `STPCardParams` directly from CardScan `CreditCard` objects,
    // which you can use with Stripe's APIs
        let cardParams = creditCard.cardParams()
        print("CARD SCANNED: \(number)")

    // At this point you have the credit card number and optionally the expiry.
    // You can either tokenize the number or prompt the user for more
    // information (e.g., CVV) before tokenizing.

        self.dismiss(animated: true)
    }
}
