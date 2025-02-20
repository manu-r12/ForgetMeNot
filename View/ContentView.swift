import SwiftUI

struct ContentView: View {

    @AppStorage("hasCompletedOnboarding") private var showOnboarding = true

    var body: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            HomeView()
        }
    }
}
