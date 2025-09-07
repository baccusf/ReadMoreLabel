//
//  TableViewModel.swift
//  ReadMoreLabelExample
//
//  Created by Claude Code on 9/7/25.
//

import Foundation
import ReadMoreLabel
import UIKit

@available(iOS 16.0, *)
class TableViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var sampleData: [ReadMoreSampleData] = []
    @Published var expandedStates: [Bool] = []
    @Published var isAnimationEnabled: Bool = true
    
    // MARK: - Private Properties
    
    private let styleProvider = StyleProvider()
    
    // MARK: - Initialization
    
    init() {
        loadSampleData()
    }
    
    // MARK: - Public Methods
    
    func toggleAnimation(_ enabled: Bool) {
        isAnimationEnabled = enabled
    }
    
    func updateExpandedState(at index: Int, isExpanded: Bool) {
        guard index >= 0 && index < expandedStates.count else { return }
        expandedStates[index] = isExpanded
    }
    
    func getReadMoreTexts(for language: String, style: Style) -> (text: String, ellipsis: String) {
        return styleProvider.getReadMoreTexts(for: language, style: style)
    }
    
    // MARK: - Private Methods
    
    private func loadSampleData() {
        sampleData = [
            ReadMoreSampleData(
                text: "✨ English emoji example with beginningNewLine position! 🚀 This ReadMoreLabel uses emoji bullets and styled text to create a more visually appealing user experience. The 'Read More' button appears on a completely new line after all allowed lines are displayed. Perfect for social media apps and news readers.",
                style: .emoji,
                position: .newLine,
                language: "en"
            ),
            // English Examples
            ReadMoreSampleData(
                text: "This is a longer English text that demonstrates the basic 'More..' functionality at the newLine position. ReadMoreLabel provides a clean and intuitive way to handle text truncation in your iOS applications. Users can tap the 'More..' button to reveal the complete content with smooth animations.",
                style: .basic,
                position: .newLine,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "🎨 Colorful English styling example! This shows beginningTruncated position where the 'Read More' appears after (n-1) lines. You can customize the text with different colors, fonts, and emojis. The library supports NSAttributedString for rich text formatting, giving you complete control over the appearance.",
                style: .colorful,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "✨ English emoji example with beginningNewLine position! 🚀 This ReadMoreLabel uses emoji bullets and styled text to create a more visually appealing user experience. The 'Read More' button appears on a completely new line after all allowed lines are displayed. Perfect for social media apps and news readers. 📱💻🎨 This extended text ensures that even on iPhone 16's wide screen (393pt), the content will definitely require more than 3 lines to display properly, triggering the ReadMore functionality as expected. 🌟✨🔥",
                style: .emoji,
                position: .end,
                language: "en"
            ),

            // Korean Examples
            ReadMoreSampleData(
                text: "이것은 긴 한국어 텍스트로 newLine 위치를 보여주는 예제입니다. ReadMoreLabel은 iOS 앱에서 텍스트 자르기를 처리하는 깔끔하고 직관적인 방법을 제공합니다. 사용자는 '더보기..' 버튼을 탭하여 부드러운 애니메이션과 함께 전체 내용을 볼 수 있습니다. 모든 허용된 줄이 표시된 후 완전히 새로운 줄에 더보기 버튼이 나타납니다.",
                style: .bold,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🚀🔥💯 이모지가 포함된 텍스트 예제입니다! 🎉✨🌟 ReadMoreLabel은 복잡한 유니코드 문자도 정확하게 처리할 수 있습니다. 😊📱💻 다양한 이모지와 함께 텍스트가 올바르게 잘리는지 확인해보세요! 🎯🚀⭐ 이진 탐색 알고리즘을 사용하여 효율적으로 처리됩니다. 🔍💡🎨",
                style: .mobile,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🚀🔥💯 이모지가 포함된 텍스트 예제입니다! 🎉✨🌟 ReadMoreLabel은 복잡한 유니코드 문자도 정확하게 처리할 수 있습니다. \n😊📱💻 다양한 이모지와 함께 텍스트가 올바르게 잘리는지 확인해보세요! 🎯🚀⭐ 이진 탐색 알고리즘을 사용하여 효율적으로 처리됩니다. 🔍💡🎨",
                style: .mobile,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🇰🇷🇺🇸🇯🇵 국기 이모지와 복합 문자 테스트! 👨‍👩‍👧‍👦👩‍💻🧑‍🎨 가족 이모지도 포함되어 있습니다. TextKit 1의 강력한 텍스트 처리 능력을 확인할 수 있는 예제입니다. 📚✏️📝 복잡한 유니코드 조합도 정확하게 측정하고 자를 수 있습니다.",
                style: .gradient,
                position: .end,
                language: "ko"
            ),
            
            // Japanese Examples
            ReadMoreSampleData(
                text: "これはReadMoreLabelの機能を示す長い日本語のテキストです。「続きを読む」ボタンをタップすると、スムーズなアニメーションとともにテキストが展開されます。日本語の文字処理も正確に行われ、美しい表示を実現します。",
                style: .basic,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "🌸 これはReadMoreLabelの機能を示す長い日本語のテキストです。「続きを読む」ボタンをタップすると、スムーズなアニメーションとともにテキストが展開されます。日本語の文字処理も正確に行われ、美しい表示を実現します。絵文字や特殊文字も適切に処理されます。🎌✨",
                style: .emoji,
                position: .newLine,
                language: "ja"
            ),
            
            // Additional English Examples with different styles
            ReadMoreSampleData(
                text: "This is another comprehensive English example that demonstrates various ReadMoreLabel features. The gradient style provides an elegant appearance with gradient colors and attractive typography. Perfect for modern iOS applications that need sophisticated text handling capabilities.",
                style: .gradient,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "📱 Mobile optimized example with responsive design! This text demonstrates how ReadMoreLabel adapts to different screen sizes and orientations. The mobile style ensures optimal readability across all iOS devices, from iPhone SE to iPhone 16 Pro Max. Great for apps that prioritize user experience!",
                style: .mobile,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "Bold and prominent text styling example! This demonstrates the bold style which makes important content stand out. Perfect for headlines, announcements, or any content that needs to capture user attention immediately. The text remains highly readable while maintaining visual hierarchy.",
                style: .bold,
                position: .newLine,
                language: "en"
            ),
            
            // Additional Korean Examples
            ReadMoreSampleData(
                text: "✨ 그라데이션 스타일 한국어 예제입니다! 그라데이션 효과와 함께 아름다운 텍스트 스타일링을 보여줍니다. 현대적인 iOS 앱에서 사용하기에 적합한 세련된 디자인을 제공하며, 사용자 경험을 향상시킵니다. 다양한 텍스트 길이에 완벽하게 대응합니다.",
                style: .gradient,
                position: .end,
                language: "ko"
            ),
            
            // Font Size Testing - English
            ReadMoreSampleData(
                text: "📝 Font Size Small (12pt): This text demonstrates ReadMoreLabel functionality with a smaller font size. The compact text allows for more content density while maintaining readability across different screen sizes and accessibility settings.",
                style: .fontSizeSmall,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "📚 Font Size Medium (18pt): This text showcases ReadMoreLabel with a medium font size that provides excellent balance between readability and content density. Perfect for most standard text content in modern mobile applications.",
                style: .fontSizeMedium,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "📖 Font Size Large (24pt): This text demonstrates ReadMoreLabel with a large font size that ensures excellent readability for users with visual impairments or when accessibility features are enabled in the system.",
                style: .fontSizeLarge,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "🎯 Font Size Extra Large (32pt): This text shows ReadMoreLabel functionality with an extra large font size, ideal for headlines, important announcements, or when maximum readability is required.",
                style: .fontSizeXLarge,
                position: .end,
                language: "en"
            ),
            
            // Font Size Testing - Korean
            ReadMoreSampleData(
                text: "📝 폰트 크기 작음 (12pt): 이 텍스트는 작은 폰트 크기로 ReadMoreLabel 기능을 보여줍니다. 컴팩트한 텍스트로 다양한 화면 크기와 접근성 설정에서 가독성을 유지하면서 더 많은 콘텐츠 밀도를 제공합니다.",
                style: .fontSizeSmall,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "📚 폰트 크기 중간 (18pt): 이 텍스트는 가독성과 콘텐츠 밀도 사이의 완벽한 균형을 제공하는 중간 폰트 크기로 ReadMoreLabel을 보여줍니다. 최신 모바일 애플리케이션의 대부분 표준 텍스트 콘텐츠에 완벽합니다.",
                style: .fontSizeMedium,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "📖 폰트 크기 큼 (24pt): 이 텍스트는 시각 장애가 있는 사용자나 시스템에서 접근성 기능이 활성화된 경우 뛰어난 가독성을 보장하는 큰 폰트 크기로 ReadMoreLabel을 보여줍니다.",
                style: .fontSizeLarge,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🎯 폰트 크기 매우 큼 (32pt): 이 텍스트는 헤드라인, 중요한 공지사항 또는 최대 가독성이 필요한 경우에 이상적인 매우 큰 폰트 크기로 ReadMoreLabel 기능을 보여줍니다.",
                style: .fontSizeXLarge,
                position: .end,
                language: "ko"
            ),
            
            // Font Size Testing - Japanese
            ReadMoreSampleData(
                text: "📝 フォントサイズ小 (12pt): このテキストは小さなフォントサイズでReadMoreLabel機能を示しています。コンパクトなテキストにより、さまざまな画面サイズとアクセシビリティ設定で可読性を維持しながら、より多くのコンテンツ密度を提供します。",
                style: .fontSizeSmall,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "📚 フォントサイズ中 (18pt): このテキストは可読性とコンテンツ密度の完璧なバランスを提供する中サイズのフォントでReadMoreLabelを紹介します。現代のモバイルアプリケーションの大部分の標準テキストコンテンツに最適です。",
                style: .fontSizeMedium,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "📖 フォントサイズ大 (24pt): このテキストは視覚障害のあるユーザーやシステムでアクセシビリティ機能が有効になっている場合に優れた可読性を保証する大きなフォントサイズでReadMoreLabelを示しています。",
                style: .fontSizeLarge,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "🎯 フォントサイズ特大 (32pt): このテキストは見出し、重要なお知らせ、または最大限の可読性が必要な場合に理想的な特大フォントサイズでReadMoreLabel機能を示しています。",
                style: .fontSizeXLarge,
                position: .end,
                language: "ja"
            )
        ]
        
        expandedStates = Array(repeating: false, count: sampleData.count)
    }
}

extension TableViewModel {
    // MARK: - Nested Types
    
    struct ReadMoreSampleData: Identifiable {
        let id = UUID()
        let text: String
        let style: Style
        let position: ReadMoreLabel.Position
        let language: String
        
        init(text: String, style: Style, position: ReadMoreLabel.Position, language: String) {
            self.text = text
            self.style = style
            self.position = position
            self.language = language
        }
    }

    // MARK: - ReadMoreLabel Style Extension

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
    
    // MARK: - StyleProvider
    
    class StyleProvider {
        
        // MARK: - Public Methods
        
        func getReadMoreTexts(for language: String, style: Style) -> (text: String, ellipsis: String) {
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
        
        func applyStyle(_ style: Style, to label: ReadMoreLabel, with data: TableViewModel.ReadMoreSampleData) {
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
}
