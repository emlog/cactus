//
//  Item.swift
//  cactus
//
//  Created by 许大伟 on 2025/2/19.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
