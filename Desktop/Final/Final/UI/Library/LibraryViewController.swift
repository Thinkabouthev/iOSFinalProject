import UIKit
import Kingfisher

final class LibraryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!

    private let tmdb = TMDBClient(apiKey: Secrets.tmdbApiKey)
    private let store = LibraryStore()

    private var allLibraryShows: [LibraryShow] = []
    private var visibleLibraryShows: [LibraryShow] = []
    private var currentSearchText: String = ""
    private var currentSegment: Int = 0 // 0 all, 1 watching, 2 finished, 3 plan

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
       

        reloadLibrary()
    }

    private func reloadLibrary() {
        allLibraryShows = store.load()
        applyFilters()
        tableView.reloadData()
    }

    private func applyFilters() {
        var list = allLibraryShows

            // segment
        switch currentSegment {
        case 1: list = list.filter { $0.status == .watching }
        case 2: list = list.filter { $0.status == .finished }
        case 3: list = list.filter { $0.status == .plan }
        default: break
    }

            // search
        let q = currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !q.isEmpty {
            list = list.filter { $0.name.lowercased().contains(q.lowercased()) }
        }

        visibleLibraryShows = list
    }

        // MARK: Table

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : visibleLibraryShows.count
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as! LibraryHeaderCell

            cell.onSearchChanged = { [weak self] text in
                self?.currentSearchText = text
                self?.applyFilters()
                self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }

            cell.onAddTapped = { [weak self] in
                self?.openAddFlow()
            }

            cell.onSegmentChanged = { [weak self] idx in
                self?.currentSegment = idx
                self?.applyFilters()
                self?.tableView.reloadSections(IndexSet(integer: 1), with: .automatic)
            }


            let continueItems: [LibraryHeaderCell.ContinueItem] = visibleLibraryShows.map { s in
            let total = max(1, s.totalEpisodes)
            let watched = max(0, s.watchedEpisodes)
            let progress = Float(watched) / Float(total)

            return .init(
                showId: s.id,
                title: s.name,
                subtitle: s.status == .watching ? "Watching" : "Not started",
                posterPath: s.posterPath,
                progress: progress
            )
        }

            cell.configureContinue(
            items: continueItems,
            makePosterURL: { [weak self] path in self?.tmdb.imageURL(path: path) }
            )

            return cell
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowCell", for: indexPath) as! ShowCell
        let item = visibleLibraryShows[indexPath.row]

        cell.titleLabel.text = item.name
        cell.subtitleLabel.text = item.subtitle
        cell.progressView.progress = item.progress

        if let url = tmdb.imageURL(path: item.posterPath) {
                cell.posterImageView.kf.setImage(with: url)
        } else {
            cell.posterImageView.image = nil
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }

        let item = visibleLibraryShows[indexPath.row]

        let vc = storyboard?.instantiateViewController(withIdentifier: "ShowDetailsViewController") as! ShowDetailsViewController
        vc.showId = item.id
        navigationController?.pushViewController(vc, animated: true)
        print("NAV!!!!!!!!!!!!!:", navigationController as Any)
    }


    private func openAddFlow() {
        let alert = UIAlertController(title: "Add show", message: "Search TMDB", preferredStyle: .alert)
        alert.addTextField { tf in tf.placeholder = "e.g. Stranger Things" }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        alert.addAction(UIAlertAction(title: "Search", style: .default, handler: { [weak self] _ in
            guard let self else { return }
            let q = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !q.isEmpty else { return }

            Task {
                do {
                    let results = try await self.tmdb.searchTV(query: q)
                    await MainActor.run {
                        self.presentPickResult(results)
                    }
                } catch {
                    print("TMDB search error:", error)
                }
            }
        }))

        present(alert, animated: true)
    }

    private func presentPickResult(_ results: [TMDBTVShow]) {
        let sheet = UIAlertController(title: "Pick a show", message: nil, preferredStyle: .actionSheet)
        for show in results.prefix(8) {
            sheet.addAction(UIAlertAction(title: show.name, style: .default, handler: { [weak self] _ in
                guard let self else { return }
                self.store.upsertFromTMDB(id: show.id, name: show.name, posterPath: show.posterPath)
                self.reloadLibrary()
            }))
        }

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        if let pop = sheet.popoverPresentationController {
            pop.sourceView = self.view
            pop.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 1, height: 1)
        }

        present(sheet, animated: true)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyFilters()
        tableView.reloadData()
    }
}
