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

    override func prepareForReuse() {
        super.prepareForReuse()
    }

    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(readMoreLabel)
        clipsToBounds = true

        readMoreLabel.setContentHuggingPriority(UILayoutPriority(1000), for: .vertical)
        readMoreLabel.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .vertical)

        NSLayoutConstraint.activate([
            readMoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            readMoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            readMoreLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
        ])

        let bottomConstraint = readMoreLabel.bottomAnchor.constraint(
            equalTo: contentView.bottomAnchor,
            constant: 0
        )
        bottomConstraint.priority = UILayoutPriority(750)
        bottomConstraint.isActive = true
    }

    func configure(with sampleData: TableViewModel.ReadMoreSampleData, isExpanded: Bool,
                   delegate: ReadMoreLabelDelegate?)
    {
        readMoreLabel.delegate = delegate
        readMoreLabel.text = sampleData.text
        readMoreLabel.readMorePosition = sampleData.position

        if sampleData.language == "ar" {
            readMoreLabel.textAlignment = .right
            readMoreLabel.semanticContentAttribute = .forceRightToLeft
        } else {
            readMoreLabel.textAlignment = .natural
            readMoreLabel.semanticContentAttribute = .unspecified
        }

        let styleProvider = TableViewModel.StyleProvider()
        styleProvider.applyStyle(sampleData.style, to: readMoreLabel, with: sampleData)
        readMoreLabel.setExpanded(isExpanded)
    }

}
