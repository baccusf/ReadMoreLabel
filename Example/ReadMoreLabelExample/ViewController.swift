import UIKit
import ReadMoreLabel

// MARK: - Sample Data Models

struct SampleData {
    let text: String
    let style: ReadMoreLabel.Style
    let position: ReadMoreLabel.Position
    let language: String
}

// MARK: - ReadMoreLabel Style Extension
extension ReadMoreLabel {
    enum Style {
        case basic
        case colorful  
        case emoji
        case gradient
        case bold
        case mobile
    }
}

class ViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private let sampleData = [
        SampleData(
            text: "✨ English emoji example with beginningNewLine position! 🚀 This ReadMoreLabel uses emoji bullets and styled text to create a more visually appealing user experience. The 'Read More' button appears on a completely new line after all allowed lines are displayed. Perfect for social media apps and news readers.",
            style: .emoji,
            position: .newLine,
            language: "en"
        ),
        // English Examples
        SampleData(
            text: "This is a longer English text that demonstrates the basic 'More..' functionality at the newLine position. ReadMoreLabel provides a clean and intuitive way to handle text truncation in your iOS applications. Users can tap the 'More..' button to reveal the complete content with smooth animations.",
            style: .basic,
            position: .newLine,
            language: "en"
        ),
        SampleData(
            text: "🎨 Colorful English styling example! This shows beginningTruncated position where the 'Read More' appears after (n-1) lines. You can customize the text with different colors, fonts, and emojis. The library supports NSAttributedString for rich text formatting, giving you complete control over the appearance.",
            style: .colorful,
            position: .end,
            language: "en"
        ),
        SampleData(
            text: "✨ English emoji example with beginningNewLine position! 🚀 This ReadMoreLabel uses emoji bullets and styled text to create a more visually appealing user experience. The 'Read More' button appears on a completely new line after all allowed lines are displayed. Perfect for social media apps and news readers. 📱💻🎨 This extended text ensures that even on iPhone 16's wide screen (393pt), the content will definitely require more than 3 lines to display properly, triggering the ReadMore functionality as expected. 🌟✨🔥",
            style: .emoji,
            position: .end,
            language: "en"
        ),
        
        // Korean Examples
        SampleData(
            text: "이것은 긴 한국어 텍스트로 newLine 위치를 보여주는 예제입니다. ReadMoreLabel은 iOS 앱에서 텍스트 자르기를 처리하는 깔끔하고 직관적인 방법을 제공합니다. 사용자는 '더보기..' 버튼을 탭하여 부드러운 애니메이션과 함께 전체 내용을 볼 수 있습니다. 모든 허용된 줄이 표시된 후 완전히 새로운 줄에 더보기 버튼이 나타납니다.",
            style: .bold,
            position: .newLine,
            language: "ko"
        ),
        SampleData(
            text: "🚀🔥💯 이모지가 포함된 텍스트 예제입니다! 🎉✨🌟 ReadMoreLabel은 복잡한 유니코드 문자도 정확하게 처리할 수 있습니다. 😊📱💻 다양한 이모지와 함께 텍스트가 올바르게 잘리는지 확인해보세요! 🎯🚀⭐ 이진 탐색 알고리즘을 사용하여 효율적으로 처리됩니다. 🔍💡🎨",
            style: .mobile,
            position: .end,
            language: "ko"
        ),
        SampleData(
            text: "🚀🔥💯 이모지가 포함된 텍스트 예제입니다! 🎉✨🌟 ReadMoreLabel은 복잡한 유니코드 문자도 정확하게 처리할 수 있습니다. \n😊📱💻 다양한 이모지와 함께 텍스트가 올바르게 잘리는지 확인해보세요! 🎯🚀⭐ 이진 탐색 알고리즘을 사용하여 효율적으로 처리됩니다. 🔍💡🎨",
            style: .mobile,
            position: .end,
            language: "ko"
        ),
        SampleData(
            text: "🇰🇷🇺🇸🇯🇵 국기 이모지와 복합 문자 테스트! 👨‍👩‍👧‍👦👩‍💻🧑‍🎨 가족 이모지도 포함되어 있습니다. TextKit 2의 강력한 텍스트 처리 능력을 확인할 수 있는 예제입니다. 📚✏️📝 복잡한 유니코드 조합도 정확하게 측정하고 자를 수 있습니다.",
            style: .gradient,
            position: .end,
            language: "ko"
        ),
        SampleData(
            text: "📱 これは日本語のモバイルファーストデザインの例です。newLine位置を使用しています。このReadMoreLabelは、適切なタップターゲットとアクセシビリティサポートを備えたタッチインターフェース用に最適化されています。すべてのiOSデバイスで一貫した動作を維持します。",
            style: .mobile,
            position: .newLine,
            language: "ja"
        ),
        SampleData(
            text: "🚀 日本語カスタム省略記号の例！beginningNewLine位置を使用。デフォルトの「..」の代わりに「→」や「***」、絵文字などの任意のテキストを使用できます。これにより、切り取られたテキストインジケーターの視覚的な外観をより細かく制御できます。すべての行が表示された後、新しい行にボタンが表示されます。",
            style: .gradient,
            position: .end,
            language: "ja"
        )
    ]
    
    private var expandedStates: [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        expandedStates = Array(repeating: false, count: sampleData.count)
    }
    
    private func setupUI() {
        title = "ReadMoreLabel Examples"
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Add header view
        let headerView = createHeaderView()
        tableView.tableHeaderView = headerView
    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = "Different ReadMoreLabel Styles"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Multilingual examples with different positions"
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -16)
        ])
        
        // Calculate required height and set proper frame
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let targetSize = CGSize(width: UIScreen.main.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let requiredSize = headerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        headerView.frame = CGRect(origin: .zero, size: requiredSize)
        
        return headerView
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 16.0, *) {
            tableView.register(ExampleTableViewCell.self, forCellReuseIdentifier: "ExampleCell")
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .singleLine
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { context in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        })
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath) as! ExampleTableViewCell
        cell.configure(
            with: sampleData[indexPath.row],
            isExpanded: expandedStates[indexPath.row]
        )
        cell.delegate = self

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ExampleTableViewCellDelegate

