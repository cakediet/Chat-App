//
//  PhotoMessage.swift
//  Messenger
//
//  Created by Alex Feckanin on 6/24/22.
//

import Foundation
import MessageKit
import UIKit

class PhotoMessage: NSObject, MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
    }
}
