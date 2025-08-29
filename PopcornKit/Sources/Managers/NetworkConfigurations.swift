import Foundation

public struct Trakt {
    static let apiKey = "d3b0811a35719a67187cba2476335b2144d31e5840d02f687fbf84e7eaadc811"
    static let apiSecret = "f047aa37b81c87a990e210559a797fd4af3b94c16fb6d22b62aa501ca48ea0a4"
    static let base = "https://api.trakt.tv"
    static let shows = "/shows"
    static let movies = "/movies"
    static let people = "/people"
    static let person = "/person"
    static let seasons = "/seasons"
    static let episodes = "/episodes"
    static let auth = "/oauth"
    static let token = "/token"
    static let sync = "/sync"
    static let playback = "/playback"
    static let history = "/history"
    static let device = "/device"
    static let code = "/code"
    static let remove = "/remove"
    static let related = "/related"
    static let watched = "/watched"
    static let watchlist = "/watchlist"
    static let scrobble = "/scrobble"
    static let imdb = "/imdb"
    static let tvdb = "/tvdb"
    static let search = "/search"
    
    static let extended = ["extended": "full"]
    public struct Headers {
        static let Default = [
            "Content-Type": "application/json",
            "trakt-api-version": "2",
            "trakt-api-key": Trakt.apiKey
        ]
        
        static func Authorization(_ token: String) -> [String: String] {
            var Authorization = Default; Authorization["Authorization"] = "Bearer \(token)"
            return Authorization
        }
    }
    public enum MediaType: String {
        case movies = "movies"
        case shows = "shows"
        case episodes = "episodes"
        case people = "people"
    }
    /**
     Watched status of media.
     
     - .watching:   When the video intially starts playing or is unpaused.
     - .paused:     When the video is paused.
     - .finished:   When the video is stopped or finishes playing on its own.
     */
    public enum WatchedStatus: String {
        /// When the video intially starts playing or is unpaused.
        case watching = "start"
        /// When the video is paused.
        case paused = "pause"
        /// When the video is stopped or finishes playing on its own.
        case finished = "stop"
    }
}

public struct TMDB {
    static let apiKey = "ac92176abc89a80e6f5df9510e326601"
    static let base = "https://api.themoviedb.org/3"
    static let tv = "/tv"
    static let person = "/person"
    static let images = "/images"
    static let season = "/season"
    static let episode = "/episode"
    static let videos = "/videos"
    
    public enum MediaType: String {
        case movies = "movie"
        case shows = "tv"
    }
    
    static let defaultHeaders = ["api_key": TMDB.apiKey, "language": "en"]
}

public struct Fanart {
    static let apiKey = "bd2753f04538b01479e39e695308b921"
    static let base = "http://webservice.fanart.tv/v3"
    static let tv = "/tv"
    static let movies = "/movies"
    
    static let defaultParameters = ["api_key": Fanart.apiKey]
}

public struct OpenSubtitles {
    static let base = "https://api.opensubtitles.com/api/v1/"
    static let userAgent = "Popcorn v1"
    static let apiKey = "ljnc55mUqXwU9OZcxC4Hf6ZqJ1WPVMIn"
    static let login = "login"
    static let logout = "logout"
    static let subtitles = "subtitles"
    static let download = "download"
    static let features = "features"
    static let userInfo = "infos/user"
    static let guessit = "utilities/guessit"
    
    // Discovery endpoints
    struct Discover {
        static let popular = "discover/popular"
        static let latest = "discover/latest"
        static let mostDownloaded = "discover/most_downloaded"
    }
    
    static let defaultHeaders = [
        "User-Agent": OpenSubtitles.userAgent,
        "Api-Key": apiKey,
        "Accept": "application/json"
    ]
    
    static func authenticatedHeaders(with bearerToken: String) -> [String: String] {
        var headers = defaultHeaders
        headers["Authorization"] = "Bearer \(bearerToken)"
        headers["Content-Type"] = "application/json"
        return headers
    }
}

//public struct OMDb {
//    static let apiKey = "19f23577"
//    static let base = "http://www.omdbapi.com"
//    static let info = "i"
//
//    static let defaultParameters = ["apikey": OMDb.apiKey]
//}

// cloudflare cached version of above
public struct OMDb {
    static let base = "https://reviews.randomrush.work"
    static let info = "i"
    
    static let defaultParameters: [String: String] = [:]
}

// cloudflare cached version of above
public struct DHT {
    static let base = "https://popcorn-dht.8mdm9hjd2h.workers.dev"
    
    static let defaultParameters: [String: String] = [:]
}


public struct Popcorn {
    static let base = "https://uxert.link"
    static let movies = "/movies"
    static let movie = "/movie"
    static let shows = "/shows"
    static let show = "/show"
    static let status = "/status"
    
    /// Possible orders used in API call.
    public enum Orders: Int {
        case ascending = 1
        case descending = -1
        
    }
    
    /// Possible filters used in API call.
    public enum Filters: String, CaseIterable {
        case popularity = "popularity"
        case year = "year"
        case date = "updated"
        case rating = "rating"
        case trending = "trending"
        
        public var string: String {
            switch self {
            case .popularity:
                return "Popular".localized
            case .year:
                return "New".localized
            case .date:
                return "Recently Added".localized
            case .rating:
                return "Top Rated".localized
            case .trending:
                return "Trending".localized
            }
        }
    }
    
    /// Possible genres used in API call.
    public enum Genres: String, Hashable, CaseIterable {
        case all = "All"
        case action = "Action"
        case adventure = "Adventure"
        case animation = "Animation"
        case comedy = "Comedy"
        case crime = "Crime"
//        case disaster = "Disaster"
        case documentary = "Documentary"
        case drama = "Drama"
        case family = "Family"
//        case fanFilm = "Fan Film"
        case fantasy = "Fantasy"
//        case filmNoir = "Film Noir"
        case history = "History"
//        case holiday = "Holiday"
        case horror = "Horror"
//        case indie = "Indie"
        case music = "Music"
        case mystery = "Mystery"
//        case road = "Road"
//        case romance = "Romance"
//        case sciFi = "Science Fiction"
//        case short = "Short"
//        case sports = "Sports"
//        case sportingEvent = "Sporting Event"
//        case suspense = "Suspense"
        case thriller = "Thriller"
        case war = "War"
        case western = "Western"
        
        public var string: String {
            return rawValue.localized
        }
    }
    
    struct APIError: Decodable, Error, LocalizedError {
        var message: String
        var code: Int
        
        public var errorDescription: String? {
            return "\(message) - \(code)"
        }
    }
}
