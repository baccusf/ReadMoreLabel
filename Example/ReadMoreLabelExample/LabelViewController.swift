import ReadMoreLabel
import UIKit

@available(iOS 16.0, *)
class LabelViewController: UIViewController {
    // MARK: - Properties
    
    private let viewModel = LabelViewModel()
    
    // Top controls (outside scroll view)
    private let topControlsContainer = UIView()
    private let animationToggleSwitch = UISwitch()
    private let expandCollapseButton = UIButton(type: .system)
    
    // ScrollView and content
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // ReadMoreLabels for different languages
    private let englishLabel = ReadMoreLabel()
    private let koreanLabel = ReadMoreLabel()
    private let japaneseLabel = ReadMoreLabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLabels()
        bindViewModel()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Animation Examples"

        // Setup top controls container
        setupTopControls()
        
        // Setup scroll view
        setupScrollView()

        // Setup labels
        setupReadMoreLabels()

        // Layout
        setupConstraints()
    }

    private func setupTopControls() {
        topControlsContainer.backgroundColor = .systemBackground
        topControlsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let controlsStackView = UIStackView()
        controlsStackView.axis = .vertical
        controlsStackView.spacing = 16
        controlsStackView.translatesAutoresizingMaskIntoConstraints = false

        // Animation toggle
        let animationStack = UIStackView()
        animationStack.axis = .horizontal
        animationStack.spacing = 12
        animationStack.alignment = .center

        let animationLabel = UILabel()
        animationLabel.text = "Enable Animation:"
        animationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        animationToggleSwitch.isOn = viewModel.isAnimationEnabled
        animationToggleSwitch.addTarget(self, action: #selector(animationToggleChanged), for: .valueChanged)

        animationStack.addArrangedSubview(animationLabel)
        animationStack.addArrangedSubview(animationToggleSwitch)

        // Expand/Collapse button
        expandCollapseButton.setTitle("Expand All", for: .normal)
        expandCollapseButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        expandCollapseButton.backgroundColor = .systemBlue
        expandCollapseButton.setTitleColor(.white, for: .normal)
        expandCollapseButton.layer.cornerRadius = 8
        expandCollapseButton.addTarget(
            self,
            action: #selector(expandCollapseButtonTapped),
            for: .touchUpInside
        )

        controlsStackView.addArrangedSubview(animationStack)
        controlsStackView.addArrangedSubview(expandCollapseButton)
        
        topControlsContainer.addSubview(controlsStackView)
        view.addSubview(topControlsContainer)

        NSLayoutConstraint.activate([
            controlsStackView.topAnchor.constraint(equalTo: topControlsContainer.topAnchor, constant: 20),
            controlsStackView.leadingAnchor.constraint(equalTo: topControlsContainer.leadingAnchor, constant: 16),
            controlsStackView.trailingAnchor.constraint(equalTo: topControlsContainer.trailingAnchor, constant: -16),
            controlsStackView.bottomAnchor.constraint(equalTo: topControlsContainer.bottomAnchor, constant: -20),
            expandCollapseButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func setupReadMoreLabels() {
        let labels = [englishLabel, koreanLabel, japaneseLabel]

        for label in labels {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 3
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .label
            label.delegate = self
            contentView.addSubview(label)
        }
    }

    private func setupLabels() {
        // Configure labels with ViewModel data
        let labels = [englishLabel, koreanLabel, japaneseLabel]
        for (index, label) in labels.enumerated() {
            let labelData = viewModel.labelData[index]
            label.text = labelData.text
            label.readMoreText = labelData.readMoreText
            label.setExpanded(labelData.isExpanded)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top controls container constraints
            topControlsContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topControlsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topControlsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // Scroll view constraints (below top controls)
            scrollView.topAnchor.constraint(equalTo: topControlsContainer.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // English label
            englishLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            englishLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            englishLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Korean label
            koreanLabel.topAnchor.constraint(equalTo: englishLabel.bottomAnchor, constant: 30),
            koreanLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            koreanLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Japanese label
            japaneseLabel.topAnchor.constraint(equalTo: koreanLabel.bottomAnchor, constant: 30),
            japaneseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            japaneseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            japaneseLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),
        ])
    }

    @objc private func expandCollapseButtonTapped() {
        let allLabels = [englishLabel, koreanLabel, japaneseLabel]

        // Check if any label is expanded through ViewModel
        let hasExpandedLabels = viewModel.hasAnyExpandedLabels()

        let animateLayout = {
            if self.viewModel.isAnimationEnabled {
                UIView.animate(
                    withDuration: 0.3,
                    delay: 0,
                    usingSpringWithDamping: 0.8,
                    initialSpringVelocity: 0.5,
                    options: [.curveEaseInOut],
                    animations: {
                        self.view.layoutIfNeeded()
                    },
                    completion: nil
                )
            } else {
                self.view.layoutIfNeeded()
            }
        }

        if hasExpandedLabels {
            // Collapse all through ViewModel
            viewModel.collapseAll()
            for label in allLabels {
                if label.isExpanded {
                    label.collapse()
                }
            }
            expandCollapseButton.setTitle("Expand All", for: .normal)
        } else {
            // Expand all through ViewModel
            viewModel.expandAll()
            for label in allLabels {
                if !label.isExpanded, label.isExpandable {
                    label.expand()
                }
            }
            expandCollapseButton.setTitle("Collapse All", for: .normal)
        }

        animateLayout()
    }

    private func updateExpandCollapseButtonTitle() {
        let hasExpandedLabels = viewModel.hasAnyExpandedLabels()
        expandCollapseButton.setTitle(hasExpandedLabels ? "Collapse All" : "Expand All", for: .normal)
    }
    
    private func bindViewModel() {
        // ViewModel의 변경사항을 감지하여 UI 업데이트
        // 실제 프로젝트에서는 Combine 또는 다른 reactive framework를 사용할 수 있습니다.
    }
    
    @objc private func animationToggleChanged(_ sender: UISwitch) {
        viewModel.toggleAnimation(sender.isOn)
    }
}

// MARK: - ReadMoreLabelDelegate

@available(iOS 16.0, *)
extension LabelViewController: ReadMoreLabelDelegate {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        // Update ViewModel state
        let allLabels = [englishLabel, koreanLabel, japaneseLabel]
        if let index = allLabels.firstIndex(of: label) {
            let labelData = viewModel.labelData[index]
            viewModel.updateExpandedState(for: labelData.id, isExpanded: isExpanded)
        }
        
        updateExpandCollapseButtonTitle()

        // ScrollView에서 레이아웃 애니메이션 적용
        if viewModel.isAnimationEnabled {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: [.curveEaseInOut],
                animations: {
                    self.view.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            view.layoutIfNeeded()
        }
    }
}
