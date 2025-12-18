import UIKit
import Kingfisher

final class ShowCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!

    override func awakeFromNib() {
        super.awakeFromNib()
        posterImageView.contentMode = .scaleAspectFill
        posterImageView.clipsToBounds = true
        posterImageView.layer.cornerRadius = 10

        progressView.progress = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
    }
    func configure(title: String,
                       subtitle: String,
                       posterURL: URL?,
                       progress: Float) {

            titleLabel.text = title
            subtitleLabel.text = subtitle

            if let posterURL {
                posterImageView.kf.setImage(with: posterURL)
            } else {
                posterImageView.image = nil
            }

            let p = max(0, min(progress, 1))
            progressView.progress = p
        }
}
