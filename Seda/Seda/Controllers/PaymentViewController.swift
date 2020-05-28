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
import FirebaseFunctions

class PaymentViewController: UIViewController {
    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    @IBOutlet weak var cardNumberLabel: UILabel!
    @IBOutlet weak var cashAmount: UITextField!
    @IBOutlet weak var expirationMonthTextField: UITextField!
    @IBOutlet weak var expirationYearTextField: UITextField!
    @IBOutlet weak var cvcTextField: UITextField!
    @IBOutlet weak var zipTextField: UITextField!
    let backendUrl = "https://us-central1-seda-63547.cloudfunctions.net/createPaymentIntent"
    var scanStats: ScanStats?
    var number: String?
    var expiration: String?
    var name: String?
    var expiryMonth: String?
    var expiryYear: String?
    var cardImage: UIImage?
    var cashToSend: String = "0.00"
    var paymentIntentClientSecret: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        //startCheckout()
        startCheckoutFirebase(with: backendUrl)
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
    
    func startCheckout() {
        // Request a PaymentIntent from your server and store its client secret
        // Create a PaymentIntent by calling the sample server's /create-payment-intent endpoint.
        
        let url = URL(string: backendUrl)!
        let json: [String: Any] = [
          "body": [
              ["amount": "100"],
              ["currency": "usd"]//TODO: CASHTOSEND should be taken from the UITextField, checked that it's a valid amount, and sent to our server
          ]
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        let task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data, response, error) in
          guard let response = response as? HTTPURLResponse,
            response.statusCode == 200,
            let data = data,
            let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
            let clientSecret = json["clientSecret"] as? String else {
                let message = error?.localizedDescription ?? "Failed to decode response from server."
                self?.displayAlert(title: "Error loading page", message: message)
                return
          }
          print("Created PaymentIntent")
          self?.paymentIntentClientSecret = clientSecret
            print("Set Client Secret")
            // Configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API
            // For added security, our sample app gets the publishable key from the server
            //Stripe.setDefaultPublishableKey(publishableKey)
        })
        task.resume()
    }
    
    
    func displayAlert(title: String, message: String, restartDemo: Bool = false) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if restartDemo {
                alert.addAction(UIAlertAction(title: "Restart demo", style: .cancel) { _ in
                    self.cardTextField.clear()
                    self.startCheckout()
                })
            }
            else {
                alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            }
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func startCheckoutFirebase(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
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
        let cardParams = cardTextField.cardParams
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
