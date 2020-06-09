//
//  WelcomeViewController.swift
//  Seda
//
//  Created by Billy Chen on 5/11/20.
//  Copyright © 2020 Billy Chen. All rights reserved.
//

import UIKit
extension UIButton {

func applyGradient(colors: [CGColor]) {
    self.backgroundColor = nil
    self.layoutIfNeeded()
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = colors
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 0)
    gradientLayer.frame = self.bounds
    gradientLayer.cornerRadius = self.frame.height/2

    gradientLayer.shadowColor = UIColor.darkGray.cgColor
    gradientLayer.shadowOffset = CGSize(width: 2.5, height: 2.5)
    gradientLayer.shadowRadius = 5.0
    gradientLayer.shadowOpacity = 0.3
    gradientLayer.masksToBounds = false

    self.layer.insertSublayer(gradientLayer, at: 0)
    self.contentVerticalAlignment = .center
    self.setTitleColor(UIColor.white, for: .normal)
    self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
    self.titleLabel?.textColor = UIColor.white
    }
}
func UIColorFromRGB(_ rgbValue: Int) -> UIColor {
    return UIColor(red: ((CGFloat)((rgbValue & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((rgbValue & 0x00FF00) >> 8))/255.0, blue: ((CGFloat)((rgbValue & 0x0000FF)))/255.0, alpha: 1.0)
}
class WelcomeViewController: UIViewController {

    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        registerButton.applyGradient(colors: [UIColorFromRGB(0xFF512F).cgColor,UIColorFromRGB(0xEF4746).cgColor,UIColorFromRGB(0xDD2476).cgColor])
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
