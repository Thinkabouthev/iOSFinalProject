import Foundation

struct ContinueItem: Codable, Equatable {
    let showId: Int
    let title: String
    let subtitle: String
    let progress: Float
    let imagePath: String?  
}
