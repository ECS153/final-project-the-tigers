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
import Firebase
import FirebaseFirestore
import FirebaseFunctions

class PaymentViewController: UIViewController {
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var expirationMonthTextField: UITextField!
    @IBOutlet weak var expirationYearTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    let backendUrl = "https://us-central1-seda-63547.cloudfunctions.net/createPaymentIntentTest"
    var scanStats: ScanStats?
    var number: String?
    var expiration: String?
    var name: String?
    var expiryMonth: String?
    var expiryYear: String?
    var cardImage: UIImage?
    var cashToSend: String?
    var paymentIntentClientSecret: String?
    var balance: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        //startCheckout()
        startCheckoutFirebaseTest(with: backendUrl)
        self.cardNumberLabel.text = format(number: self.number ?? "4242424242424242")
        if expiration != nil {
            expirationMonthTextField.text = expiryMonth
            expirationYearTextField.text = expiryYear
            expirationMonthTextField.isUserInteractionEnabled = false
            expirationYearTextField.isUserInteractionEnabled = false
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func payPressed(_ sender: UIButton) {
        pay()
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
    
    func displayAlert(title: String, message: String, restartDemo: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if restartDemo {
                alert.addAction(UIAlertAction(title: "Back to Profile", style: .cancel) { _ in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let profileVC = storyboard.instantiateViewController(identifier: Constants.profilePage) as! ProfileViewController
                    self.navigationController?.pushViewController(profileVC, animated: true)
                })
            }
            else {
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func addBalance() {
        let cur_user = Auth.auth().currentUser
        guard let uid = cur_user?.uid else {
            print("This user does not have a uid")
            return
        }
        print(uid)
        let db = Firestore.firestore()
        let users = db.collection("users").document(uid)
        
        users.getDocument { (document, error) in
            if let err = error {
                print(err)
            } else {
                // If balance is unable to be placed in then use -1
                let balance = document!.get("balance") as? Double ?? -1
                if let cashToSend = self.cashToSend {
                    let updateBalance: Double = balance + Double(cashToSend)!
                    print(updateBalance)
                    db.collection("users").document(uid).setData([
                        "balance" : updateBalance
                    ]) { error in
                        if error != nil {
                            print("Error updating balance")
                        } else {
                            print("Balance update!")
                        }
                    }
                }
            }
        }
    }
    
    func startCheckoutFirebaseTest(with urlString: String) {
        if var url = URLComponents(string: urlString) {
            url.queryItems = [
                URLQueryItem(name: "amount", value: cashToSend! + "00")
            ]
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url.url!) { (data, response, error) in
                if error != nil {
                    print("error")
                    return
                }
                if let safeData = data {
                    if let clientSecret = self.parseJSON(safeData) {
                        self.paymentIntentClientSecret = clientSecret
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ clientData: Data) -> String? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(ClientData.self, from: clientData)
            let clientSecret = decodedData.clientSecret
            return clientSecret
            
        } catch {
            print("fail to decode the clientSecret")
            return nil
        }
    }
    
    @objc
    func pay() {
        print("Payment processing...")
        guard let paymentIntentClientSecret = paymentIntentClientSecret else {
            return;
        }
        // Collect card details
        let cardParams = STPPaymentMethodCardParams()
        if let number = number {
            cardParams.number = number
        }
        //use the test card number
        cardParams.number = "4242424242424242"
        if expiryMonth == nil {
            cardParams.expMonth = NSNumber(value: Int(expirationMonthTextField.text ?? "") ?? 0)
            cardParams.expYear = NSNumber(value: Int(expirationYearTextField.text ?? "") ?? 0)
        } else {
            cardParams.expMonth = NSNumber(value: Int(expiryMonth  ?? "") ?? 0)
            cardParams.expYear = NSNumber(value: Int(expiryYear  ?? "") ?? 0)
        }
        if let cvc = cvcTextField.text {
            cardParams.cvc = cvc
           // cardTextField.postalCode = zip
        }
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        let paymentIntentParams = STPPaymentIntentParams(clientSecret: paymentIntentClientSecret)
        paymentIntentParams.paymentMethodParams = paymentMethodParams

        // Submit the payment
        let paymentHandler = STPPaymentHandler.shared()
        paymentHandler.confirmPayment(withParams: paymentIntentParams, authenticationContext: self) { (status, paymentIntent, error) in
            switch (status) {
            case .failed:
                self.displayAlert(title: "Payment failed", message: error?.localizedDescription ?? "")
                break
            case .canceled:
                self.displayAlert(title: "Payment canceled", message: error?.localizedDescription ?? "")
                break
            case .succeeded:
                self.addBalance()
                self.displayAlert(title: "Payment succeeded", message: paymentIntent?.description ?? "", restartDemo: true)
                break
            @unknown default:
                fatalError()
                break
            }
        }
    }
}
extension PaymentViewController: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
