//
//  VideoMessage.swift
//  Messenger
//
//  Created by Alex Feckanin on 6/24/22.
//

import Foundation
import MessageKit

class VideoMessage: NSObject, MediaItem {
    var url: URL?
    
    var image: UIImage?
    
    var placeholderImage: UIImage
    
    var size: CGSize
    
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
    }
}
