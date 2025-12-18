import Foundation

final class BackendClient {
    static let shared = BackendClient()

    private let baseURL = URL(string: "http://127.0.0.1:8000")!

    private init() {}

    struct RecommendRequest: Codable {
        let likes: [String]
        let watching: [String]
        let finished: [String]
        let dislikes: [String]
        let mood: String?
        let limit: Int
    }

    struct RecommendItem: Codable {
        let title: String
        let why: String
        let tmdb_search_query: String
    }

    struct RecommendResponse: Codable {
        let items: [RecommendItem]
    }

    struct EpisodeNotesRequest: Codable {
        let showName: String
        let season: Int
        let episode: Int
        let episodeName: String?
        let overview: String?
        let userNotes: String?
    }

    struct EpisodeNotesResponse: Codable {
        let summary: String
        let key_points: [String]
        let questions: [String]
        let next_actions: [String]
    }

    // MARK: - Public

    func getEpisodeNotes(_ req: EpisodeNotesRequest) async throws -> EpisodeNotesResponse {
        try await post(path: "/ai/episode_notes", body: req, as: EpisodeNotesResponse.self)
        print("AI raw:", String(data: data, encoding: .utf8) ?? "nil")
    }

    func getRecommendations(_ req: RecommendRequest) async throws -> RecommendResponse {
        try await post(path: "/ai/recommendations", body: req, as: RecommendResponse.self)
    }

    // MARK: - Core

    private func post<T: Codable, R: Decodable>(path: String, body: T, as: R.Type) async throws -> R {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1

        if code < 200 || code >= 300 {
            let txt = String(data: data, encoding: .utf8) ?? "no body"
            throw NSError(domain: "Backend", code: code, userInfo: [NSLocalizedDescriptionKey: txt])
        }

        return try JSONDecoder().decode(R.self, from: data)
    }
}
