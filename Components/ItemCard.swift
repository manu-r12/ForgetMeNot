//
//  ItemCard.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftUI

struct ItemCard: View {
    
    let item: ARItem

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Image
            if let uiImage = UIImage(data: item.itemImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 140)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(height: 140)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    )
            }

            // Item Info
            VStack(alignment: .leading, spacing: 4) {
                Text(item.itemName)
                    .font(.headline)
                    .lineLimit(1)

            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

