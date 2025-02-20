//
//  ARSearchItemViewController+PlayMatchSound.swift
//  ForgotMeNot
//
//  Created by Manu on 2025-02-20.
//

import AVFoundation
import UIKit

// Play a sound once the ar item is found
extension ARSearchItemViewController {

    func setupSoundPlayer() {
        
        guard let path = Bundle.main.path(forResource: "found", ofType: "wav") else {
            print("❌ Sound file not found in bundle. Make sure it's in Resources!")
            return
        }

        let soundURL = URL(fileURLWithPath: path)

        do {
            soundPlayer = try AVAudioPlayer(contentsOf: soundURL)
            soundPlayer?.prepareToPlay()
        } catch {
            print("❌ Failed to setup sound player: \(error)")
        }
    }

    func playMatchSound() {
        if soundPlayer == nil {
            setupSoundPlayer()
        }

        soundPlayer?.volume = 0.7
        soundPlayer?.play()
    }

}
