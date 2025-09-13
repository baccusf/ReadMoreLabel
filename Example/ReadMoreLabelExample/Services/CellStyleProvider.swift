import Foundation
import UIKit

// MARK: - Cell Style Provider Service

/// Single Responsibility: Cell styling configuration
struct CellStyleProvider {

    // MARK: - Types

    struct CellStyle {
        let titleFont: UIFont
        let subtitleFont: UIFont
        let subtitleTextColor: UIColor
        let accessoryType: UITableViewCell.AccessoryType
        let rowHeight: CGFloat
    }

    // MARK: - Public Interface

    static func mainScreenStyle() -> CellStyle {
        return CellStyle(
            titleFont: .systemFont(ofSize: 17, weight: .medium),
            subtitleFont: .systemFont(ofSize: 14),
            subtitleTextColor: .secondaryLabel,
            accessoryType: .disclosureIndicator,
            rowHeight: 70
        )
    }

    /// Apply style to table view cell
    static func applyStyle(_ style: CellStyle, to cell: UITableViewCell) {
        cell.textLabel?.font = style.titleFont
        cell.detailTextLabel?.font = style.subtitleFont
        cell.detailTextLabel?.textColor = style.subtitleTextColor
        cell.accessoryType = style.accessoryType
    }
}