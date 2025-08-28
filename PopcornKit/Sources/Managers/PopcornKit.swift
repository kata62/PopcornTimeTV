
import Foundation

/**
 Load TV Shows from API.
 
 - Parameter page:       The page number to load.
 - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
 - Parameter genre:      Only return shows that match the provided genre.
 - Parameter searchTerm: Only return shows that match the provided string.
 - Parameter orderBy:    Ascending or descending.
 */
public func loadShows(
    _ page: Int = 1,
    filterBy filter: Popcorn.Filters = .popularity,
    genre: Popcorn.Genres = .all,
    searchTerm: String? = nil,
    orderBy order: Popcorn.Orders = .descending) async throws -> [Show] {
    return try await PopcornApi.shared.load(page, filterBy: filter, genre: genre, searchTerm: searchTerm, orderBy: order)
}

/**
 Get more show information.
 
 - Parameter imdbId:        The imdb identification code of the show.
 */
public func getShowInfo(_ imdbId: String) async throws -> Show {
    return try await PopcornApi.shared.getInfo(imdbId)
}


/**
 Load Movies from API.
 
 - Parameter page:       The page number to load.
 - Parameter filterBy:   Sort the response by Popularity, Year, Date Rating, Alphabet or Trending.
 - Parameter genre:      Only return movies that match the provided genre.
 - Parameter searchTerm: Only return movies that match the provided string.
 - Parameter orderBy:    Ascending or descending.
 */
public func loadMovies(
    _ page: Int = 1,
    filterBy filter: Popcorn.Filters = .popularity,
    genre: Popcorn.Genres = .all,
    searchTerm: String? = nil,
    orderBy order: Popcorn.Orders = .descending) async throws -> [Movie] {
    try await PopcornApi.shared.load(page, filterBy: filter, genre: genre, searchTerm: searchTerm, orderBy: order)
}

/**
 Get more movie information.
 
 - Parameter imdbId:        The imdb identification code of the movie.
 */
public func getMovieInfo(_ imdbId: String) async throws -> Movie {
    try await PopcornApi.shared.getInfo(imdbId)
}

/**
 Download torrent file from link.
 
 - Parameter path:          The path to the torrent file you would like to download.
 */
public func downloadTorrentFile(_ url: String) async throws -> URL {
    let request = URLRequest(url: URL(string: url)!)
    let (fileUrl, _) = try await URLSession.shared.download(for: request)
    return fileUrl
}

/**
 Download subtitle file from link.
 
 - Parameter path:              The path to the subtitle file you would like to download.
 - Parameter downloadDirectory: You can opt to change the download location of the file. Defaults to `NSTemporaryDirectory/Subtitles`.
 */
public func downloadSubtitleFile(_ url: String,
    downloadDirectory directory: URL = URL(fileURLWithPath: NSTemporaryDirectory())) async throws -> URL {
        let request = URLRequest(url: URL(string: url)!)
        let (fileUrl, response) = try await URLSession.shared.download(for: request)

        let fileName = response.suggestedFilename ?? UUID().uuidString
        let downloadDirectory = directory.appendingPathComponent("Subtitles")
        if !FileManager.default.fileExists(atPath: downloadDirectory.path) {
            try? FileManager.default.createDirectory(at: downloadDirectory, withIntermediateDirectories: true, attributes: nil)
        }
        
        let destinationUrl = downloadDirectory.appendingPathComponent(fileName)
        _ = try FileManager.default.replaceItemAt(destinationUrl, withItemAt: fileUrl)
        return destinationUrl
}

/**
 Download OpenSubtitles file using fileId and API v1 download endpoint
 
 - Parameter subtitle: The subtitle object containing fileId and fileName
 - Parameter downloadDirectory: Download location. Defaults to NSTemporaryDirectory/Subtitles
 - Returns: Local file URL of downloaded subtitle
 */
public func downloadOpenSubtitleFile(_ subtitle: Subtitle, downloadDirectory directory: URL = URL(fileURLWithPath: NSTemporaryDirectory())) async throws -> URL {
        
        // Get download URL from OpenSubtitles API
        let downloadUrl = try await SubtitlesApi.shared.downloadSubtitle(fileId: subtitle.fileId)
        
        // Download the file using the returned URL
        return try await downloadSubtitleFile(downloadUrl, downloadDirectory: directory)
}

public func serverURL() -> String {
    return Session.popcornBaseUrls ?? ""
}

public func setUserCustomUrls(newUrl: String?) async -> String {
    Session.popcornBaseUrls = newUrl
    if let userUrls = newUrl, !userUrls.isEmpty {
        if let url = await PopcornKit.getFirstLivePopcornURL(fromUrls: userUrls) {
            PopcornApi.changeBaseUrl(newUrl: url)
        }
        return userUrls
    } else {
        _ = await handleServerWasMoved()
        return Session.popcornBaseUrls ?? ""
    }
}

/// return if a live server is found
public func handleServerWasMoved() async -> Bool {
    // check if any server is up, from previus saved list
    if let appUrls = Session.popcornBaseUrls,
       let url = await PopcornKit.getFirstLivePopcornURL(fromUrls: appUrls) {
        PopcornApi.changeBaseUrl(newUrl: url)
        return true
    }
    
    if let endpoints = try? await DHTApi().loadEndpoints() {
        let urls = endpoints.server
        if urls == Session.popcornBaseUrls {
            return false // nothing to do, same urls as those found in DHT
        }
        
        Session.popcornBaseUrls = urls
        if let url = await PopcornKit.getFirstLivePopcornURL(fromUrls: urls) {
            PopcornApi.changeBaseUrl(newUrl: url)
            return true
        }
    }
    
    return false
}

/// get first url that is live from a list of separated by comma, by getting status
private func getFirstLivePopcornURL(fromUrls from: String) async -> String? {
    let urls = from.split(separator: ",").compactMap { URL(string: String($0)) }
    for url in urls {
        let statusURL = url.appendingPathComponent("status")
        if let _ = try? await URLSession.shared.data(from: statusURL) {
            var serverUrl = url.absoluteString
            if serverUrl.hasSuffix("/") {
                serverUrl = String(serverUrl.dropLast())
            }
            return serverUrl
        }
    }
    
    return nil
}
