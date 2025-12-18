import UIKit
import Kingfisher

final class DetailsHeaderCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var showTitleLabel: UILabel!
    @IBOutlet weak var metaLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var seasonSegment: UISegmentedControl!

    var onSeasonChanged: ((Int) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none

        posterImageView.layer.cornerRadius = 16
        posterImageView.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill

        overviewLabel.numberOfLines = 0  // показываем весь текст
        seasonSegment.addTarget(self, action: #selector(seasonChanged), for: .valueChanged)
    }

    func configure(details: TMDBTVDetails, tmdb: TMDBClient, selectedSeason: Int) {
        showTitleLabel.text = details.name

        let year = details.firstAirDate.map { String($0.prefix(4)) } ?? ""
        let genre = details.genres?.first?.name ?? ""
        let rating = details.voteAverage.map { String(format: "%.1f", $0) } ?? ""

        metaLabel.text = [genre, year, rating.isEmpty ? "" : "★ \(rating)"]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")

        if let url = tmdb.imageURL(path: details.posterPath) {
            posterImageView.kf.setImage(with: url)
        } else {
            posterImageView.image = nil
        }

        rebuildSeasons(count: details.numberOfSeasons ?? 1, selected: selectedSeason)
    }

    private func rebuildSeasons(count: Int, selected: Int) {
        seasonSegment.removeAllSegments()
        let c = max(1, count)
        for i in 1...c {
            seasonSegment.insertSegment(withTitle: "S\(i)", at: i-1, animated: false)
        }
        seasonSegment.selectedSegmentIndex = max(0, min(c-1, selected-1))
    }

    @objc private func seasonChanged() {
        let season = seasonSegment.selectedSegmentIndex + 1
        onSeasonChanged?(season)
    }
}
