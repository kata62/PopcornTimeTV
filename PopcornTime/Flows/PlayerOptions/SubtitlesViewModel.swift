//
//  SubtitlesViewModel.swift
//  SubtitlesViewModel
//
//  Created by Alexandru Tudose on 06.09.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import SwiftUI
import PopcornKit

class SubtitlesViewModel: ObservableObject {
    
    let delays = (-60..<60)
    var subtitles = Dictionary<String, [Subtitle]>()
    let encodings = SubtitleSettings.encodings
    var encodingsKeys: [String] = Array(SubtitleSettings.encodings.keys.sorted())
    
    @Published var subtitlesInView: [Subtitle] = []
    let enLocale = Locale.current.localizedString(forLanguageCode: "en")!
    let selectOther = "Select Other".localized
    
    init(subtitles: Dictionary<String, [Subtitle]> = [:]) {
        self.subtitles = subtitles
    }
    
    func delayText(delay: Int) -> String {
        return (delay > 0 ? "+" : "") + NumberFormatter.localizedString(from: NSNumber(value: delay), number: .decimal)
    }
    
    func generateSubtitles(currentSubtitle: Subtitle?) -> [Subtitle] {
        var newSubtitles = [currentSubtitle ?? subtitles[enLocale.localizedCapitalized]?.first ?? subtitles[subtitles.keys.first!]!.first!,
                            Subtitle(name: "", language: selectOther, fileId:0, fileName: "", ISO639: "")]//insert predetermined subtitle or english or first available whichever exists
        for unknownSubtitle in SubtitleSettings.shared.subtitlesSelectedForVideo {
            if let subtitle = unknownSubtitle as? Subtitle {
                if !newSubtitles.contains(subtitle){
                    newSubtitles.insert(subtitle, at: 0)
                }
            }
        }
        
        return newSubtitles
    }
    
    func didSelectSubtitle(_ subtitle: Subtitle?) {
        guard let subtitle = subtitle else {
            return
        }

        for i in 0..<SubtitleSettings.shared.subtitlesSelectedForVideo.count {
            if let savedSubtitle = SubtitleSettings.shared.subtitlesSelectedForVideo[i] as? Subtitle{
                if savedSubtitle.language == subtitle.language{// do we have a sub with the same language in permanent storage
                    SubtitleSettings.shared.subtitlesSelectedForVideo.replaceSubrange(i...i, with: [subtitle as Any])//replace the one we have with the latest one
                    let index = subtitlesInView.firstIndex(of: savedSubtitle)!
                    subtitlesInView[index] = subtitle
                    return
                }
            }
        }
        
        if !subtitlesInView.contains(subtitle){// does the subtitlesinview already have our sub if no enter
            for savedSubtitle in subtitlesInView{
                if subtitle.language == savedSubtitle.language{// do we have a sub with the same language
                    let index = subtitlesInView.firstIndex(of: savedSubtitle)!
                    subtitlesInView[index] = subtitle//switch out the one with the same language with our latest one
                    SubtitleSettings.shared.subtitlesSelectedForVideo.append(subtitle as Any)//add it to our permanent list
                    break
                }
                if savedSubtitle == subtitlesInView.last{//if we do not have a sub with the same language
                    subtitlesInView.insert(subtitle, at: 0) //add the latest selected
                    SubtitleSettings.shared.subtitlesSelectedForVideo.append(subtitle as Any)
                }
            }
        } else {// we have the sub in the subtitlesinview but not in permanent storage
            SubtitleSettings.shared.subtitlesSelectedForVideo.append(subtitle as Any)
        }
    }
    
}
