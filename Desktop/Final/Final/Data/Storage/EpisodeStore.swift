import Foundation

final class EpisodeStore {
    static let shared = EpisodeStore()
    private init() {}

    private let defaults = UserDefaults.standard

    func episodeKey(showId: Int, season: Int, episode: Int) -> String {
        "watched_v1_\(showId)_s\(season)_e\(episode)"
    }

    func isWatched(_ key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    func setWatched(_ watched: Bool, for key: String) {
        defaults.set(watched, forKey: key)
    }

    func noteKey(showId: Int, season: Int, episode: Int) -> String {
        "note_v1_\(showId)_s\(season)_e\(episode)"
    }

    func saveNote(_ text: String, for key: String) {
        defaults.set(text, forKey: key)
    }

    func loadNote(for key: String) -> String {
        defaults.string(forKey: key) ?? ""
    }
}
