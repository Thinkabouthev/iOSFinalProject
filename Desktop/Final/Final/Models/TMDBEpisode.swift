import Foundation

struct TMDBEpisode: Decodable {
    let episodeNumber: Int
    let seasonNumber: Int
    let name: String
    let overview: String?
    let stillPath: String?
}
