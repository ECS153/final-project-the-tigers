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
    let BackendUrl = "http://127.0.0.1:4242/"
    @IBOutlet weak var cardNumberLabel: UILabel!

    var scanStats: ScanStats?
    var number: String?
    var expiration: String?
    var name: String?
    var cardImage: UIImage?
    
    var paymentIntentClientSecret: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startCheckout()
        //self.cardNumberLabel.text = format(number: self.number ?? "")
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
        let url = URL(string: BackendUrl + "create-payment-intent")!
        let json: [String: Any] = [
            "currency": "usd",
            "items": [
                "id": "photo_subscription"
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
                let clientSecret = json["clientSecret"] as? String,
                let publishableKey = json["publishableKey"] as? String else {
                    let message = error?.localizedDescription ?? "Failed to decode response from server."
                    self?.displayAlert(title: "Error loading page", message: message)
                    return
            }
            print("Created PaymentIntent")
            self?.paymentIntentClientSecret = clientSecret
            // Configure the SDK with your Stripe publishable key so that it can make requests to the Stripe API
            // For added security, our sample app gets the publishable key from the server
            Stripe.setDefaultPublishableKey(publishableKey)
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
    
    @objc
    func pay() {
        guard let paymentIntentClientSecret = paymentIntentClientSecret else {
            return;
        }
        // Collect card details
        let cardParams = cardTextField.cardParams
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
