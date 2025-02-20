//
//  ARSearchItemViewContainer.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import ARKit
import RealityKit
import SwiftUI

struct ARSearchItemViewContainer: UIViewRepresentable {
    var arWorldMapId: ARItem

    func makeUIView(context: Context) -> ARView {
        print("Ar World - \(arWorldMapId)")
        return ARSearchItemViewController(
            arworldMapId: arWorldMapId
        )
    }

    func updateUIView(_ uiView: ARView, context: Context) {}
}
