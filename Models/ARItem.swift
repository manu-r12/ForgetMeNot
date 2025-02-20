//
//  ARItem.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftData
import Foundation

@Model
class ARItem {
    var anchorName: String
    var itemName: String
    var itemDescription: String
    var capturedImage: Data
    var itemImage: Data
    var arWorldMapId: String
    var positionX: Float
    var positionY: Float
    var positionZ: Float

    init(
        itemName: String,
        itemDescription: String,
        capturedImage: Data,
        itemImage: Data,
        arWorldMapId: String,
        itemPosition: SIMD3<Float>,
        anchorName: String
    ) {
        self.anchorName = anchorName
        self.itemName = itemName
        self.itemDescription = itemDescription
        self.capturedImage = capturedImage
        self.itemImage = itemImage
        self.arWorldMapId = arWorldMapId
        self.positionX = itemPosition.x
        self.positionY = itemPosition.y
        self.positionZ = itemPosition.z
    }

    var itemPosition: SIMD3<Float> {
        get { SIMD3<Float>(positionX, positionY, positionZ) }
        set {
            positionX = newValue.x
            positionY = newValue.y
            positionZ = newValue.z
        }
    }
}
