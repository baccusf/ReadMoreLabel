//
//  StyleProvider.swift
//  ReadMoreLabelExample
//
//  Created by Claude Code on 9/7/25.
//

import Foundation
import ReadMoreLabel
import UIKit

class StyleProvider {
    
    // MARK: - Public Methods
    
    func getReadMoreTexts(for language: String, style: ReadMoreLabel.Style) -> (text: String, ellipsis: String) {
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
    
    func applyStyle(_ style: ReadMoreLabel.Style, to label: ReadMoreLabel, with data: ReadMoreSampleData) {
        let readMoreTexts = getReadMoreTexts(for: data.language, style: style)
        
        // Apply ellipsis
        label.ellipsisText = NSAttributedString(string: readMoreTexts.ellipsis)
        
        // Apply style-specific attributes
        switch style {
        case .basic:
            label.font = UIFont.systemFont(ofSize: 16)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                ]
            )
            
        case .colorful:
            label.font = UIFont.systemFont(ofSize: 16)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemPurple,
                    .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                ]
            )
            
        case .emoji:
            label.font = UIFont.systemFont(ofSize: 16)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemOrange,
                    .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                ]
            )
            
        case .gradient:
            label.font = UIFont.systemFont(ofSize: 16)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemTeal,
                    .font: UIFont.italicSystemFont(ofSize: 16),
                    .underlineStyle: NSUnderlineStyle.single.rawValue,
                    .underlineColor: UIColor.systemTeal,
                ]
            )
            
        case .bold:
            label.font = UIFont.systemFont(ofSize: 16)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemRed,
                    .font: UIFont.systemFont(ofSize: 16, weight: .black),
                    .underlineStyle: NSUnderlineStyle.thick.rawValue,
                ]
            )
            
        case .mobile:
            label.font = UIFont.systemFont(ofSize: 16)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemIndigo,
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                    .backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.1),
                ]
            )
            
        case .fontSizeSmall:
            label.font = UIFont.systemFont(ofSize: 12)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemBlue,
                    .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                ]
            )
            
        case .fontSizeMedium:
            label.font = UIFont.systemFont(ofSize: 18)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemGreen,
                    .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                ]
            )
            
        case .fontSizeLarge:
            label.font = UIFont.systemFont(ofSize: 24)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemOrange,
                    .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                ]
            )
            
        case .fontSizeXLarge:
            label.font = UIFont.systemFont(ofSize: 32)
            label.readMoreText = NSAttributedString(
                string: readMoreTexts.text,
                attributes: [
                    .foregroundColor: UIColor.systemRed,
                    .font: UIFont.systemFont(ofSize: 32, weight: .heavy),
                ]
            )
        }
    }
}