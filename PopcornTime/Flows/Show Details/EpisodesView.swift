//
//  EpisodesView.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 19.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import SwiftUI
import PopcornKit
import Combine

struct EpisodesView: View {
    var show: Show
    var episodes: [Episode]
    var currentSeason: Int
    @State var currentEpisode: Episode? {
        didSet {
            downloadModel = currentEpisode.flatMap{ DownloadButtonViewModel(media: $0)}
        }
    }
    @State var downloadModel: DownloadButtonViewModel?
    
    @State var torrent: Torrent?
    @State var showPlayer = false
    
    var onFocus: () -> Void = {}
    
    var body: some View {
        return VStack(alignment: .leading) {
            navigationLink
                .hidden()
            titleView
            episodesCountView
            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(episodes, id: \.self) { episode in
                        #if os(tvOS)
                        SelectTorrentQualityButton(media: episode, action: { torrent in
                            self.torrent = torrent
                            self.currentEpisode = episode
                            showPlayer = true
                        }, label: {
                            EpisodeView(episode: episode)
                        }, onFocus: {
                            currentEpisode = episode
                            onFocus()
                        })
                        .frame(width: 310, height: 215)
                        #endif
                    }
                }
                .padding([.top, .bottom], 20) // allow zooming to be visible
                .padding(.leading, 90)
            }
            currentEpisodeView
        }
    }
    
    @ViewBuilder
    var titleView: some View {
        HStack {
            Spacer()
            Text(show.title)
                .font(.title2)
            Spacer()
        }
    }
    
    @ViewBuilder
    var navigationLink: some View {
        #if os(tvOS)
        if let torrent = torrent, let episode = currentEpisode {
            NavigationLink(destination: TorrentPlayerView(torrent: torrent, media: episode),
                           isActive: $showPlayer,
                           label: {
                EmptyView()
            })
        }
        #endif
    }
    
    @ViewBuilder
    var episodesCountView: some View {
        let localizedSeason = NumberFormatter.localizedString(from: NSNumber(value: currentSeason), number: .none)
        let seasonString = "Season".localized + " \(localizedSeason)"
        let count = episodes.count
        let isSingular = count == 1
        let numberOfEpisodes = "\(NumberFormatter.localizedString(from: NSNumber(value: count), number: .none)) \(isSingular ? "Episode".localized : "Episodes".localized)"
        
        Text("\(seasonString) (\(numberOfEpisodes.lowercased()))")
            .font(.callout)
            .foregroundColor(.init(white: 1.0, opacity: 0.667)) // light text color
            .padding(.leading, 90)
            .padding(.top, 14)
    }
    
    @ViewBuilder
    var currentEpisodeView: some View {
        if let episode = currentEpisode, let downloadModel = downloadModel {
            let airDateString = DateFormatter.localizedString(from: episode.firstAirDate, dateStyle: .medium, timeStyle: .none)
            let showGenre = episode.show?.genres.first?.localizedCapitalized.localized ?? ""
            let infoText = "\(airDateString) \n \(showGenre)"
            
            HStack() {
                VStack {
                    Text(infoText)
                        .font(.callout)
                        .multilineTextAlignment(.trailing)
                }
                VStack(alignment: .leading) {
                    Text("\(episode.episode). " + episode.title)
                        .font(.headline)
                    HStack {
                        Text(episode.summary)
                            .multilineTextAlignment(.leading)
//                            .lineLimit(6)
                            .padding(.bottom, 30)
//                            .frame(minWidth: 600, maxWidth: 800)
                            .frame(width: 800)
                        #if os(tvOS)
                        DownloadButton(viewModel: downloadModel)
                            .buttonStyle(TVButtonStyle(onFocus: onFocus))
                        #endif
                    }
//                    .background(Color.red)
                }
//                .background(Color.blue)
            }
            .padding(0)
            .frame(height: 350)
//            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing], 250)
//            .background(Color.gray)
        }
    }
}

struct EpisodesView_Previews: PreviewProvider {
    static var previews: some View {
        let show = Show.dummy()
        EpisodesView(show: show, episodes: show.episodes, currentSeason: 0, currentEpisode: show.episodes.first)
    }
}


struct FocusedEpisode: FocusedValueKey {
    typealias Value = Binding<Media>
}

extension FocusedValues {
    var episodeBinding: FocusedEpisode.Value? {
        get { self[FocusedEpisode.self] }
        set { self[FocusedEpisode.self] = newValue }
    }
}