import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case http(code: Int, body: String?)
}

final class TMDBClient {
    private let apiKey: String?
    private let accessToken: String?
    private let session: URLSession
    private let baseURL = URL(string: "https://api.themoviedb.org/3")!

    init(apiKey: String? = nil, accessToken: String? = nil, session: URLSession = .shared) {
        self.apiKey = apiKey
        self.accessToken = accessToken
        self.session = session
    }

    // MARK: - Public endpoints

    func trendingTV() async throws -> [TMDBTVShow] {
        let res: TMDBPagedResponse<TMDBTVShow> = try await fetch(
            path: "/trending/tv/day",
            query: []
        )
        return res.results
    }

    func searchTV(query q: String) async throws -> [TMDBTVShow] {
        let res: TMDBPagedResponse<TMDBTVShow> = try await fetch(
            path: "/search/tv",
            query: [URLQueryItem(name: "query", value: q)]
        )
        return res.results
    }

    func tvDetails(id: Int) async throws -> TMDBTVDetails {
        try await fetch(path: "/tv/\(id)", query: [])
    }

    func seasonDetails(showId: Int, seasonNumber: Int) async throws -> TMDBSeasonDetails {
        try await fetch(path: "/tv/\(showId)/season/\(seasonNumber)", query: [])
    }

    func imageURL(path: String?) -> URL? {
        guard let path, !path.isEmpty else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    // MARK: - Core fetch

    private func fetch<T: Decodable>(path: String, query: [URLQueryItem]) async throws -> T {
        var comps = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        var items = query
        items.append(URLQueryItem(name: "language", value: "en-US"))

        if accessToken == nil || accessToken?.isEmpty == true {
            if let apiKey, !apiKey.isEmpty {
                items.append(URLQueryItem(name: "api_key", value: apiKey))
            }
        }
        comps.queryItems = items

        let url = comps.url!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // если есть Bearer-токен — используем его (это то, что тебе сейчас спасёт ситуацию)
        if let token = accessToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)
        let code = (response as? HTTPURLResponse)?.statusCode ?? -1


        print("TMDB status:", code, url.absoluteString)
        if code != 200 {
            print("TMDB body:", String(data: data, encoding: .utf8) ?? "no body")
            throw TMDBError.http(code: code, body: String(data: data, encoding: .utf8))
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}

enum TMDBError: Error {
    case http(code: Int, body: String?)
}
