//
//  PlayerAudioController.swift
//  PlayerAudioController
//
//  Created by Alexandru Tudose on 26.08.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import SwiftUI
#if os(tvOS)
import TVVLCKit
#elseif os(iOS)
import MobileVLCKit
#elseif os(macOS)
import VLCKit
#endif
import AVKit

class PlayerAudioModel {
    private(set) var mediaplayer: VLCMediaPlayer
    var audioProfile: EqualizerProfiles = .fullDynamicRange
    var audioProfileBinding: Binding<EqualizerProfiles> = .constant(.fullDynamicRange)
    var audioDelayBinding: Binding<Int> = .constant(0)
    
    var audioTracksNames: () -> [String] = { return [] }
    var audioTrackBinding: Binding<Int> = .constant(0)
    
    init(mediaplayer: VLCMediaPlayer) {
        self.mediaplayer = mediaplayer
        mediaplayer.currentAudioPlaybackDelay = 0
        audioTracksNames = { mediaplayer.audioTrackNames.map({ $0 as! String }) }
        
        audioDelayBinding = Binding(get: {
            mediaplayer.currentAudioPlaybackDelay / 1_000_000 // from microseconds to seconds
        }, set: { newDelay in
            mediaplayer.currentAudioPlaybackDelay = newDelay * 1_000_000
        })
        
        audioProfileBinding = Binding(get: { [unowned self] in
            return audioProfile
        }, set: { [unowned self] profile in
            audioProfile = profile
            didSelectEqualizerProfile(profile)
        })
        
        audioTrackBinding = Binding(get: {
            return Int(mediaplayer.currentAudioTrackIndex)
        }, set: { trackIndex in
            mediaplayer.currentAudioTrackIndex = Int32(trackIndex)
        })
        
        #if os(iOS) || os(tvOS)
        try? AVAudioSession.sharedInstance().setActive(false)
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        didSelectEqualizerProfile(.fullDynamicRange)
        #endif
    }
    
    func didSelectEqualizerProfile(_ profile: EqualizerProfiles) {
        mediaplayer.resetEqualizer(fromProfile: profile.rawValue)
        mediaplayer.equalizerEnabled = true
    }
}
