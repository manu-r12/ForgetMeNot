//
//  OnboardingView.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

import SwiftUI

struct OnboardingView: View {

    @Binding var showOnboarding: Bool

    @State private var currentStep = 0

    let steps = Constants.onBoardingSteps

    var body: some View {
        VStack {

            VStack {

                Text(steps[currentStep].title)
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding()
                    .minimumScaleFactor(0.5)
                    .lineLimit(3)

                Text(steps[currentStep].description)
                    .font(.title2)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                    .frame(height: 150)
                    .padding(.bottom, 20)
                    .lineLimit(3)


                Image(systemName: steps[currentStep].icon)
                    .font(.system(size: 100))
                    .padding(.bottom, 40)


                // Navigation buttons
                HStack {
                    if currentStep < steps.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentStep += 1
                            }
                        }) {
                            Text("Next")
                                .font(.headline)
                                .frame(width: 150)
                                .foregroundColor(.black)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                        }
                        .padding(.trailing, 10)
                    }

                    if currentStep == steps.count - 1 {
                        Button(action: {
                            showOnboarding = false
                        }) {
                            Text("Start Exploring")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.bottom, 30)

            }
            .padding()
            .frame(maxWidth: .infinity)
            .edgesIgnoringSafeArea(.all)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding()
        }
    }
}


#Preview {
    OnboardingView(showOnboarding: .constant(false))
}


