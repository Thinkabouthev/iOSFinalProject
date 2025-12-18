import UIKit
import Kingfisher

final class EpisodeDetailsViewController: UIViewController, UITextViewDelegate {

    private let showId: Int
    private let season: Int
    private let episode: Int

    var showName: String = ""
    var episodeName: String = ""
    var episodeOverview: String = ""
    var stillURL: URL?

    private var episodeKey: String { EpisodeStore.shared.episodeKey(showId: showId, season: season, episode: episode) }

    // state
    private var watched = false

    // UI
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stack = UIStackView()

    private let titleRow = UIStackView()
    private let titleLabel = UILabel()
    private let watchedButton = UIButton(type: .system)

    private let infoCard = UIView()
    private let stillImage = UIImageView()
    private let showLabel = UILabel()
    private let epLabel = UILabel()
    private let metaLabel = UILabel()

    private let chipsRow = UIStackView()
    private let watchedChip = UILabel()
    private let hasNotesChip = UILabel()

    private let segment = UISegmentedControl(items: ["Notes", "AI Summary"])

    private let notesCard = UIView()
    private let notesTitle = UILabel()
    private let notesTextView = UITextView()
    private let notesPlaceholder = UILabel()

    private let aiCard = UIView()
    private let aiTextView = UITextView()
    private let aiButton = UIButton(type: .system)

