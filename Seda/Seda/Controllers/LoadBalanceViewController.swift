//
//  LoadBalanceViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/31/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit

class LoadBalanceViewController: UIViewController {

    @IBOutlet weak var LoadTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadTextField.text = ""
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loadBalancePressed(_ sender: UIButton) {
        if let LoadTextField = LoadTextField.text{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let addMoneyVC = storyboard.instantiateViewController(identifier: "CardScanVC") as! ScanCardViewController
            self.navigationController?.pushViewController(addMoneyVC, animated: true)
            addMoneyVC.cashToSend = LoadTextField
        }
        
    }
    
}
