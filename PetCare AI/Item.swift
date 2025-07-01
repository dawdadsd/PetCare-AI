//
//  Item.swift
//  PetCare AI
//
//  Created by 徐北游 on 2025/7/1.
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
