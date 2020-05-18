//
//  ProfileViewController.swift
//  Seda
//
//  Created by Ryland Sepic on 5/17/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import Foundation

import UIKit

class ProfileViewController: UIViewController {

  
    @IBOutlet weak var balance: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func add_money(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let addMoneyVC = storyboard.instantiateViewController(identifier: "CardScanVC") as! ScanCardViewController
        
        self.navigationController?.pushViewController(addMoneyVC, animated: true)
    }
}
