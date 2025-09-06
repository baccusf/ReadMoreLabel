import ReadMoreLabel
import UIKit

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
        ),
    ]

    private var expandedStates: [Bool] = []
    private var isAnimationEnabled: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        expandedStates = Array(repeating: false, count: sampleData.count)

        setupUI()
        setupTableView()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        })
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
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // Add header view
        let headerView = createHeaderView()
        tableView.tableHeaderView = headerView
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        if #available(iOS 16.0, *) {
            tableView.register(ExampleTableViewCell.self, forCellReuseIdentifier: "ExampleCell")
        }
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120 // Increased to allow for extra spacing
        tableView.separatorStyle = .singleLine

        // HeaderView와 첫 셀 간격 추가 보장
        tableView.sectionHeaderHeight = 0
        tableView.sectionFooterHeight = 0
    }

    private func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground

        // 애니메이션 스위치가 포함된 UIStackView 생성
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // 애니메이션 라벨 생성
        let animationLabel = UILabel()
        animationLabel.text = "Enable Animation:"
        animationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        animationLabel.textColor = .label

        // 애니메이션 스위치 생성
        let animationSwitch = UISwitch()
        animationSwitch.isOn = true
        animationSwitch.addTarget(self, action: #selector(animationSwitchChanged(_:)), for: .valueChanged)

        // 스택뷰에 요소들 추가
        stackView.addArrangedSubview(animationLabel)
        stackView.addArrangedSubview(animationSwitch)

        // headerView에 스택뷰 추가
        headerView.addSubview(stackView)

        // 스택뷰 양쪽 정렬 제약조건
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
        ])

        headerView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 63)
        headerView.autoresizingMask = [.flexibleWidth]

        return headerView
    }

    @objc private func animationSwitchChanged(_ sender: UISwitch) {
        isAnimationEnabled = sender.isOn
    }
}

// MARK: - UITableViewDataSource

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sampleData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath) as! ExampleTableViewCell
        cell.configure(
            with: sampleData[indexPath.row],
            isExpanded: expandedStates[indexPath.row],
            delegate: self
        )

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ReadMoreLabelDelegate

@available(iOS 16.0, *)
extension TableViewController: ReadMoreLabelDelegate {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        // label의 중심점을 tableView 좌표계로 변환
        let labelCenterInTableView = label.convert(label.center, to: tableView)

        // 해당 위치의 indexPath를 찾음
        guard let indexPath = tableView.indexPathForRow(at: labelCenterInTableView) else {
            return
        }

        // 확장 상태 업데이트
        expandedStates[indexPath.row] = isExpanded

        // 테이블 뷰 업데이트 (높이 변경 반영)
        if isAnimationEnabled {
            UIView.animate(withDuration: 0.3) {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        } else {
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
}

extension TableViewController {
    // MARK: - Sample Data Models

    struct SampleData {
        let text: String
        let style: ReadMoreLabel.Style
        let position: ReadMoreLabel.Position
        let language: String
    }
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
        case fontSizeSmall // 12pt font
        case fontSizeMedium // 18pt font
        case fontSizeLarge // 24pt font
        case fontSizeXLarge // 32pt font
    }
}
