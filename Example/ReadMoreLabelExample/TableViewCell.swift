//
//  TableViewCell.swift
//  ReadMoreLabelExample
//
//  Created by SeungHo Choi on 9/4/25.
//

import ReadMoreLabel
import UIKit

@available(iOS 16.0, *)
class TableViewCell: UITableViewCell {
    // MARK: - Properties
    
    weak var delegate: ReadMoreLabelDelegate?
    private let styleProvider = TableViewModel.StyleProvider()

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

        // ReadMoreLabel은 외부에서 상태 관리하므로 별도 초기화 불필요
        // configure에서 올바른 순서로 확장 상태가 복원됨
    }

    private func setupUI() {
        selectionStyle = .none // Disable cell selection to prevent tap interference
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
        let bottomConstraint = readMoreLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: 0
        )
        bottomConstraint.priority = UILayoutPriority(750) // 250으로 낮춤
        bottomConstraint.isActive = true
    }

    func configure(with sampleData: TableViewModel.ReadMoreSampleData, isExpanded: Bool,
                   delegate: ReadMoreLabelDelegate?)
    {
        // Set delegate first
        readMoreLabel.delegate = delegate

        // Set text and position first
        readMoreLabel.text = sampleData.text
        readMoreLabel.readMorePosition = sampleData.position

        // RTL support for Arabic language
        if sampleData.language == "ar" {
            readMoreLabel.textAlignment = .right
            readMoreLabel.semanticContentAttribute = .forceRightToLeft
        } else {
            readMoreLabel.textAlignment = .natural
            readMoreLabel.semanticContentAttribute = .unspecified
        }

        // Apply different styles using StyleProvider BEFORE setting expanded state
        // This prevents font changes from overriding the expanded state
        styleProvider.applyStyle(sampleData.style, to: readMoreLabel, with: sampleData)

        // Set expanded state LAST to preserve it after style changes
        // Cell 재사용 시에는 delegate 호출하지 않음 (불필요한 상태 업데이트 방지)
        readMoreLabel.setExpanded(isExpanded)
    }

}