    init(showId: Int, season: Int, episode: Int) {
        self.showId = showId
        self.season = season
        self.episode = episode
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        buildUI()
        layoutUI()
        hook()

        watched = EpisodeStore.shared.isWatched(episodeKey)
        applyWatchedUI()

        let saved = EpisodeStore.shared.loadNote(for: episodeKey)
        notesTextView.text = saved
        updateNotesUI()

        // fill texts
        titleLabel.text = "S\(season)E\(episode) • \(episodeName)"
        showLabel.text = showName
        epLabel.text = episodeName
        metaLabel.text = "Season \(season) • Episode \(episode)"
        if let stillURL { stillImage.kf.setImage(with: stillURL) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveNotes()
    }

    private func buildUI() {
        // stack
        stack.axis = .vertical
        stack.spacing = 16

        // title row
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 12

        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 0

        watchedButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        watchedButton.tintColor = .systemGray3
        watchedButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        watchedButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(UIView())
        titleRow.addArrangedSubview(watchedButton)

        // info card
        infoCard.backgroundColor = .secondarySystemBackground
        infoCard.layer.cornerRadius = 16

        stillImage.layer.cornerRadius = 14
        stillImage.clipsToBounds = true
        stillImage.contentMode = .scaleAspectFill
        stillImage.backgroundColor = .systemGray5

        stillImage.translatesAutoresizingMaskIntoConstraints = false
        stillImage.widthAnchor.constraint(equalToConstant: 110).isActive = true
        stillImage.heightAnchor.constraint(equalToConstant: 70).isActive = true

        showLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        epLabel.font = .systemFont(ofSize: 14, weight: .regular)
        epLabel.textColor = .secondaryLabel
        metaLabel.font = .systemFont(ofSize: 12, weight: .regular)
        metaLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [showLabel, epLabel, metaLabel])
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .leading

        let infoRow = UIStackView(arrangedSubviews: [stillImage, textStack])
        infoRow.axis = .horizontal
        infoRow.spacing = 12
        infoRow.alignment = .center
        infoRow.translatesAutoresizingMaskIntoConstraints = false

        infoCard.addSubview(infoRow)
        NSLayoutConstraint.activate([
            infoRow.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 12),
            infoRow.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -12),
            infoRow.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 12),
            infoRow.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -12),
        ])

        // chips
        chipsRow.axis = .horizontal
        chipsRow.spacing = 12
        chipsRow.alignment = .center

        setupChip(watchedChip, text: "Watched")
        setupChip(hasNotesChip, text: "Has notes")

        chipsRow.addArrangedSubview(watchedChip)
        chipsRow.addArrangedSubview(hasNotesChip)
        chipsRow.addArrangedSubview(UIView())

        // segment
        segment.selectedSegmentIndex = 0

        // notes card
        notesCard.backgroundColor = UIColor.black.withAlphaComponent(0.12)
        notesCard.layer.cornerRadius = 20

        notesTitle.text = "My Notes"
        notesTitle.font = .systemFont(ofSize: 18, weight: .bold)
        notesTitle.textColor = .white

        notesTextView.delegate = self
        notesTextView.backgroundColor = .clear
        notesTextView.textColor = .white
        notesTextView.font = .systemFont(ofSize: 15, weight: .regular)
        notesTextView.isScrollEnabled = false
        notesTextView.textContainerInset = UIEdgeInsets(top: 10, left: 6, bottom: 10, right: 6)

        notesPlaceholder.text = "Add notes…"
        notesPlaceholder.textColor = UIColor.white.withAlphaComponent(0.4)
        notesPlaceholder.font = .systemFont(ofSize: 15, weight: .regular)

        let notesInner = UIStackView(arrangedSubviews: [notesTitle, notesTextView])
        notesInner.axis = .vertical
        notesInner.spacing = 10
        notesInner.translatesAutoresizingMaskIntoConstraints = false

        notesCard.addSubview(notesInner)
        notesCard.addSubview(notesPlaceholder)

        NSLayoutConstraint.activate([
            notesInner.leadingAnchor.constraint(equalTo: notesCard.leadingAnchor, constant: 14),
            notesInner.trailingAnchor.constraint(equalTo: notesCard.trailingAnchor, constant: -14),
            notesInner.topAnchor.constraint(equalTo: notesCard.topAnchor, constant: 14),
            notesInner.bottomAnchor.constraint(equalTo: notesCard.bottomAnchor, constant: -14),

            notesTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 140),

            notesPlaceholder.leadingAnchor.constraint(equalTo: notesTextView.leadingAnchor, constant: 10),
            notesPlaceholder.topAnchor.constraint(equalTo: notesTextView.topAnchor, constant: 10),
        ])

        // ai card
        aiCard.backgroundColor = .secondarySystemBackground
        aiCard.layer.cornerRadius = 16
        aiCard.isHidden = true

        aiTextView.isEditable = false
        aiTextView.backgroundColor = .clear
        aiTextView.font = .systemFont(ofSize: 15, weight: .regular)
        aiTextView.text = "Tap “Generate summary” to get AI summary"
        aiTextView.translatesAutoresizingMaskIntoConstraints = false

        aiButton.setTitle("Generate summary", for: .normal)
        aiButton.translatesAutoresizingMaskIntoConstraints = false

        aiCard.addSubview(aiTextView)
        aiCard.addSubview(aiButton)
        

        NSLayoutConstraint.activate([
            aiTextView.leadingAnchor.constraint(equalTo: aiCard.leadingAnchor, constant: 14),
            aiTextView.trailingAnchor.constraint(equalTo: aiCard.trailingAnchor, constant: -14),
            aiTextView.topAnchor.constraint(equalTo: aiCard.topAnchor, constant: 14),

            aiButton.topAnchor.constraint(equalTo: aiTextView.bottomAnchor, constant: 10),
            aiButton.leadingAnchor.constraint(equalTo: aiCard.leadingAnchor, constant: 14),
            aiButton.bottomAnchor.constraint(equalTo: aiCard.bottomAnchor, constant: -14),

            aiCard.heightAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])

        // assemble
        stack.addArrangedSubview(titleRow)
        stack.addArrangedSubview(infoCard)
        stack.addArrangedSubview(chipsRow)
        stack.addArrangedSubview(segment)
        stack.addArrangedSubview(notesCard)
        stack.addArrangedSubview(aiCard)
    }

    private func layoutUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }

    private func hook() {
        watchedButton.addTarget(self, action: #selector(toggleWatched), for: .touchUpInside)
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        aiButton.addTarget(self, action: #selector(generateSummary), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(focusNotes))
        notesCard.addGestureRecognizer(tap)
    }

    @objc private func toggleWatched() {
        watched.toggle()
        EpisodeStore.shared.setWatched(watched, for: episodeKey)
        applyWatchedUI()
    }

    @objc private func segmentChanged() {
        let notesSelected = (segment.selectedSegmentIndex == 0)
        notesCard.isHidden = !notesSelected
        aiCard.isHidden = notesSelected
        if !notesSelected {
            notesTextView.resignFirstResponder()
            if aiTextView.text.contains("Tap") || aiTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                loadAISummary()
            }
        }
    }


    @objc private func focusNotes() {
        if segment.selectedSegmentIndex != 0 {
            segment.selectedSegmentIndex = 0
            segmentChanged()
        }
        notesTextView.becomeFirstResponder()
    }
    private func loadAISummary() {
        aiTextView.text = "Generating…"
        Task {
            do {
                let req = BackendClient.EpisodeNotesRequest(
                    showName: showName,
                    season: season,
                    episode: episode,
                    episodeName: episodeName,
                    overview: episodeOverview,
                    userNotes: notesTextView.text
                )

                let res = try await BackendClient.shared.getEpisodeNotes(req)

                await MainActor.run {
                    let bullets = res.key_points.map { "• \($0)" }.joined(separator: "\n")
                    aiTextView.text = """
                    \(res.summary)

                    Key points:
                    \(bullets)
                    """
                }
            } catch {
                await MainActor.run {
                    aiTextView.text = "AI error: \(error.localizedDescription)"
                }
            }
        }
    }
    @objc private func generateSummary() {
        loadAISummary()
    }

    // UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        updateNotesUI()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        saveNotes()
    }

    private func saveNotes() {
        EpisodeStore.shared.saveNote(notesTextView.text ?? "", for: episodeKey)
        updateNotesUI()
    }

    private func updateNotesUI() {
        let clean = (notesTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        notesPlaceholder.isHidden = !clean.isEmpty
        applyHasNotesChip(hasNotes: !clean.isEmpty)
    }

    private func applyWatchedUI() {
        watchedButton.tintColor = watched ? .systemPurple : .systemGray3
        watchedChip.backgroundColor = watched ? UIColor.systemPurple.withAlphaComponent(0.25) : UIColor.systemGray5
        watchedChip.textColor = watched ? .systemPurple : .secondaryLabel
    }

    private func applyHasNotesChip(hasNotes: Bool) {
        hasNotesChip.backgroundColor = hasNotes ? UIColor.systemPurple.withAlphaComponent(0.25) : UIColor.systemGray5
        hasNotesChip.textColor = hasNotes ? .systemPurple : .secondaryLabel
    }

    private func setupChip(_ label: UILabel, text: String) {
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textAlignment = .center
        label.backgroundColor = .systemGray5
        label.textColor = .secondaryLabel
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.heightAnchor.constraint(equalToConstant: 34).isActive = true
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
}
