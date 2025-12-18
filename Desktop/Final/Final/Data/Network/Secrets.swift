import Foundation

enum Secrets {
    static var tmdbApiKey: String {
        guard
            let url = Bundle.main.url(forResource: "Secret", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist["TMDB_API_KEY"] as? String
        else {
            fatalError("TMDB_API_KEY not found. Add it to Secret.plist")
        }
        return key
    }
    static var tmdbAccessToken: String {
        guard
            let url = Bundle.main.url(forResource: "Secret", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let token = plist["TMDB_ACCESS_TOKEN"] as? String,
            !token.isEmpty
        else {
            fatalError("TMDB_ACCESS_TOKEN not found in Secret.plist")
        }
        return token
    }
}
