//
//  InstructionView.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftUI

struct InstructionView: View {

    @Binding var showInstructions: Bool
    @State private var currentIndex = 0
    
    var didFinish: () -> Void

    var instructions = Constants.instructions

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Safe area spacer
                Color.clear
                    .frame(height: geometry.safeAreaInsets.top)

                ScrollView {
                    VStack(spacing: 24) {

                        // Main Title with proper spacing
                        Text("How to Save an Object")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 32)
                            .padding(.bottom, 16)

                        // TabView Container
                        TabView(selection: $currentIndex) {
                            ForEach(0..<instructions.count, id: \.self) { index in
                                VStack(alignment: .center, spacing: 24) {

                                    // Image Container
                                    ZStack {
                                        Circle()
                                            .fill(Color.gray.opacity(0.1))
                                            .frame(width: 200, height: 200)

                                        Image(instructions[index].image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 160, height: 160)
                                    }
                                    .padding(.top, 20)


                                    // Content Container
                                    VStack(spacing: 16) {
                                        Text(instructions[index].title)
                                            .font(.system(size: 24, weight: .semibold))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.center)

                                        Text(instructions[index].description)
                                            .font(.system(size: 18))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)

                                        Text(getExampleText(for: index))
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                            .multilineTextAlignment(.center)
                                            .padding(.top, 4)
                                    }
                                    .padding(.horizontal, 32)

                                    Spacer(minLength: 40)

                                    // Button Container
                                    VStack {
                                        Button(action: {
                                            if currentIndex < instructions.count - 1 {
                                                withAnimation {
                                                    currentIndex += 1
                                                }
                                            } else {
                                                showInstructions = false
                                                didFinish()
                                            }
                                        }) {
                                            Text(currentIndex < instructions.count - 1 ? "Next" : "Continue to AR Mode")
                                                .font(.system(size: 18, weight: .semibold))
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 18)
                                                .background(Color.green)
                                                .cornerRadius(16)
                                        }
                                    }
                                    .padding(.horizontal, 32)
                                    .padding(.bottom, 32)
                                }
                                .frame(width: geometry.size.width)
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                        .frame(height: geometry.size.height - 100)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
    }

    private func getExampleText(for index: Int) -> String {
        switch index {
        case 0:
            return "Example: Tap on the visible object, like a cup, to save its location."
        case 1:
            return "Example: If the key is behind a book, tap the book to save the key's location."
        case 2:
            return "Example: If the phone is inside a drawer, tap the drawer to mark the phone's location."
        default:
            return ""
        }
    }
}
