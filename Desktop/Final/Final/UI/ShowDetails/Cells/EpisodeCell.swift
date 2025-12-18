import UIKit
import Kingfisher

final class EpisodeCell: UITableViewCell {
    @IBOutlet weak var stillImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!

    override func awakeFromNib() {
            super.awakeFromNib()
            stillImageView.layer.cornerRadius = 14
            stillImageView.clipsToBounds = true
            stillImageView.contentMode = .scaleAspectFill
        }

        override func prepareForReuse() {
            super.prepareForReuse()
            stillImageView.kf.cancelDownloadTask()
            stillImageView.image = nil
        }
    }
