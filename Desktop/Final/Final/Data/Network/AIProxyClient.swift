import Foundation

final class AIProxyClient {
    // TODO: когда появится backend:
    // POST /ai/summary {showName, season, episode, notes} -> {summary}
    func summarizeEpisode(showName: String, season: Int, episode: Int, notes: String) async throws -> String {
        return "AI Summary placeholder.\nShow: \(showName)\nS\(season)E\(episode)\nNotes: \(notes.prefix(120))"
    }
}
