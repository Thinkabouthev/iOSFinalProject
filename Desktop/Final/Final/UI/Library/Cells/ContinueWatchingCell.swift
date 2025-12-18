import UIKit
import Kingfisher

final class ContinueWatchingCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true

        posterImageView.layer.cornerRadius = 10
        posterImageView.clipsToBounds = true
        posterImageView.contentMode = .scaleAspectFill
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        progressView.progress = 0
    }

    func configure(title: String, subtitle: String, progress: Float, posterURL: URL?) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        progressView.progress = progress.isFinite ? max(0, min(1, progress)) : 0
        if let url = posterURL {
            posterImageView.kf.setImage(with: url)
        } else {
            posterImageView.image = nil
        }
    }
}
