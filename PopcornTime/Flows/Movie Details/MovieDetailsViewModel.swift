//
//  DetailViewModel.swift
//  PopcornTimetvOS SwiftUI
//
//  Created by Alexandru Tudose on 20.06.2021.
//  Copyright © 2021 PopcornTime. All rights reserved.
//

import Foundation
import PopcornKit
import AVKit

class MovieDetailsViewModel: ObservableObject {
    @Published var movie: Movie
    var error: Error?
    
    @Published var isLoading = false
    @Published var didLoad = false
    
    var trailerModel: TrailerButtonViewModel
    var downloadModel: DownloadButtonViewModel
    
    init(movie: Movie) {
        self.movie = movie
        self.trailerModel = TrailerButtonViewModel(movie: movie)
        self.downloadModel = DownloadButtonViewModel(media: movie)
    }
    
    func load() {
        guard !isLoading, !didLoad else {
            return
        }
        
        if movie.ratings == nil {
            Task { @MainActor in
                let info = try? await OMDbApi.shared.loadCachedInfo(imdbId: movie.id)
                if let info = info {
                    self.movie.ratings = info.transform()
                }
            }
        }
        
        isLoading = true
        Task { @MainActor in
            do {
                var movie = try await PopcornKit.getMovieInfo(movie.id)
                movie.ratings = self.movie.ratings
                movie.largeBackgroundImage = self.movie.largeBackgroundImage ?? movie.largeBackgroundImage //keep last background
                self.movie = movie
                self.downloadModel = DownloadButtonViewModel(media: movie)
                
                let group = DispatchGroup()
                group.enter()
                TraktManager.shared.getRelated(self.movie) {arg1,_ in
                    self.movie.related = arg1
                    group.leave()
                }
                
                group.enter()
                TraktManager.shared.getPeople(forMediaOfType: .movies, id: self.movie.id) {arg1,arg2,_ in
                    self.movie.actors = arg1
                    self.movie.crew = arg2
                    group.leave()
                }
                
                group.notify(queue: .main) {
                    self.didLoad = true
                }
            } catch {
                self.error = error
            }
            self.isLoading = false
        }
    }
    
    var backgroundUrl: URL? {
        return URL(string: movie.largeBackgroundImage ?? "")
    }
    
    func playSongTheme() {
        ThemeSongManager.shared.playMovieTheme(movie.title)
    }
    
    func stopTheme() {
        ThemeSongManager.shared.stopTheme()
    }
}
