//
//  Created by The Tigers on 6/7/20.
//

import Firebase
import Foundation

class Transaction {
    var amount: Double
    var sender: String
    var receiver: String
    var message: String
    
    init (amount: Double, sender: String, receiver: String, message: String) {
        self.amount = amount
        self.sender = sender
        self.receiver = receiver
        self.message = message
    }
}
