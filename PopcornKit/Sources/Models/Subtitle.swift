import Foundation
import ObjectMapper

/**
  Struct for managing subtitle objects.
 */
public struct Subtitle: Equatable, Mappable {
    
    /// Language string of the subtitle. Eg. English.
    public let language: String
    static let defaultLang = "Unknown"
    public let name: String
    
    /// File ID needed for download endpoint
    public let fileId: Int
    
    /// Original filename
    public let fileName: String
    
    /// Two letter ISO language code of the subtitle eg. en.
    public let ISO639: String
    
    /// The OpenSubtitles hash for the subtitle.
    internal var movieHash: OpenSubtitlesHash.VideoHash?
    
    public init?(map: Map) {
        do { self = try Subtitle(map) }
        catch { return nil }
    }
    
    private init(_ map: Map) throws {
        // Parse from new API v1 format - data is nested under "attributes"
        let attributes: [String: Any] = try map.value("attributes")
        
        // Get the release name
        self.name = attributes["release"] as? String ?? ""
        
        // Get language code
        let languageCode: String = attributes["language"] as? String ?? "en"
        self.ISO639 = languageCode
        
        // Convert language code to localized language name
        let subLanguage = Locale.current.localizedString(forLanguageCode: languageCode)?.localizedCapitalized
        self.language = subLanguage ?? Subtitle.defaultLang
        
        // Get file information from files array
        let files: [[String: Any]] = attributes["files"] as? [[String: Any]] ?? []
        if let firstFile = files.first {
            self.fileId = firstFile["file_id"] as? Int ?? 0
            self.fileName = firstFile["file_name"] as? String ?? ""
        } else {
            self.fileId = 0
            self.fileName = ""
        }
    }
    
    public mutating func mapping(map: Map) {
        switch map.mappingType {
        case .fromJSON:
            if let subtitle = Subtitle(map: map) {
                self = subtitle
            }
        case .toJSON:
            name >>> map["name"]
            language >>> map["language"]
            fileId >>> map["fileId"]
            fileName >>> map["fileName"]
            ISO639 >>> map["ISO639"]
            movieHash >>> map["movieHash"]
        }
    }
    
    public init(name: String, language: String, fileId: Int, fileName: String, ISO639: String, movieHash: OpenSubtitlesHash.VideoHash? = nil) {
        self.name = name
        self.language = language
        self.fileId = fileId
        self.fileName = fileName
        self.ISO639 = ISO639
        self.movieHash = movieHash
    }
}
