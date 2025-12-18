import Foundation

struct TMDBPagedResponse<T: Decodable>: Decodable {
    let results: [T]
}
