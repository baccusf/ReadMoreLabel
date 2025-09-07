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
            ),

            // Font Size Testing Examples (12개) - 각 언어별 3개씩
            
            // English Font Size Examples (3개)
            ReadMoreSampleData(
                text: "📚 Font Size Medium (18pt): This text demonstrates ReadMoreLabel with a balanced medium font size that provides excellent readability and content density. Perfect for most standard text content in modern mobile applications with optimal user experience across devices.",
                style: .fontSizeMedium,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "📖 Font Size Large (25pt): This text showcases ReadMoreLabel with a large font size that ensures excellent readability for users with visual impairments or when accessibility features are enabled. The larger font provides enhanced visibility for improved user accessibility.",
                style: .fontSizeLarge,
                position: .newLine,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "🎯 Font Size Extra Large (32pt): This demonstrates ReadMoreLabel functionality with an extra large font size, ideal for headlines and announcements that require maximum readability and visual impact.",
                style: .fontSizeXLarge,
                position: .end,
                language: "en"
            ),

            // Korean Font Size Examples (3개)
            ReadMoreSampleData(
                text: "📚 폰트 크기 중간 (18pt): 이 텍스트는 가독성과 콘텐츠 밀도 사이의 완벽한 균형을 제공하는 중간 폰트 크기로 ReadMoreLabel을 보여줍니다. 최신 모바일 애플리케이션의 대부분 표준 텍스트 콘텐츠에 완벽하며 모든 기기에서 최적의 사용자 경험을 제공합니다.",
                style: .fontSizeMedium,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "📖 폰트 크기 큼 (25pt): 이 텍스트는 시각 장애가 있는 사용자나 시스템에서 접근성 기능이 활성화된 경우 뛰어난 가독성을 보장하는 큰 폰트 크기로 ReadMoreLabel을 보여줍니다. 더 큰 폰트는 향상된 사용자 접근성을 위한 뛰어난 가시성을 제공합니다.",
                style: .fontSizeLarge,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🎯 폰트 크기 매우 큼 (32pt): 이것은 헤드라인과 공지사항에서 최대 가독성과 시각적 임팩트가 필요한 경우 이상적인 매우 큰 폰트 크기로 ReadMoreLabel 기능을 보여줍니다.",
                style: .fontSizeXLarge,
                position: .newLine,
                language: "ko"
            ),

            // Japanese Font Size Examples (3개)
            ReadMoreSampleData(
                text: "📚 フォントサイズ中 (18pt): このテキストは可読性とコンテンツ密度の完璧なバランスを提供する中サイズのフォントでReadMoreLabelを紹介します。現代のモバイルアプリケーションの大部分の標準テキストコンテンツに最適で、すべてのデバイスで最適なユーザーエクスペリエンスを提供します。",
                style: .fontSizeMedium,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "📖 フォントサイズ大 (25pt): このテキストは視覚障害のあるユーザーやシステムでアクセシビリティ機能が有効になっている場合に優れた可読性を保証する大きなフォントサイズでReadMoreLabelを示します。より大きなフォントは向上したユーザーアクセシビリティのための優れた視認性を提供します。",
                style: .fontSizeLarge,
                position: .newLine,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "🎯 フォントサイズ特大 (32pt): これは見出しやお知らせで最大限の可読性と視覚的インパクトが必要な場合に理想的な特大フォントサイズでReadMoreLabel機能を示します。",
                style: .fontSizeXLarge,
                position: .end,
                language: "ja"
            ),

            // Arabic Font Size Examples (3개)
            ReadMoreSampleData(
                text: "📚 حجم الخط المتوسط (18pt): يُظهر هذا النص ReadMoreLabel بحجم خط متوسط يوفر توازناً ممتازاً بين قابلية القراءة وكثافة المحتوى. مثالي لمعظم محتوى النص القياسي في تطبيقات الهاتف المحمول الحديثة مع دعم كامل للغة العربية ويوفر تجربة مستخدم مثلى عبر جميع الأجهزة.",
                style: .fontSizeMedium,
                position: .newLine,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "📖 حجم الخط الكبير (25pt): يُظهر هذا النص ReadMoreLabel بحجم خط كبير يضمن قابلية قراءة ممتازة للمستخدمين ذوي الإعاقات البصرية أو عند تفعيل ميزات إمكانية الوصول في النظام. يوفر الخط الأكبر رؤية محسنة لإمكانية وصول محسنة للمستخدم مع دعم RTL كامل.",
                style: .fontSizeLarge,
                position: .end,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "🎯 حجم الخط الكبير جداً (32pt): يُظهر هذا وظيفة ReadMoreLabel بحجم خط كبير جداً، مثالي للعناوين والإعلانات التي تتطلب أقصى قابلية للقراءة وتأثير بصري قوي.",
                style: .fontSizeXLarge,
                position: .newLine,
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
        case basic          // 16pt font - 기본 스타일
        case colorful       // 16pt font - 컬러풀 스타일
        case emoji          // 15pt font - 이모지 스타일
        case gradient       // 16pt font - 그라데이션 스타일
        case bold           // 16pt font - 볼드 스타일
        case mobile         // 15pt font - 모바일 스타일
        case fontSizeMedium // 18pt font - 중간 폰트 크기
        case fontSizeLarge  // 25pt font - 큰 폰트 크기
        case fontSizeXLarge // 32pt font - 매우 큰 폰트 크기
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
                // Font Size Testing - English
            case ("en", .fontSizeMedium):
                return ("📚 Read More (18pt)", "..")
            case ("en", .fontSizeLarge):
                return ("📖 Read More (25pt)", "...")
            case ("en", .fontSizeXLarge):
                return ("🎯 Read More (32pt)", "....")
                // Font Size Testing - Korean
            case ("ko", .fontSizeMedium):
                return ("📚 더보기 (18pt)", "..")
            case ("ko", .fontSizeLarge):
                return ("📖 더보기 (25pt)", "...")
            case ("ko", .fontSizeXLarge):
                return ("🎯 더보기 (32pt)", "....")
                // Font Size Testing - Japanese
            case ("ja", .fontSizeMedium):
                return ("📚 もっと見る (18pt)", "..")
            case ("ja", .fontSizeLarge):
                return ("📖 もっと見る (25pt)", "...")
            case ("ja", .fontSizeXLarge):
                return ("🎯 もっと見る (32pt)", "....")
                // Font Size Testing - Arabic
            case ("ar", .fontSizeMedium):
                return ("📚 اقرأ المزيد (18pt)", "..")
            case ("ar", .fontSizeLarge):
                return ("📖 اقرأ المزيد (25pt)", "...")
            case ("ar", .fontSizeXLarge):
                return ("🎯 اقرأ المزيد (32pt)", "....")
                // Font size styles fallback to English for other languages
            case (_, .fontSizeMedium), (_, .fontSizeLarge), (_, .fontSizeXLarge):
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
                label.font = UIFont.systemFont(ofSize: 25)
                label.readMoreText = NSAttributedString(
                    string: readMoreTexts.text,
                    attributes: [
                        .foregroundColor: UIColor.systemOrange,
                        .font: UIFont.systemFont(ofSize: 25, weight: .bold),
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
