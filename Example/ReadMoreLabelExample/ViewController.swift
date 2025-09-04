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
        case fontSizeSmall   // 12pt font
        case fontSizeMedium  // 18pt font
        case fontSizeLarge   // 24pt font
        case fontSizeXLarge  // 32pt font
    }
}

class TableViewController: UIViewController {
    
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
        ),
        
        // Font Size Testing Examples
        SampleData(
            text: "📝 Small Font Size Test (12pt): This example demonstrates how ReadMoreLabel handles different font sizes. The 'Read More' text uses a smaller 12pt font while maintaining proper text truncation and positioning. This is useful for compact UI designs, footnotes, or when you need to display more content in limited space. The smaller font should still be readable and accessible.",
            style: .fontSizeSmall,
            position: .end,
            language: "en"
        ),
        SampleData(
            text: "📚 Medium Font Size Test (18pt): This example shows ReadMoreLabel with medium-sized font. The larger text provides better readability while still demonstrating the truncation functionality. This font size is ideal for main content areas where readability is important but you still want to conserve screen space with the read more feature.",
            style: .fontSizeMedium,
            position: .newLine,
            language: "en"
        ),
        SampleData(
            text: "📖 Large Font Size Test (24pt): This demonstrates ReadMoreLabel with large font size for enhanced accessibility and readability. The 'Read More' button uses the same large font size to maintain visual consistency. This is perfect for accessibility-focused apps or when targeting users who prefer larger text for better readability.",
            style: .fontSizeLarge,
            position: .end,
            language: "en"
        ),
        SampleData(
            text: "🎯 Extra Large Font Test (32pt): Testing with extra large font size to see how ReadMoreLabel adapts to very large text. This extreme font size tests the robustness of the text measurement and truncation algorithms. The 'Read More' text maintains the same large size for consistency.",
            style: .fontSizeXLarge,
            position: .newLine,
            language: "en"
        ),
        
        // Korean Font Size Examples
        SampleData(
            text: "📝 한국어 소형 폰트 테스트 (12pt): 이 예제는 ReadMoreLabel이 작은 폰트 크기를 어떻게 처리하는지 보여줍니다. 12pt 폰트를 사용하여 제한된 공간에서도 '더보기' 텍스트가 올바르게 표시되는지 확인할 수 있습니다. 작은 폰트 크기에서도 가독성을 유지하면서 텍스트 자르기 기능이 정상적으로 작동합니다.",
            style: .fontSizeSmall,
            position: .end,
            language: "ko"
        ),
        SampleData(
            text: "📚 한국어 중형 폰트 테스트 (18pt): 중간 크기 폰트로 ReadMoreLabel의 동작을 확인하는 예제입니다. 18pt 폰트는 가독성과 공간 효율성의 좋은 균형을 제공합니다. 메인 콘텐츠 영역에서 사용하기에 적합하며, 더보기 기능을 통해 화면 공간을 효율적으로 활용할 수 있습니다.",
            style: .fontSizeMedium,
            position: .newLine,
            language: "ko"
        ),
        SampleData(
            text: "📖 한국어 대형 폰트 테스트 (24pt): 접근성 향상을 위한 큰 폰트 크기로 ReadMoreLabel을 테스트합니다. 24pt 폰트는 시각적으로 더 명확하게 보이며, 큰 텍스트를 선호하는 사용자들에게 적합합니다. '더보기' 버튼도 동일한 큰 폰트 크기를 유지하여 시각적 일관성을 보장합니다.",
            style: .fontSizeLarge,
            position: .end,
            language: "ko"
        ),
        SampleData(
            text: "🎯 한국어 초대형 폰트 테스트 (32pt): 매우 큰 폰트 크기에서의 ReadMoreLabel 동작을 테스트합니다. 이 극한 폰트 크기는 텍스트 측정 및 자르기 알고리즘의 견고성을 확인하는 데 도움이 됩니다. '더보기' 텍스트도 동일한 큰 크기를 유지합니다.",
            style: .fontSizeXLarge,
            position: .newLine,
            language: "ko"
        ),
        
        // Japanese Font Size Examples
        SampleData(
            text: "📝 日本語小フォントテスト（12pt）: この例では、ReadMoreLabelが小さなフォントサイズをどのように処理するかを示します。12ptフォントを使用して、限られたスペースでも「続きを読む」テキストが正しく表示されることを確認できます。小さなフォントサイズでも読みやすさを維持しながら、テキスト切り詰め機能が正常に動作します。",
            style: .fontSizeSmall,
            position: .end,
            language: "ja"
        ),
        SampleData(
            text: "📚 日本語中フォントテスト（18pt）: 中サイズフォントでReadMoreLabelの動作を確認する例です。18ptフォントは読みやすさとスペース効率性の良いバランスを提供します。メインコンテンツエリアでの使用に適しており、もっと見る機能を通じて画面スペースを効率的に活用できます。",
            style: .fontSizeMedium,
            position: .newLine,
            language: "ja"
        ),
        SampleData(
            text: "📖 日本語大フォントテスト（24pt）: アクセシビリティ向上のための大きなフォントサイズでReadMoreLabelをテストします。24ptフォントは視覚的により明確に見え、大きなテキストを好むユーザーに適しています。「もっと見る」ボタンも同じ大きなフォントサイズを維持して視覚的一貫性を保証します。",
            style: .fontSizeLarge,
            position: .end,
            language: "ja"
        ),
        SampleData(
            text: "🎯 日本語特大フォントテスト（32pt）: 非常に大きなフォントサイズでのReadMoreLabel動作をテストします。この極限フォントサイズはテキスト測定および切り詰めアルゴリズムの堅牢性を確認するのに役立ちます。「もっと見る」テキストも同じ大きなサイズを維持します。",
            style: .fontSizeXLarge,
            position: .newLine,
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

extension TableViewController: UITableViewDataSource {
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

extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ExampleTableViewCellDelegate

@available(iOS 16.0, *)
extension TableViewController: ExampleTableViewCellDelegate {
    func didChangeExpandedState(_ cell: ExampleTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        expandedStates[indexPath.row] = true
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
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
        selectionStyle = .none  // Disable cell selection to prevent tap interference
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
        // Temporarily disable delegate to prevent recursion during configuration
        let originalDelegate = readMoreLabel.delegate
        readMoreLabel.delegate = nil
        
        readMoreLabel.text = sampleData.text
        readMoreLabel.setExpanded(isExpanded, animated: false)
        
        // Set position first
        readMoreLabel.readMorePosition = sampleData.position
        
        // Apply different styles and language-specific settings
        applyStyle(sampleData.style, language: sampleData.language)
        
        // Restore delegate after configuration is complete
        readMoreLabel.delegate = originalDelegate
    }
    
    private func applyStyle(_ style: ReadMoreLabel.Style, language: String) {
        // Get language-specific read more text
        let readMoreTexts = getReadMoreTexts(for: language, style: style)
        
        // Apply ellipsis
        readMoreLabel.ellipsisText = NSAttributedString(string: readMoreTexts.ellipsis)
        
        // Apply style-specific attributes
        switch style {
        case .basic:
            readMoreLabel.font = UIFont.systemFont(ofSize: 16)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium)
                ]
            )
            
        case .colorful:
            readMoreLabel.font = UIFont.systemFont(ofSize: 16)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemPurple,
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            )
            
        case .emoji:
            readMoreLabel.font = UIFont.systemFont(ofSize: 16)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemOrange,
                    .font: UIFont.systemFont(ofSize: 15, weight: .bold)
                ]
            )
            
        case .gradient:
            readMoreLabel.font = UIFont.systemFont(ofSize: 16)
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
            readMoreLabel.font = UIFont.systemFont(ofSize: 16)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemRed,
                    .font: UIFont.systemFont(ofSize: 16, weight: .black),
                    .underlineStyle: NSUnderlineStyle.thick.rawValue
                ]
            )
            
        case .mobile:
            readMoreLabel.font = UIFont.systemFont(ofSize: 16)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemIndigo,
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                    .backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.1)
                ]
            )
            
        case .fontSizeSmall:
            readMoreLabel.font = UIFont.systemFont(ofSize: 12)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium)
                ]
            )
            
        case .fontSizeMedium:
            readMoreLabel.font = UIFont.systemFont(ofSize: 18)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemGreen,
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
                ]
            )
            
        case .fontSizeLarge:
            readMoreLabel.font = UIFont.systemFont(ofSize: 24)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemOrange,
                    .font: UIFont.systemFont(ofSize: 24, weight: .bold)
                ]
            )
            
        case .fontSizeXLarge:
            readMoreLabel.font = UIFont.systemFont(ofSize: 32)
            readMoreLabel.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemRed,
                    .font: UIFont.systemFont(ofSize: 32, weight: .heavy)
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
            
        // Font Size Testing - English
        case ("en", .fontSizeSmall):
            return ("📝 Read More (12pt)", ".")
        case ("en", .fontSizeMedium):
            return ("📚 Read More (18pt)", "..")
        case ("en", .fontSizeLarge):
            return ("📖 Read More (24pt)", "...")
        case ("en", .fontSizeXLarge):
            return ("🎯 Read More (32pt)", "....")
            
        // Font Size Testing - Korean
        case ("ko", .fontSizeSmall):
            return ("📝 더보기 (12pt)", ".")
        case ("ko", .fontSizeMedium):
            return ("📚 더보기 (18pt)", "..")
        case ("ko", .fontSizeLarge):
            return ("📖 더보기 (24pt)", "...")
        case ("ko", .fontSizeXLarge):
            return ("🎯 더보기 (32pt)", "....")
            
        // Font Size Testing - Japanese
        case ("ja", .fontSizeSmall):
            return ("📝 もっと見る (12pt)", ".")
        case ("ja", .fontSizeMedium):
            return ("📚 もっと見る (18pt)", "..")
        case ("ja", .fontSizeLarge):
            return ("📖 もっと見る (24pt)", "...")
        case ("ja", .fontSizeXLarge):
            return ("🎯 もっと見る (32pt)", "....")
            
        // Font size styles fallback to English for other languages
        case (_, .fontSizeSmall), (_, .fontSizeMedium), (_, .fontSizeLarge), (_, .fontSizeXLarge):
            return getReadMoreTexts(for: "en", style: style)
            
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

// MARK: - LabelViewController

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
        title = "ReadMoreLabel Examples"
        
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
            label.isExpandAnimationEnabled = true
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
        let isAnimationEnabled = animationToggleSwitch.isOn
        englishLabel.isExpandAnimationEnabled = isAnimationEnabled
        koreanLabel.isExpandAnimationEnabled = isAnimationEnabled
        japaneseLabel.isExpandAnimationEnabled = isAnimationEnabled
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
