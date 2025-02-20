//
//  ARSearchItemView.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftUI

struct ARSearchItemView: View {

    let arItem: ARItem

    init(id: ARItem) {
        self.arItem = id
        print("From  ARSearchItemView  ID - \(arItem)")
    }

    var body: some View {
        ZStack {
            ARSearchItemViewContainer(arWorldMapId: arItem)
                .edgesIgnoringSafeArea(.all)
        }
    }
}


