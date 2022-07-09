//
//  Channel.swift
//  Messenger
//
//  Created by Alex Feckanin on 6/27/22.
//

import Foundation
import FirebaseFirestoreSwift
import Firebase

struct Channel: Codable {
    
    var id = ""
    var name = ""
    var adminID = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    @ServerTimestamp var createdDate = Date()
    @ServerTimestamp var lastMessageDate = Date()
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case adminID
        case memberIds
        case avatarLink
        case aboutChannel
        case createdDate
        case lastMessageDate = "date"
    }
    
}
