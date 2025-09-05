//
//  ExampleTableViewCell.swift
//  ReadMoreLabelExample
//
//  Created by SeungHo Choi on 9/4/25.
//

import UIKit
import ReadMoreLabel

@available(iOS 16.0, *)
class ExampleTableViewCell: UITableViewCell {
    
    weak var delegate: ReadMoreLabelDelegate?
    
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
    
    // UITableViewCell 재활용 시 상태 초기화
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // ReadMoreLabel의 캐시 상태 초기화
        // configure에서 올바른 순서로 확장 상태가 복원됨
        readMoreLabel.prepareForCellReuse()
    }
    
    private func setupUI() {
        selectionStyle = .none  // Disable cell selection to prevent tap interference
        readMoreLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(readMoreLabel)
        clipsToBounds = true
        
        // Content Priority 설정 - intrinsicContentSize를 존중하도록
        readMoreLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        readMoreLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)
        
        NSLayoutConstraint.activate([
            readMoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            readMoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            readMoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
        ])

        // bottom constraint를 더 낮은 우선순위로 설정
        let bottomConstraint = readMoreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        bottomConstraint.priority = UILayoutPriority(750) // 250으로 낮춤
        bottomConstraint.isActive = true
    }
    
    func configure(with sampleData: TableViewController.SampleData, isExpanded: Bool, delegate: ReadMoreLabelDelegate?) {
        // Set delegate first
        readMoreLabel.delegate = delegate
        
        // Set text and position first
        readMoreLabel.text = sampleData.text
        readMoreLabel.readMorePosition = sampleData.position
        
        // Apply different styles and language-specific settings BEFORE setting expanded state
        // This prevents font changes from overriding the expanded state
        applyStyle(sampleData.style, language: sampleData.language)
        
        // Set expanded state LAST to preserve it after style changes
        // Cell 재사용 시에는 delegate 호출하지 않음 (불필요한 상태 업데이트 방지)
        readMoreLabel.setExpanded(isExpanded, notifyDelegate: false)
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
