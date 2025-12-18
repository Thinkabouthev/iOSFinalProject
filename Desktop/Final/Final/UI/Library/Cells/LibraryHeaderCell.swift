import UIKit

final class LibraryHeaderCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var filterSegment: UISegmentedControl!
    @IBOutlet weak var continueCollection: UICollectionView!
    @IBOutlet weak var addButton: UIButton!

    var onSearchChanged: ((String) -> Void)?
    var onAddTapped: (() -> Void)?
    var onSegmentChanged: ((Int) -> Void)?
    var onContinueSelected: ((Int) -> Void)?

    struct ContinueItem {
        let showId: Int
        let title: String
        let subtitle: String
        let posterPath: String?
        let progress: Float
    }

    private var continueItems: [ContinueItem] = []
    private var makePosterURL: ((String?) -> URL?)?

    override func awakeFromNib() {
        super.awakeFromNib()

        searchField.addTarget(self, action: #selector(searchChanged(_:)), for: .editingChanged)
        filterSegment.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)

        continueCollection.dataSource = self
        continueCollection.delegate = self
    }

    func configureContinue(items: [ContinueItem], makePosterURL: @escaping (String?) -> URL?) {
        self.continueItems = items
        self.makePosterURL = makePosterURL
        continueCollection.reloadData()
    }

    @IBAction func addTapped(_ sender: UIButton) {
            onAddTapped?()
    }

    @objc private func searchChanged(_ sender: UITextField) {
        onSearchChanged?(sender.text ?? "")
    }

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        onSegmentChanged?(sender.selectedSegmentIndex)
    }
}

extension LibraryHeaderCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        continueItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContinueCell", for: indexPath) as! ContinueWatchingCell
        let item = continueItems[indexPath.item]
        cell.configure(
            title: item.title,
            subtitle: item.subtitle,
            progress: item.progress,
            posterURL: makePosterURL?(item.posterPath)
        )
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onContinueSelected?(continueItems[indexPath.item].showId)
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 300, height: collectionView.bounds.height)
    }
}
