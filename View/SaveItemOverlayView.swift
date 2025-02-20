//
//  SaveItemOverlayView.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftUI

struct SaveItemOverlayView: View {
    @ObservedObject var vm: SaveItemViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var showCamera = false
    let capturedImage: UIImage
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Save Item")
                    .font(.title)
                    .bold()

                // Show captured image first
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .cornerRadius(10)
                    .shadow(radius: 5)

                // Show text if a new image is selected
                if vm.selectedImage != nil {
                    Text("Item image selected! ✅")
                        .foregroundColor(.green)
                        .bold()
                }

                Button(action: {
                    showCamera = true
                }) {
                    Label("Take Photo Of Item", systemImage: "camera")
                }
                .buttonStyle(.bordered)

                TextField("Item Name", text: $vm.itemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)

                TextField("Description: Inside the drawer...", text: $vm.itemDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 20)

                Button {
                    dismiss()
                } label: {
                    Text("Save")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                }

                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.red)

            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal, 40)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $vm.selectedImage)
        }
    }


    private func dismiss() {
        onDismiss()
        presentationMode.wrappedValue.dismiss()
    }
}
