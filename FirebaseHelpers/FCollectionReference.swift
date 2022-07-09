//
//  FCollectionReference.swift
//  Messenger
//
//  Created by Alex Feckanin on 5/30/22.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference: String {
    case User
    case Recent
    case Messages
    case Typing
    case Channel
}

func FirebaseReference( collectionReference: FCollectionReference) -> CollectionReference{
    
    return Firestore.firestore().collection(collectionReference.rawValue)
    
}
