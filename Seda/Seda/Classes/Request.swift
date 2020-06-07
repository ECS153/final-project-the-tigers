//
//  Created by Ryland Sepic on 6/3/20.
//

import Foundation

class Request {
    var name:String
    var docID:String
    var friend_pub_key:String
    var s_or_r: Bool
    
    init(name: String, _ doc: String, _ friend_pub_key: String, _ s_or_r: Bool) {
        self.name = name
        self.docID = doc
        self.friend_pub_key = friend_pub_key
        self.s_or_r = s_or_r
    }
}
