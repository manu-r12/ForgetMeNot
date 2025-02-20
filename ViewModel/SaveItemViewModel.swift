//
//  SaveItemViewModel.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import Foundation
import UIKit
import ARKit

class SaveItemViewModel: ObservableObject {

    @Published var itemName: String = ""

    @Published var itemDescription: String = ""

    @Published var selectedImage: UIImage? = nil

    let persistenceManager: PersistenceManager

    init(persistenceManager: PersistenceManager){
        self.persistenceManager = persistenceManager
    }

    private func imageToData(_ image: UIImage, compressionQuality: CGFloat = 1.0) -> Data? {
        return image.jpegData(compressionQuality: compressionQuality) ?? image.pngData()
    }

    @MainActor
    func saveItem(with arWorldMap: String, refCapturedImage: UIImage, itemPos: SIMD3<Float>, name: String) -> ARItem? {

        guard let image = imageToData(refCapturedImage) else {return nil}

        guard let itemImage = selectedImage else {
            print("No Item Image")
            return nil
        }

        guard let itemImageData = imageToData(itemImage) else {
            return nil
        }

        let newARItem = ARItem(
            itemName: itemName,
            itemDescription: itemDescription,
            capturedImage: image,
            itemImage: itemImageData,
            arWorldMapId: arWorldMap,
            itemPosition: itemPos,
            anchorName: name
        )

        persistenceManager.saveItem(item: newARItem)
        print("Item Saved: \(newARItem)")

        return newARItem
    }


}

