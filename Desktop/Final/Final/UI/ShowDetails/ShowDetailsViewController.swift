import UIKit
import Kingfisher

final class ShowDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var showId: Int!

    private let tmdb = TMDBClient(apiKey: Secrets.tmdbApiKey)
    private var details: TMDBTVDetails?
    private var selectedSeason: Int = 1
    private var episodes: [TMDBEpisode] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        
        Task { await loadAll() }
    }


    @MainActor
    private func loadAll() async {
        guard let showId else { return }

        do {
            let d = try await tmdb.tvDetails(id: showId)
            self.details = d
            self.title = d.name

            let maxSeason = max(1, d.numberOfSeasons ?? 1)
            selectedSeason = min(max(selectedSeason, 1), maxSeason)

            let seasonData = try await tmdb.seasonDetails(showId: showId, seasonNumber: selectedSeason)
            self.episodes = seasonData.episodes

            tableView.reloadData()
        } catch {
            print("❌ ShowDetails load error:", error)
        }
    }

    @MainActor
    private func loadSeason(_ seasonNumber: Int) async {
        guard let showId else { return }

        do {
            selectedSeason = seasonNumber
            let seasonData = try await tmdb.seasonDetails(showId: showId, seasonNumber: seasonNumber)
            self.episodes = seasonData.episodes
            tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
        } catch {
            print("❌ Season load error:", error)
        }
    }

        // MARK: - Table

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : episodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsHeaderCell", for: indexPath) as! DetailsHeaderCell

            if let details {
                cell.configure(details: details, tmdb: tmdb, selectedSeason: selectedSeason)
                cell.onSeasonChanged = { [weak self] season in
                    guard let self else { return }
                    Task { await self.loadSeason(season) }
                }
            }
            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeCell", for: indexPath) as! EpisodeCell
        let ep = episodes[indexPath.row]

        let seasonNum = ep.seasonNumber == 0 ? selectedSeason : ep.seasonNumber
        let epNum = ep.episodeNumber

        cell.titleLabel.text = "S\(seasonNum)E\(epNum) • \(ep.name)"
        cell.overviewLabel.text = ep.overview ?? ""

        if let url = tmdb.imageURL(path: ep.stillPath) {
            cell.stillImageView.kf.setImage(with: url)
        } else {
            cell.stillImageView.image = nil
        }

        return cell
    }
    private func seasonProgress() -> Float {
        guard let showId else { return 0 }
        let total = episodes.count
        guard total > 0 else { return 0 }

        var watchedCount = 0
        for ep in episodes {
            let seasonNum = (ep.seasonNumber == 0) ? selectedSeason : ep.seasonNumber
            let key = EpisodeStore.shared.episodeKey(showId: showId, season: seasonNum, episode: ep.episodeNumber)
            if EpisodeStore.shared.isWatched(key) { watchedCount += 1 }
        }
        return Float(watchedCount) / Float(total)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        tableView.deselectRow(at: indexPath, animated: true)

        let ep = episodes[indexPath.row]

        let seasonNum = (ep.seasonNumber == 0) ? selectedSeason : ep.seasonNumber
        let epNum = ep.episodeNumber

        let vc = EpisodeDetailsViewController(showId: showId,
                                             season: seasonNum,
                                             episode: epNum)
        vc.showName = details?.name ?? ""
        vc.episodeName = ep.name
        vc.episodeOverview = ep.overview ?? ""
        vc.stillURL = tmdb.imageURL(path: ep.stillPath)

        navigationController?.pushViewController(vc, animated: true)
    }

}
