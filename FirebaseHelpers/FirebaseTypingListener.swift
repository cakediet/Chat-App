//
//  FirebaseTypingListener.swift
//  Messenger
//
//  Created by Alex Feckanin on 6/19/22.
//

import Foundation
import Firebase


class FirebaseTypingListener {
    static let shared = FirebaseTypingListener()
    var typingListener: ListenerRegistration!
    
    private init() { }
    
    func createTypingObsever(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        
        typingListener = FirebaseReference(collectionReference: .Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != User.currentID {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                FirebaseReference(collectionReference: .Typing).document(chatRoomId).setData([User.currentID : false])
            }
        })
    }
    class func saveTypingCounter(typing: Bool, chatRoomId: String){
        FirebaseReference(collectionReference: .Typing).document(chatRoomId).updateData([User.currentID : typing])
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
}
