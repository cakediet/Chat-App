//
//  FirebaseChannelListener.swift
//  Messenger
//
//  Created by Alex Feckanin on 6/28/22.
//

import Foundation
import Firebase

class FirebaseChannelListener {
    static let shared = FirebaseChannelListener()
    
    var channelListener: ListenerRegistration!
    
    private init () { }
    
    //MARK: - Fetching
    func downloadUserChannelsFromFirebase(completion: @escaping (_ allChannels: [Channel]) -> Void) {
        
        channelListener = FirebaseReference(collectionReference: .Channel).whereField(kADMINID, isEqualTo: User.currentID).addSnapshotListener({ (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents for user channels")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        })
    }
    
    func downloadSubscribedChannelsFromFirebase(completion: @escaping (_ allChannels: [Channel]) -> Void) {
        
        channelListener = FirebaseReference(collectionReference: .Channel).whereField(kMEMBERIDS, arrayContains: User.currentID).addSnapshotListener({ (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents for subscribed channels")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        })
    }
    
    func downloadAllChannelsFromFirebase(completion: @escaping (_ allChannels: [Channel]) -> Void) {
        
        FirebaseReference(collectionReference: .Channel).getDocuments{ (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("No documents for all channels")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            
            allChannels = self.removeSubscribedChannels(allChannels)
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        }
    }
    
    //MARK: - Add Update and Delete
    func saveChannel(_ channel: Channel) {
        do {
            try
            FirebaseReference(collectionReference: .Channel).document(channel.id).setData(from: channel)
        } catch {
            print("Error saving channel ", error.localizedDescription)
        }
    
    }
    
    func deleteChannel(_ channel: Channel) {
        FirebaseReference(collectionReference: .Channel).document(channel.id).delete()
    }
    
    //MARK: - Helpers
    func removeSubscribedChannels(_ allChannels: [Channel]) -> [Channel] {
        var newChannels: [Channel] = []
        
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentID){
                newChannels.append(channel)
            }
        }
        
        return newChannels
    }
    
    func removeChannelListener() {
        self.channelListener.remove()
    }
}
