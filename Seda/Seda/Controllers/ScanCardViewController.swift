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
    
    var cashToSend: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        if let cashToSend = cashToSend {
            cardNumberLabel.text = "Load Balance: $\(cashToSend)"
        }
        scanCardButton.layer.cornerRadius = 25;
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func scanCardButtonIsPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = storyboard.instantiateViewController(withIdentifier: Constants.paymentStoryboard) as! PaymentViewController
        vc1.cashToSend = cashToSend!
        self.navigationController?.pushViewController(vc1, animated: true)
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Constants.paymentStoryboard) as! PaymentViewController
        vc.scanStats = scanViewController.getScanStats()
        vc.number = creditCard.number
        vc.cardImage = creditCard.image
        vc.expiration = creditCard.expiryForDisplay()
        vc.name = creditCard.name
        vc.expiryMonth = expiryMonth
        vc.expiryYear = expiryYear
        vc.cashToSend = cashToSend
        // If you're using Stripe and you include the CardScan/Stripe pod, you
      // can get `STPCardParams` directly from CardScan `CreditCard` objects,
    // which you can use with Stripe's APIs
        let cardParams = creditCard.cardParams()
        print("CARD SCANNED: \(number)")

    // At this point you have the credit card number and optionally the expiry.
    // You can either tokenize the number or prompt the user for more
    // information (e.g., CVV) before tokenizing.

        self.dismiss(animated: true)
        self.present(vc, animated: true)
    }
}
