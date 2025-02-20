//
//  Constants.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-19.
//

struct Constants {

    static let instructions: [(image: String, title: String, description: String)] = [
        ("visible", "If an object is visible", "Simply tap on it to save its location."),
        ("behind", "If an object is behind something", "Tap anywhere on the object covering it to save the location."),
        ("inside", "If an object is inside something", "For drawers, boxes, or bags, tap on them to mark the object inside.")
    ]

    static let onBoardingSteps = [
        (title: "Welcome to Forget Me Not :)", description: "Use Augmented Reality to find things you forgot where you put them.", icon: "mappin.and.ellipse"),
        (title: "Save Position", description: "Tap on any object to save its location.", icon: "pin"),
        (title: "Locate Object", description: "Tap on the saved object to locate it.", icon: "magnifyingglass"),
        (title: "AR View", description: "Watch the AR guide you to the saved object!", icon: "camera.viewfinder"),
        (title: "You're All Set!", description: "Tap 'Start Exploring' to begin.", icon: "play.fill")
    ]

}
