//
//  ARSaveItemViewContainer.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftUI
import RealityKit
import ARKit

struct ARSaveItemViewContainer: UIViewRepresentable {

    func makeUIView(context: Context) -> ARSaveItemViewController {
        return ARSaveItemViewController(frame: .zero)
    }

    func updateUIView(_ uiView: ARSaveItemViewController, context: Context) {}
}
