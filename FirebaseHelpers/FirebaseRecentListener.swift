//
//  FirebaseRecentListener.swift
//  Messenger
//
//  Created by Alex Feckanin on 6/13/22.
//

import Foundation
import Firebase

class FirebaseRecentListener {
    static let shared = FirebaseRecentListener()
    
    private init() {}
    
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {
        FirebaseReference(collectionReference: .Recent).whereField(kSENDERID, isEqualTo: User.currentID).addSnapshotListener { (querySnapshot, error) in
            
            var recentChats: [RecentChat] = []
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent chats")
                return
            }
            
            let allRecents = documents.compactMap { (QueryDocumentSnapshot) ->
                RecentChat? in
                
                return try? QueryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: {$0.date! > $1.date! })
            completion(recentChats)
            
        }
    }
    
    func resetRecentCounter(chatRoomId: String){
        FirebaseReference(collectionReference: .Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentID).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no documents for recent")
                return
            }
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!)
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String){
        FirebaseReference(collectionReference: .Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnaphot, error) in
            
            guard let documents = querySnaphot?.documents else {
                print("no documents for recent update")
                return
            }
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
            
        }
    }
    
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String){
        var tempRecent = recent
        
        if tempRecent.senderId != User.currentID {
            tempRecent.unreadCounter += 1
        }
        
        tempRecent.lastMessage = lastMessage
        tempRecent.date = Date()
        
        self.saveRecent(tempRecent)
    }
    
    func clearUnreadCounter(recent: RecentChat){
        var newRecent = recent
        newRecent.unreadCounter = 0
        
        self.saveRecent(newRecent)
    }
    
    func saveRecent(_ recent: RecentChat) {
        do {
            try FirebaseReference(collectionReference: .Recent).document(recent.id).setData(from: recent)
        }
        catch{
            print("error saving recent chat", error.localizedDescription)
        }
        
    }
    
    func deleteRecent(_ recent: RecentChat){
        FirebaseReference(collectionReference: .Recent).document(recent.id).delete()
    }
}