@available(iOS 16.0, *)
extension ViewController: ExampleTableViewCellDelegate {
    func didChangeExpandedState(_ cell: ExampleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        expandedStates[indexPath.row] = true
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}

// MARK: - Custom Table View Cell

protocol ExampleTableViewCellDelegate: AnyObject {
    func didChangeExpandedState(_ cell: ExampleTableViewCell)
}

@available(iOS 16.0, *)
class ExampleTableViewCell: UITableViewCell {
    
    weak var delegate: ExampleTableViewCellDelegate?
    
    private let readMoreLabel: ReadMoreLabel = {
        let label = ReadMoreLabel()
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // UITableViewCell 재활용 시 ReadMoreLabel 캐시 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        readMoreLabel.prepareForCellReuse() // 캐시 상태 초기화
    }
    
    private func setupUI() {
        contentView.addSubview(readMoreLabel)
        readMoreLabel.delegate = self
        
        // Content Priority 설정 - intrinsicContentSize를 존중하도록
        readMoreLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        readMoreLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        
        NSLayoutConstraint.activate([
            readMoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            readMoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            readMoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])

        // bottom constraint를 더 낮은 우선순위로 설정
        let bottomConstraint = readMoreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        bottomConstraint.priority = UILayoutPriority(750) // 250으로 낮춤
        bottomConstraint.isActive = true
    }
    
    func configure(with sampleData: SampleData, isExpanded: Bool) {
        readMoreLabel.text = sampleData.text
        readMoreLabel.setExpanded(isExpanded, animated: false)
        
        
        // Set position first
        readMoreLabel.readMorePosition = sampleData.position
        
        // Apply different styles and language-specific settings
        applyStyle(sampleData.style, language: sampleData.language)
    }
    
    
    private func applyStyle(_ style: ReadMoreLabel.Style, language: String) {
        // Get language-specific read more text
        let readMoreTexts = getReadMoreTexts(for: language, style: style)
        
        // Apply ellipsis
        readMoreLabel.ellipsisText = NSAttributedString(string: readMoreTexts.ellipsis)
        
        // Apply style-specific attributes
        switch style {
        case .basic:
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium)
                ]
            )
            
        case .colorful:
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemPurple,
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            )
            
        case .emoji:
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemOrange,
                    .font: UIFont.systemFont(ofSize: 15, weight: .bold)
                ]
            )
            
        case .gradient:
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemTeal,
                    .font: UIFont.italicSystemFont(ofSize: 16),
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: UIColor.systemTeal
                ]
            )
            
        case .bold:
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemRed,
                    .font: UIFont.systemFont(ofSize: 16, weight: .black),
                    .underlineStyle: NSUnderlineStyle.thick.rawValue
                ]
            )
            
        case .mobile:
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemIndigo,
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                    .backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.1)
                ]
            )
        }
    }
    
    private func getReadMoreTexts(for language: String, style: ReadMoreLabel.Style) -> (text: String, ellipsis: String) {
        switch (language, style) {
        // English
        case ("en", .basic):
            return ("More..", "..")
        case ("en", .colorful):
            return ("🎨 Read More", "***")
        case ("en", .emoji):
            return ("✨ More Magic", "...")
        case ("en", .gradient):
            return ("Continue Reading →", "~")
        case ("en", .bold):
            return ("🔥 SEE MORE", "!!!")
        case ("en", .mobile):
            return ("📱 Tap to Expand", "...")
            
        // Korean
        case ("ko", .basic):
            return ("더보기..", "..")
        case ("ko", .colorful):
            return ("🎨 더 읽기", "***")
        case ("ko", .emoji):
            return ("✨ 더보기 매직", "...")
        case ("ko", .gradient):
            return ("계속 읽기 →", "~")
        case ("ko", .bold):
            return ("🔥 더보기", "!!!")
        case ("ko", .mobile):
            return ("📱 탭하여 확장", "...")
            
        // Japanese
        case ("ja", .basic):
            return ("続きを読む..", "..")
        case ("ja", .colorful):
            return ("🎨 もっと読む", "***")
        case ("ja", .emoji):
            return ("✨ もっと見る", "...")
        case ("ja", .gradient):
            return ("続きを読む →", "~")
        case ("ja", .bold):
            return ("🔥 もっと見る", "!!!")
        case ("ja", .mobile):
            return ("📱 タップして展開", "...")
            
        // Default fallback to English
        default:
            return getReadMoreTexts(for: "en", style: style)
        }
    }
}

// MARK: - ReadMoreLabelDelegate

@available(iOS 16.0, *)
extension ExampleTableViewCell: ReadMoreLabelDelegate {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        delegate?.didChangeExpandedState(self)
    }
}
