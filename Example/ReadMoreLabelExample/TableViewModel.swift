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
            // English Examples (6개) - 각 스타일별 균등 배치
            ReadMoreSampleData(
                text: "This is a clean English text that demonstrates the basic ReadMoreLabel functionality. The library provides an intuitive way to handle text truncation in iOS applications. Users can tap the button to reveal the complete content with smooth animations and excellent readability.",
                style: .basic,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "🎨 Colorful English styling example with vibrant colors and attractive underlines! This demonstrates the colorful style with newLine position where the button appears on a separate line. The colorful design adds visual appeal while maintaining clean layout separation and readability.",
                style: .colorful,
                position: .newLine,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "✨ English emoji example! 🚀 This ReadMoreLabel uses emoji bullets and styled text to create a visually appealing experience. Perfect for social media apps and modern interfaces. 📱💻🎨 The emoji style ensures engaging user interaction with colorful visual elements.",
                style: .emoji,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "This elegant gradient style provides sophisticated appearance with italic typography and teal colors. Perfect for modern iOS applications that require refined text handling capabilities. The gradient design offers a premium user experience with professional styling and smooth transitions.",
                style: .gradient,
                position: .newLine,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "🔥 BOLD English example! This demonstrates the bold style which makes important content stand out with maximum visibility. Perfect for headlines and announcements that need immediate user attention and strong visual impact.",
                style: .bold,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "📱 Mobile optimized English example with responsive design! This text demonstrates how ReadMoreLabel adapts to different screen sizes. The mobile style ensures optimal readability across all iOS devices with clean background highlighting and user-friendly interface design.",
                style: .mobile,
                position: .newLine,
                language: "en"
            ),

            // Korean Examples (6개) - 각 스타일별 균등 배치  
            ReadMoreSampleData(
                text: "한국어 기본 스타일 예제입니다! ReadMoreLabel이 한국어 텍스트 처리에서 어떻게 작동하는지 보여줍니다. 사용자는 버튼을 탭하여 전체 내용을 확인할 수 있으며, 부드러운 애니메이션과 함께 텍스트가 확장됩니다.",
                style: .basic,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🎨 컬러풀 한국어 스타일! 다채로운 색상과 밑줄이 있는 매력적인 디자인을 보여줍니다. 시각적 매력을 더하면서도 깔끔한 레이아웃을 유지하며, 현대적인 앱 디자인에 완벽하게 어울리는 스타일링을 제공합니다.",
                style: .colorful,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "✨ 이모지 한국어 예제! 🚀 다양한 이모지와 함께 텍스트가 올바르게 처리되는지 확인할 수 있습니다. 📱💻🎨 소셜미디어나 현대적인 인터페이스에 적합한 시각적으로 매력적인 사용자 경험을 제공합니다.",
                style: .emoji,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "세련된 그라데이션 스타일 한국어 예제입니다! 이탤릭 타이포그래피와 틸 색상으로 우아한 외관을 제공합니다. 정교한 텍스트 처리 기능이 필요한 현대적인 iOS 애플리케이션에 완벽하며, 프리미엄 사용자 경험을 선사합니다.",
                style: .gradient,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🔥 볼드 한국어 예제! 중요한 콘텐츠를 강조하여 최대한의 가시성을 제공하는 굵은 스타일을 보여줍니다. 헤드라인이나 공지사항처럼 즉각적인 사용자 관심이 필요한 경우에 완벽한 선택입니다.",
                style: .bold,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "📱 모바일 최적화 한국어 예제! 반응형 디자인으로 다양한 화면 크기에 적응하는 ReadMoreLabel을 보여줍니다. 깔끔한 배경 하이라이팅과 사용자 친화적인 인터페이스로 모든 iOS 기기에서 최적의 가독성을 보장합니다.",
                style: .mobile,
                position: .end,
                language: "ko"
            ),

            // Japanese Examples (6개) - 각 스타일별 균등 배치
            ReadMoreSampleData(
                text: "日本語の基本スタイル例です！ReadMoreLabelが日本語テキスト処理でどのように動作するかを示します。ユーザーはボタンをタップして完全な内容を確認でき、スムーズなアニメーションとともにテキストが展開されます。美しい表示を実現します。",
                style: .basic,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "🎨 カラフル日本語スタイル！多彩な色とアンダーラインを持つ魅力的なデザインを示しています。視覚的な魅力を追加しながらもきれいなレイアウトを維持し、現代的なアプリデザインに完璧にマッチするスタイリングを提供します。",
                style: .colorful,
                position: .newLine,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "✨ 絵文字日本語例！🚀 様々な絵文字とともにテキストが正しく処理されることを確認できます。📱💻🎨 ソーシャルメディアや現代的なインターフェースに適した視覚的に魅力的なユーザーエクスペリエンスを提供します。",
                style: .emoji,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "洗練されたグラデーションスタイル日本語例です！イタリックタイポグラフィとティール色で優雅な外観を提供します。精密なテキスト処理機能が必要な現代的なiOSアプリケーションに完璧で、プレミアムユーザーエクスペリエンスを提供します。",
                style: .gradient,
                position: .newLine,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "🔥 ボールド日本語例！重要なコンテンツを強調して最大限の可視性を提供する太字スタイルを示します。見出しやお知らせのような即座にユーザーの注意が必要な場合に完璧な選択です。強力な視覚的インパクトを与えます。",
                style: .bold,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "📱 モバイル最適化日本語例！レスポンシブデザインで様々なスクリーンサイズに適応するReadMoreLabelを示します。きれいな背景ハイライティングとユーザーフレンドリーなインターフェースで、すべてのiOSデバイスで最適な可読性を保証します。",
                style: .mobile,
                position: .newLine,
                language: "ja"
            ),

            // Arabic Examples (6개) - 각 스타일별 균등 배치, RTL 지원
            ReadMoreSampleData(
                text: "🇸🇦 مثال النمط الأساسي العربي! يُظهر كيفية عمل ReadMoreLabel مع معالجة النصوص العربية. يمكن للمستخدمين النقر على الزر لعرض المحتوى الكامل، وسيتوسع النص مع حركات سلسة. يحقق عرضاً جميلاً مع دعم كامل لاتجاه الكتابة من اليمين إلى اليسار.",
                style: .basic,
                position: .newLine,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "🎨 النمط الملون العربي! يُظهر تصميماً جذاباً بألوان متنوعة وتسطير جميل. يضيف جاذبية بصرية مع الحفاظ على تخطيط نظيف، ويوفر تصميماً يتماشى تماماً مع التطبيقات الحديثة ويدعم اتجاه الكتابة العربية بشكل مثالي.",
                style: .colorful,
                position: .end,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "✨ مثال الرموز التعبيرية العربي! 🚀 يمكن التحقق من معالجة النص بشكل صحيح مع رموز تعبيرية متنوعة. 📱💻🎨 يوفر تجربة مستخدم جذابة بصرياً مناسبة لوسائل التواصل الاجتماعي والواجهات الحديثة مع دعم RTL كامل.",
                style: .emoji,
                position: .newLine,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "مثال النمط المتدرج العربي الأنيق! يوفر مظهراً راقياً بخط مائل وألوان تيل جميلة. مثالي لتطبيقات iOS الحديثة التي تتطلب قدرات معالجة نصوص متطورة، ويوفر تجربة مستخدم متميزة مع دعم شامل للغة العربية.",
                style: .gradient,
                position: .end,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "🔥 مثال النمط الغامق العربي! يُظهر النمط الغامق الذي يبرز المحتوى المهم ويوفر أقصى قدر من الوضوح. خيار مثالي للعناوين والإعلانات التي تحتاج انتباه المستخدم الفوري مع تأثير بصري قوي ودعم RTL متكامل.",
                style: .bold,
                position: .newLine,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "📱 مثال الجوال المحسن العربي! يُظهر ReadMoreLabel المتكيف مع أحجام الشاشات المختلفة بتصميم متجاوب. يضمن قابلية قراءة مثلى عبر جميع أجهزة iOS مع إبراز خلفية نظيف وواجهة سهلة الاستخدام تدعم اتجاه الكتابة العربية بالكامل.",
                style: .mobile,
                position: .end,
                language: "ar"
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
        case basic      // 16pt font - 기본 스타일
        case colorful   // 16pt font - 컬러풀 스타일
        case emoji      // 15pt font - 이모지 스타일
        case gradient   // 16pt font - 그라데이션 스타일
        case bold       // 16pt font - 볼드 스타일
        case mobile     // 15pt font - 모바일 스타일
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
                // Arabic
            case ("ar", .basic):
                return ("اقرأ المزيد..", "..")
            case ("ar", .colorful):
                return ("🎨 اقرأ المزيد", "***")
            case ("ar", .emoji):
                return ("✨ المزيد", "...")
            case ("ar", .gradient):
                return ("← تابع القراءة", "~")
            case ("ar", .bold):
                return ("🔥 المزيد", "!!!")
            case ("ar", .mobile):
                return ("📱 اضغط للتوسيع", "...")
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
                label.font = UIFont.systemFont(ofSize: 15)
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
                label.font = UIFont.systemFont(ofSize: 15)
                label.readMoreText = NSAttributedString(
                    string: readMoreTexts.text,
                    attributes: [
                        .foregroundColor: UIColor.systemIndigo,
                        .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                        .backgroundColor: UIColor.systemIndigo.withAlphaComponent(0.1),
                    ]
                )
            }
        }
    }
}
