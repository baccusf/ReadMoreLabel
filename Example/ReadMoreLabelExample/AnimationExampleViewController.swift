import ReadMoreLabel
import UIKit

// MARK: - Animation Example Controller

/// Animation Examples showing expand/collapse animations
final class AnimationExampleViewController: UIViewController {

    // MARK: - Properties

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let sampleText = """
    This is a comprehensive example demonstrating the animation capabilities of ReadMoreLabel.
    When you tap the "Read More" button, the label will expand with a smooth animation to show the full content.
    You can also programmatically control the expansion state using the provided methods.

    The animation is smooth and provides excellent user experience for content that needs to be truncated initially but can be expanded on demand.
    """

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Animation Examples"
        setupScrollView()
        setupContent()
    }

    // MARK: - Private Methods

    private func setupScrollView() {
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupContent() {
        var previousView: UIView = contentView

        // Create multiple ReadMoreLabel examples
        for i in 0..<3 {
            let containerView = createLabelContainer(index: i + 1)
            contentView.addSubview(containerView)

            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: previousView == contentView ? contentView.topAnchor : previousView.bottomAnchor, constant: 20),
                containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
            ])

            previousView = containerView
        }

        // Set bottom constraint for the last view
        NSLayoutConstraint.activate([
            previousView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    private func createLabelContainer(index: Int) -> UIView {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Example \(index)"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)

        let readMoreLabel = ReadMoreLabel()
        readMoreLabel.translatesAutoresizingMaskIntoConstraints = false
        readMoreLabel.text = sampleText
        readMoreLabel.numberOfLines = 3
        readMoreLabel.font = .systemFont(ofSize: 16)

        let expandButton = UIButton(type: .system)
        expandButton.translatesAutoresizingMaskIntoConstraints = false
        expandButton.setTitle("Toggle Expand", for: .normal)
        expandButton.addTarget(self, action: #selector(toggleExpand(_:)), for: .touchUpInside)
        expandButton.tag = index

        containerView.addSubview(titleLabel)
        containerView.addSubview(readMoreLabel)
        containerView.addSubview(expandButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            readMoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            readMoreLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            readMoreLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            expandButton.topAnchor.constraint(equalTo: readMoreLabel.bottomAnchor, constant: 12),
            expandButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            expandButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        return containerView
    }

    @objc private func toggleExpand(_ sender: UIButton) {
        guard let containerView = sender.superview,
              let readMoreLabel = containerView.subviews.compactMap({ $0 as? ReadMoreLabel }).first else {
            return
        }

        UIView.animate(withDuration: 0.3) {
            readMoreLabel.isExpanded.toggle()
            self.view.layoutIfNeeded()
        }
    }
}