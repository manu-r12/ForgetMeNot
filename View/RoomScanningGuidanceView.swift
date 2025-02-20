//
//  RoomScanningGuidanceView.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftUI

struct RoomScanningGuidanceView: View {

    @Binding var isPresented: Bool
    @AppStorage("hasShownRoomScanningGuidance") private var hasShownGuidance = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        if !hasShownGuidance {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismiss()
                    }

                VStack(spacing: 20) {
                    Image(systemName: "camera.metering.matrix")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("Scan Your Room")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("For better item recognition later, please scan the entire room by slowly moving your camera around. Once you've scanned the entire room, go ahead and save the item.")
                        .multilineTextAlignment(.center)
                        .font(.body)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "arrow.left")
                        Image(systemName: "iphone")
                            .font(.system(size: 30))
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.blue)

                    Button(action: dismiss) {
                        Text("You Got It? 😊")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top, 10)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(radius: 10)
                )
                .padding(20)
            }
            .ignoresSafeArea()
            .transition(.opacity)
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.2)) {
            hasShownGuidance = true
            isPresented = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}
