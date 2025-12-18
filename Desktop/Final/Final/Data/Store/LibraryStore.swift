import Foundation

enum ShowStatus: String, Codable {
    case plan
    case watching
    case finished
}

struct LibraryShow: Codable, Equatable {
    let id: Int
    var name: String
    var posterPath: String?
    var status: ShowStatus
    var watchedEpisodes: Int
    var totalEpisodes: Int

    var progress: Float {
        guard totalEpisodes > 0 else { return 0 }                
        return Float(watchedEpisodes) / Float(totalEpisodes)
    }

    var subtitle: String {
        totalEpisodes > 0 ? "\(watchedEpisodes) / \(totalEpisodes) episodes watched" : "Not started"
    }
}

final class LibraryStore {
    private let key = "library_shows_v1"
    private let defaults = UserDefaults.standard

    func load() -> [LibraryShow] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([LibraryShow].self, from: data)) ?? []
    }

    func save(_ shows: [LibraryShow]) {
        let data = try? JSONEncoder().encode(shows)
        defaults.set(data, forKey: key)
    }

    func upsertFromTMDB(id: Int, name: String, posterPath: String?) {
        var list = load()
        if let idx = list.firstIndex(where: { $0.id == id }) {
            list[idx].name = name
            list[idx].posterPath = posterPath
        } else {
            list.append(.init(id: id, name: name, posterPath: posterPath, status: .plan, watchedEpisodes: 0, totalEpisodes: 0))
        }
        save(list)
    }

    func updateStatus(id: Int, status: ShowStatus) {
        var list = load()
        guard let idx = list.firstIndex(where: { $0.id == id }) else { return }
        list[idx].status = status
        save(list)
    }

    func remove(id: Int) {
        var list = load()
        list.removeAll { $0.id == id }
        save(list)
    }
}
