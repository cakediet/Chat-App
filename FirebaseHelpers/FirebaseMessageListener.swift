//
//  FirebaseMessageListener.swift
//  Messenger
//
//  Created by Alex Feckanin on 6/16/22.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseMessageListener {
    static let shared = FirebaseMessageListener()
    var newChatListener: ListenerRegistration!
    var updatedChatListener: ListenerRegistration!
    
    private init() { }
    
    func listenForNewChats(_ documentId: String, collectionId: String, lastMessageDate: Date) {
        
        newChatListener = FirebaseReference(collectionReference: .Messages).document(documentId).collection(collectionId).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (querySnapshot, error) in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                if change.type == .added {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                        switch result {
                        case .success(let messageObject):
                            if let message = messageObject {
                                
                                if message.senderId != User.currentID {
                                    RealmManager.shared.saveToRealm(message)
                                }
                            }else{
                                print("document does not exist")
                            }
                        case .failure(let error):
                            print("error decoding local message: , \(error.localizedDescription)")
                        }
                    }
                }
            })
        
    }
    
    func listenForReadStatusChange(_ documentId: String, collectionId: String, completion: @escaping (_ updatedMessage: LocalMessage) -> Void) {
        
        updatedChatListener = FirebaseReference(collectionReference: .Messages).document(documentId).collection(collectionId).addSnapshotListener({ (querySnapshot, error) in
            
            guard let snapshot = querySnapshot else { return }
            
            for change in snapshot.documentChanges {
                if change.type == .modified {
                    let result = Result {
                        try? change.document.data(as: LocalMessage.self)
                    }
                    
                    switch result {
                    case .success(let messageObject):
                        if let message = messageObject{
                            completion(message)
                        } else {
                            print("document does not exist in chat")
                        }
                    case .failure(let error):
                        print("error decoding local message ", error.localizedDescription)
                    }
                }
            }
        })
    }
    
    func checkForOldChats(_ documentId: String, collectionId: String){
        FirebaseReference(collectionReference: .Messages).document(documentId).collection(collectionId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for old chats")
                return
            }
            
            var oldMessages = documents.compactMap { (queryDocumentSnapshot) -> LocalMessage? in
                return try? queryDocumentSnapshot.data(as: LocalMessage.self)
                
            }
            oldMessages.sorted(by: { $0.date < $1.date})
            
            for message in oldMessages {
                RealmManager.shared.saveToRealm(message)
            }
        }
    }
    
    //MARK: - Add, update, delete
    
    func addMessage(_ message: LocalMessage, memberId: String){
        do {
            let _ = try FirebaseReference(collectionReference: .Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
        }
        catch{
            print("error saving message ", error.localizedDescription)
        }
    }
    
    func addChannelMessage(_ message: LocalMessage, channel: Channel){
        do {
            let _ = try FirebaseReference(collectionReference: .Messages).document(channel.id).collection(channel.id).document(message.id).setData(from: message)
        }
        catch{
            print("error saving message ", error.localizedDescription)
        }
    }
    
    //MARK: - UpdateMessageStatus
    func updateMessageInFirebase(_ message: LocalMessage, memberIds: [String]){
        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String : Any]
        
        for userId in memberIds {
            FirebaseReference(collectionReference: .Messages).document(userId).collection(message.chatRoomId).document(message.id).updateData(values)
        }
    }
    
    func removeListeners() {
        self.newChatListener.remove()
        
        if self.updatedChatListener != nil {
            self.updatedChatListener.remove()
        }
        
    }
}
