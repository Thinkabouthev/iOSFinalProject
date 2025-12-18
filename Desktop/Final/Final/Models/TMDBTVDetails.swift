import Foundation

struct TMDBGenre: Decodable {
    let id: Int
    let name: String
}

struct TMDBTVDetails: Decodable {
    let id: Int
    let name: String
    let overview: String?

    let posterPath: String?
    let firstAirDate: String?

    let numberOfSeasons: Int?
    let voteAverage: Double?
    let genres: [TMDBGenre]?
}
