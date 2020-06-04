//
//  Created by Ryland Sepic on 6/3/20.
//

import Foundation

class Request {
    var name:String
    var docID:String
    var friend_pub_key:String
    
    init(name: String, _ doc: String, _ friend_pub_key: String) {
        self.name = name
        self.docID = doc
        self.friend_pub_key = friend_pub_key
    }
}
