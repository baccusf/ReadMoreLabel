import UIKit
import ReadMoreLabel

@available(iOS 16.0, *)
class LabelViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // ReadMoreLabels for different languages
    private let englishLabel = ReadMoreLabel()
    private let koreanLabel = ReadMoreLabel()
    private let japaneseLabel = ReadMoreLabel()
    
    // Control buttons
    private let animationToggleSwitch = UISwitch()
    private let expandCollapseButton = UIButton(type: .system)
    
    // Track expanded state
    private var currentlyExpandedLabels: Set<ReadMoreLabel> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLabels()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Animation Examples"
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Setup controls
        setupControls()
        
        // Setup labels
        setupReadMoreLabels()
        
        // Layout
        setupConstraints()
    }
    
    private func setupControls() {
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
        
        animationToggleSwitch.isOn = true
        animationToggleSwitch.addTarget(self, action: #selector(animationToggled), for: .valueChanged)
        
        animationStack.addArrangedSubview(animationLabel)
        animationStack.addArrangedSubview(animationToggleSwitch)
        
        // Expand/Collapse button
        expandCollapseButton.setTitle("Expand All", for: .normal)
        expandCollapseButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        expandCollapseButton.backgroundColor = .systemBlue
        expandCollapseButton.setTitleColor(.white, for: .normal)
        expandCollapseButton.layer.cornerRadius = 8
        expandCollapseButton.addTarget(self, action: #selector(expandCollapseButtonTapped), for: .touchUpInside)
        
        controlsStackView.addArrangedSubview(animationStack)
        controlsStackView.addArrangedSubview(expandCollapseButton)
        
        contentView.addSubview(controlsStackView)
        
        NSLayoutConstraint.activate([
            controlsStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            controlsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            controlsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            expandCollapseButton.heightAnchor.constraint(equalToConstant: 44)
        ])
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
        // English
        englishLabel.text = "🇺🇸 This is a long English text that demonstrates the ReadMoreLabel functionality. When you tap the 'Read More' button, the text will expand to show the full content with smooth animation. The library supports multiple languages and provides a clean way to handle text truncation in your iOS applications. You can customize the appearance, animation, and behavior according to your needs."
        englishLabel.readMoreText = NSAttributedString(
            string: "Read More",
            attributes: [.foregroundColor: UIColor.systemBlue]
        )
        
        // Korean
        koreanLabel.text = "🇰🇷 이것은 ReadMoreLabel 기능을 보여주는 긴 한국어 텍스트입니다. '더보기' 버튼을 탭하면 부드러운 애니메이션과 함께 전체 텍스트가 확장됩니다. 이 라이브러리는 다국어를 지원하며 iOS 애플리케이션에서 텍스트 자르기를 깔끔하게 처리하는 방법을 제공합니다. 필요에 따라 모양, 애니메이션 및 동작을 사용자 정의할 수 있습니다."
        koreanLabel.readMoreText = NSAttributedString(
            string: "더보기",
            attributes: [.foregroundColor: UIColor.systemBlue]
        )
        
        // Japanese
        japaneseLabel.text = "🇯🇵 これはReadMoreLabelの機能を示す長い日本語のテキストです。「続きを読む」ボタンをタップすると、スムーズなアニメーションとともにテキスト全体が展開されます。このライブラリは多言語をサポートし、iOSアプリケーションでテキストの切り詰めをきれいに処理する方法を提供します。必要に応じて、外観、アニメーション、動作をカスタマイズできます。"
        japaneseLabel.readMoreText = NSAttributedString(
            string: "続きを読む",
            attributes: [.foregroundColor: UIColor.systemBlue]
        )
    }
    
    private func setupConstraints() {
        // Find the controls stack view
        guard let controlsStackView = contentView.subviews.first(where: { $0 is UIStackView }) as? UIStackView else { return }
        
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
            englishLabel.topAnchor.constraint(equalTo: controlsStackView.bottomAnchor, constant: 30),
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
            japaneseLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }
    
    @objc private func animationToggled() {
        // 애니메이션 설정은 이제 UI 레벨에서만 처리됩니다
        // ReadMoreLabel 자체에는 애니메이션 기능이 없습니다
    }
    
    @objc private func expandCollapseButtonTapped() {
        let allLabels = [englishLabel, koreanLabel, japaneseLabel]
        
        // Check if any label is expanded
        let hasExpandedLabels = allLabels.contains { $0.isExpanded }
        
        // 애니메이션 설정에 따라 레이아웃 애니메이션 적용
        let animateLayout = {
            if self.animationToggleSwitch.isOn {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                self.view.layoutIfNeeded()
            }
        }
        
        if hasExpandedLabels {
            // Collapse all
            for label in allLabels {
                if label.isExpanded {
                    label.collapse()
                }
            }
            expandCollapseButton.setTitle("Expand All", for: .normal)
        } else {
            // Expand all
            for label in allLabels {
                if !label.isExpanded && label.isExpandable {
                    label.expand()
                }
            }
            expandCollapseButton.setTitle("Collapse All", for: .normal)
        }
        
        // 모든 변경 후 레이아웃 애니메이션 적용
        animateLayout()
    }
    
    private func updateExpandCollapseButtonTitle() {
        let allLabels = [englishLabel, koreanLabel, japaneseLabel]
        let hasExpandedLabels = allLabels.contains { $0.isExpanded }
        
        expandCollapseButton.setTitle(hasExpandedLabels ? "Collapse All" : "Expand All", for: .normal)
    }
}

// MARK: - ReadMoreLabelDelegate

@available(iOS 16.0, *)
extension LabelViewController: ReadMoreLabelDelegate {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        updateExpandCollapseButtonTitle()
        
        // ScrollView에서 레이아웃 애니메이션 적용
        if animationToggleSwitch.isOn {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        } else {
            self.view.layoutIfNeeded()
        }
    }
}