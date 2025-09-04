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

// MARK: - Main View Controller

class ViewController: UIViewController {
    
    private let tableView = UITableView()
    
    private let examples: [(title: String, subtitle: String, viewController: UIViewController.Type)] = [
        (
            title: "📋 Table View Examples", 
            subtitle: "Multiple styles with different languages and positions",
            viewController: TableViewController.self
        ),
        (
            title: "🎬 Animation Examples", 
            subtitle: "ScrollView with animation controls",
            viewController: LabelViewController.self
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    private func setupUI() {
        title = "ReadMoreLabel Demo"
        view.backgroundColor = .systemBackground
        
        // Setup navigation bar - use standard title size
        navigationController?.navigationBar.prefersLargeTitles = false
        
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
        titleLabel.text = "ReadMoreLabel Library"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "iOS 16+ UILabel extension for text truncation with 'Read More' functionality"
        subtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "Choose an example below to explore different features and use cases"
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .tertiaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(subtitleLabel)
        headerView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 12),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20)
        ])
        
        // Use Auto Layout for proper sizing
        headerView.translatesAutoresizingMaskIntoConstraints = true
        
        // Force layout calculation to get the correct height
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        let fittingSize = headerView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        headerView.frame = CGRect(origin: .zero, size: fittingSize)
        
        return headerView
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        // Style the table view
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let example = examples[indexPath.row]
        
        // Configure cell
        cell.textLabel?.text = example.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cell.textLabel?.textColor = .label
        
        cell.detailTextLabel?.text = example.subtitle
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 2
        
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        
        // Add custom styling
        cell.backgroundColor = .secondarySystemBackground
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true
        
        // Add some spacing between cells
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let example = examples[indexPath.row]
        
        // Create and present the selected view controller
        let viewController: UIViewController = if example.viewController == TableViewController.self {
            TableViewController()
        } else {
            LabelViewController()
        }
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Apply professional cell presentation with defined spacing and margins
        applyCellPresentation(to: cell)
    }
    
    /// Applies consistent visual styling to table view cells with proper spacing
    /// - Parameter cell: The cell to style
    private func applyCellPresentation(to cell: UITableViewCell) {
        // Design system constants
        struct CellDesign {
            static let horizontalMargin: CGFloat = 16
            static let verticalSpacing: CGFloat = 8
            static let cornerRadius: CGFloat = 12
        }
        
        // Apply inset frame with proper calculations
        let originalFrame = cell.frame
        let insetFrame = CGRect(
            x: originalFrame.origin.x + CellDesign.horizontalMargin,
            y: originalFrame.origin.y + CellDesign.verticalSpacing / 2,
            width: originalFrame.width - (CellDesign.horizontalMargin * 2),
            height: originalFrame.height - CellDesign.verticalSpacing
        )
        
        cell.frame = insetFrame
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
        readMoreLabel.setExpanded(isExpanded)
        
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
