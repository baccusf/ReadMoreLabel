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
            // English Examples (9개) - 7-8줄 길이로 확장, position 균형 조정
            ReadMoreSampleData(
                text: "This is a comprehensive English text that demonstrates the basic ReadMoreLabel functionality in detail. The library provides an intuitive and powerful way to handle text truncation in modern iOS applications with advanced features. Users can easily tap the button to reveal the complete content with smooth animations, excellent readability, and seamless user experience. The basic style maintains clean typography while ensuring optimal performance across all device sizes and orientations.",
                style: .basic,
                position: .newLine,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "🎨 Colorful English styling example with vibrant colors, attractive underlines, and eye-catching visual elements! This comprehensive demonstration showcases the colorful style with end position where the button appears inline with the text. The colorful design adds significant visual appeal while maintaining clean layout separation, excellent readability, and professional appearance. Perfect for modern applications that require distinctive and memorable user interfaces with enhanced visual hierarchy.",
                style: .colorful,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "✨ Extended English emoji example with multiple decorative elements! 🚀 This comprehensive ReadMoreLabel implementation uses various emoji bullets and beautifully styled text to create a visually appealing and engaging user experience. Perfect for social media applications and modern interfaces that prioritize user engagement. 📱💻🎨 The emoji style ensures captivating user interaction with colorful visual elements, smooth animations, and responsive design that works flawlessly across all iOS devices and screen sizes.",
                style: .emoji,
                position: .newLine,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "This elegant and sophisticated gradient style provides a refined appearance with beautiful italic typography and carefully selected teal colors throughout the interface. Perfect for premium iOS applications that require advanced text handling capabilities and professional styling. The gradient design offers an exceptional premium user experience with meticulously crafted styling elements, smooth transitions, and elegant animations that enhance the overall application quality and user satisfaction significantly.",
                style: .gradient,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "🔥 BOLD and impactful English example with maximum visual prominence! This comprehensive demonstration showcases the bold style which makes critically important content stand out with exceptional visibility and strong visual impact. Perfect for headlines, announcements, and urgent communications that need immediate user attention and memorable presentation. The bold styling ensures maximum readability while maintaining professional appearance and excellent user experience across all iOS devices and usage scenarios.",
                style: .bold,
                position: .newLine,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "📱 Mobile optimized English example with comprehensive responsive design features! This detailed text demonstrates how ReadMoreLabel intelligently adapts to different screen sizes, orientations, and device configurations. The mobile style ensures optimal readability across all iOS devices with clean background highlighting, user-friendly interface design, and accessibility features. Perfect for applications that prioritize mobile-first design principles and exceptional user experience on both phones and tablets with seamless functionality.",
                style: .mobile,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "📚 Medium Font Size English demonstration (18pt) with enhanced readability features! This comprehensive text showcases ReadMoreLabel with a perfectly balanced medium font size that provides excellent readability and optimal content density for extended reading sessions. Ideal for most standard text content in modern mobile applications with superior user experience across all devices. The medium font size ensures comfortable reading while maximizing content visibility and maintaining professional appearance throughout the application interface.",
                style: .fontSizeMedium,
                position: .newLine,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "📖 Large Font Size English showcase (25pt) with accessibility-focused design! This detailed text demonstrates ReadMoreLabel with a large font size that ensures exceptional readability for users with visual impairments or when system accessibility features are enabled. The larger font provides enhanced visibility for improved user accessibility and comfort. Perfect for inclusive applications that prioritize universal design principles and ensure excellent user experience for all users regardless of their visual capabilities or preferences.",
                style: .fontSizeLarge,
                position: .end,
                language: "en"
            ),
            ReadMoreSampleData(
                text: "🎯 Extra Large Font Size English example (32pt) with maximum visual impact! This demonstrates ReadMoreLabel functionality with an extra large font size that's ideal for headlines, announcements, and promotional content that requires maximum readability and powerful visual presence. Perfect for marketing materials and important notifications that need to capture immediate user attention while maintaining excellent readability across all device sizes and viewing conditions.",
                style: .fontSizeXLarge,
                position: .newLine,
                language: "en"
            ),

            // Korean Examples (9개) - 7-8줄 길이로 확장, position 균형 조정
            ReadMoreSampleData(
                text: "종합적인 한국어 기본 스타일 예제입니다! ReadMoreLabel이 한국어 텍스트 처리에서 어떻게 뛰어나게 작동하는지 자세히 보여줍니다. 사용자는 버튼을 쉽게 탭하여 전체 내용을 확인할 수 있으며, 부드러운 애니메이션과 함께 텍스트가 아름답게 확장됩니다. 기본 스타일은 깔끔한 타이포그래피를 유지하면서도 모든 기기 크기와 방향에서 최적의 성능을 보장하여 우수한 사용자 경험을 제공합니다.",
                style: .basic,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🎨 다채로운 한국어 컬러풀 스타일 완전판! 생동감 넘치는 색상과 매력적인 밑줄, 시선을 사로잡는 시각적 요소들로 구성된 포괄적인 데모입니다. 이 종합적인 시연은 텍스트와 함께 인라인으로 버튼이 나타나는 end position의 컬러풀 스타일을 보여줍니다. 시각적 매력을 크게 더하면서도 깔끔한 레이아웃 분리와 뛰어난 가독성, 전문적인 외관을 유지합니다. 독특하고 기억에 남는 사용자 인터페이스가 필요한 현대적인 애플리케이션에 완벽합니다.",
                style: .colorful,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "✨ 확장된 한국어 이모지 예제! 🚀 이 포괄적인 ReadMoreLabel 구현은 다양한 이모지 불릿과 아름답게 스타일링된 텍스트를 사용하여 시각적으로 매력적이고 매력적인 사용자 경험을 만들어냅니다. 사용자 참여를 우선시하는 소셜미디어 애플리케이션과 현대적인 인터페이스에 완벽합니다. 📱💻🎨 이모지 스타일은 다채로운 시각적 요소, 부드러운 애니메이션, 모든 iOS 기기와 화면 크기에서 완벽하게 작동하는 반응형 디자인으로 매혹적인 사용자 상호작용을 보장합니다.",
                style: .emoji,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "우아하고 세련된 그라데이션 스타일은 아름다운 이탤릭 타이포그래피와 신중하게 선택된 틸 색상을 인터페이스 전체에 걸쳐 제공하여 세련된 외관을 선사합니다. 고급 텍스트 처리 기능과 전문적인 스타일링이 필요한 프리미엄 iOS 애플리케이션에 완벽합니다. 그라데이션 디자인은 세심하게 제작된 스타일링 요소, 부드러운 전환, 전반적인 애플리케이션 품질과 사용자 만족도를 크게 향상시키는 우아한 애니메이션으로 뛰어난 프리미엄 사용자 경험을 제공합니다.",
                style: .gradient,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🔥 강력하고 임팩트 있는 한국어 볼드 예제! 최대 시각적 돋보임을 자랑합니다! 이 포괄적인 데모는 매우 중요한 콘텐츠를 뛰어난 가시성과 강한 시각적 임팩트로 돋보이게 만드는 볼드 스타일을 보여줍니다. 헤드라인, 공지사항, 즉각적인 사용자 관심과 기억에 남는 프레젠테이션이 필요한 긴급 커뮤니케이션에 완벽합니다. 볼드 스타일링은 전문적인 외관과 모든 iOS 기기 및 사용 시나리오에서 뛰어난 사용자 경험을 유지하면서 최대 가독성을 보장합니다.",
                style: .bold,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "📱 포괄적인 반응형 디자인 기능을 갖춘 모바일 최적화 한국어 예제입니다! 이 상세한 텍스트는 ReadMoreLabel이 다양한 화면 크기, 방향, 기기 구성에 지능적으로 적응하는 방법을 보여줍니다. 모바일 스타일은 깔끔한 배경 하이라이팅, 사용자 친화적인 인터페이스 디자인, 접근성 기능을 통해 모든 iOS 기기에서 최적의 가독성을 보장합니다. 모바일 우선 디자인 원칙과 원활한 기능을 갖춘 폰과 태블릿 모두에서 뛰어난 사용자 경험을 우선시하는 애플리케이션에 완벽합니다.",
                style: .mobile,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "📚 향상된 가독성 기능을 갖춘 중간 폰트 크기 한국어 데모 (18pt)! 이 포괄적인 텍스트는 연장된 독서 세션을 위한 뛰어난 가독성과 최적의 콘텐츠 밀도를 제공하는 완벽하게 균형 잡힌 중간 폰트 크기로 ReadMoreLabel을 보여줍니다. 모든 기기에서 우수한 사용자 경험을 제공하는 현대적인 모바일 애플리케이션의 대부분 표준 텍스트 콘텐츠에 이상적입니다. 중간 폰트 크기는 애플리케이션 인터페이스 전반에 걸쳐 전문적인 외관을 유지하면서 콘텐츠 가시성을 최대화하고 편안한 독서를 보장합니다.",
                style: .fontSizeMedium,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "📖 접근성 중심 디자인을 갖춘 큰 폰트 크기 한국어 쇼케이스 (25pt)! 이 상세한 텍스트는 시각 장애가 있는 사용자나 시스템 접근성 기능이 활성화된 경우 뛰어난 가독성을 보장하는 큰 폰트 크기로 ReadMoreLabel을 보여줍니다. 더 큰 폰트는 향상된 사용자 접근성과 편안함을 위한 뛰어난 가시성을 제공합니다. 보편적 디자인 원칙을 우선시하고 시각적 능력이나 선호도에 관계없이 모든 사용자에게 뛰어난 사용자 경험을 보장하는 포용적인 애플리케이션에 완벽합니다.",
                style: .fontSizeLarge,
                position: .newLine,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "🎯 최대 시각적 임팩트를 자랑하는 매우 큰 폰트 크기 한국어 예제 (32pt)! 이는 헤드라인, 공지사항, 최대 가독성과 강력한 시각적 존재감이 필요한 홍보 콘텐츠에 이상적인 매우 큰 폰트 크기로 ReadMoreLabel 기능을 보여줍니다. 모든 기기 크기와 시청 조건에서 뛰어난 가독성을 유지하면서 즉각적인 사용자 관심을 끌어야 하는 마케팅 자료와 중요한 알림에 완벽합니다.",
                style: .fontSizeXLarge,
                position: .end,
                language: "ko"
            ),

            // Japanese Examples (9개) - 7-8줄 길이로 확장, position 균형 조정
            ReadMoreSampleData(
                text: "包括的な日本語基本スタイル例です！ReadMoreLabelが日本語テキスト処理で優れた動作をどのように詳細に示すかを紹介します。ユーザーは簡単にボタンをタップして完全な内容を確認でき、スムーズなアニメーションとともにテキストが美しく展開されます。基本スタイルは清潔なタイポグラフィを維持しながら、すべてのデバイスサイズと向きで最適なパフォーマンスを保証し、優れたユーザーエクスペリエンスを提供します。",
                style: .basic,
                position: .newLine,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "🎨 活気に満ちたカラフル日本語スタイル完全版！鮮やかな色彩、魅力的なアンダーライン、目を引く視覚要素で構成された包括的なデモンストレーションです。この総合的な実演は、ボタンがテキストとインラインで表示されるend positionのカラフルスタイルを示しています。視覚的魅力を大幅に向上させながら、清潔なレイアウト分離、優れた可読性、プロフェッショナルな外観を維持します。独特で記憶に残るユーザーインターフェースが必要な現代的なアプリケーションに完璧です。",
                style: .colorful,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "✨ 拡張された日本語絵文字例！🚀 この包括的なReadMoreLabel実装は、様々な絵文字弾丸と美しくスタイル化されたテキストを使用して、視覚的に魅力的で魅力的なユーザーエクスペリエンスを作り出します。ユーザーエンゲージメントを優先するソーシャルメディアアプリケーションと現代的なインターフェースに最適です。📱💻🎨 絵文字スタイルは、カラフルな視覚要素、スムーズなアニメーション、すべてのiOSデバイスと画面サイズで完璧に動作するレスポンシブデザインで魅力的なユーザーインタラクションを保証します。",
                style: .emoji,
                position: .newLine,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "エレガントで洗練されたグラデーションスタイルは、美しいイタリックタイポグラフィと慎重に選択されたティール色をインターフェース全体に提供し、洗練された外観を実現します。高度なテキスト処理機能とプロフェッショナルなスタイリングが必要なプレミアムiOSアプリケーションに完璧です。グラデーションデザインは、細心に作り込まれたスタイリング要素、スムーズな遷移、アプリケーション全体の品質とユーザー満足度を大幅に向上させるエレガントなアニメーションで、卓越したプレミアムユーザーエクスペリエンスを提供します。",
                style: .gradient,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "🔥 強力でインパクトのある日本語ボールド例！最大限の視覚的な目立ち度を誇ります！この包括的なデモンストレーションは、非常に重要なコンテンツを卓越した可視性と強い視覚的インパクトで際立たせるボールドスタイルを示しています。見出し、お知らせ、即座にユーザーの注意と記憶に残るプレゼンテーションが必要な緊急コミュニケーションに最適です。ボールドスタイリングは、プロフェッショナルな外観とすべてのiOSデバイスおよび使用シナリオでの優れたユーザーエクスペリエンスを維持しながら、最大限の可読性を保証します。",
                style: .bold,
                position: .newLine,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "📱 包括的なレスポンシブデザイン機能を備えたモバイル最適化日本語例！この詳細なテキストは、ReadMoreLabelが様々な画面サイズ、向き、デバイス構成にどのように知的に適応するかを示しています。モバイルスタイルは、きれいな背景ハイライティング、ユーザーフレンドリーなインターフェースデザイン、アクセシビリティ機能を通じて、すべてのiOSデバイスで最適な可読性を保証します。モバイルファーストのデザイン原則と、シームレスな機能性を備えた電話とタブレットの両方で優れたユーザーエクスペリエンスを優先するアプリケーションに最適です。",
                style: .mobile,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "📚 拡張された可読性機能を備えた中サイズフォント日本語デモ（18pt）！この包括的なテキストは、長時間の読書セッションに優れた可読性と最適なコンテンツ密度を提供する完璧にバランスの取れた中サイズフォントでReadMoreLabelを紹介します。すべてのデバイスで優れたユーザーエクスペリエンスを提供する現代的なモバイルアプリケーションの大部分の標準テキストコンテンツに理想的です。中サイズフォントは、アプリケーションインターフェース全体でプロフェッショナルな外観を維持しながら、コンテンツの可視性を最大化し、快適な読書を保証します。",
                style: .fontSizeMedium,
                position: .newLine,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "📖 アクセシビリティ重視設計を備えた大フォント日本語ショーケース（25pt）！この詳細なテキストは、視覚障害のあるユーザーやシステムアクセシビリティ機能が有効になっている場合に優れた可読性を保証する大フォントでReadMoreLabelを示しています。より大きなフォントは、向上したユーザーアクセシビリティと快適さのための優れた視認性を提供します。ユニバーサルデザイン原則を優先し、視覚能力や好みに関係なくすべてのユーザーに優れたユーザーエクスペリエンスを保証するインクルーシブなアプリケーションに完璧です。",
                style: .fontSizeLarge,
                position: .end,
                language: "ja"
            ),
            ReadMoreSampleData(
                text: "🎯 最大限の視覚的インパクトを誇る特大フォント日本語例（32pt）！これは見出し、お知らせ、最大限の可読性と強力な視覚的存在感が必要なプロモーションコンテンツに理想的な特大フォントでReadMoreLabel機能を示しています。すべてのデバイスサイズと視聴条件で優れた可読性を維持しながら、即座にユーザーの注意を引く必要があるマーケティング資料と重要な通知に完璧です。",
                style: .fontSizeXLarge,
                position: .newLine,
                language: "ja"
            ),

            // Arabic Examples (9개) - 7-8줄 길이로 확장, position 균형 조정, RTL 지원
            ReadMoreSampleData(
                text: "🇸🇦 مثال شامل للنمط الأساسي العربي! يُظهر بالتفصيل كيفية عمل ReadMoreLabel مع معالجة النصوص العربية بطريقة ممتازة. يمكن للمستخدمين بسهولة النقر على الزر لعرض المحتوى الكامل، وسيتوسع النص بشكل جميل مع حركات سلسة ورائعة. النمط الأساسي يحافظ على طباعة نظيفة بينما يضمن الأداء الأمثل عبر جميع أحجام الأجهزة والاتجاهات، مما يوفر تجربة مستخدم متميزة مع دعم كامل لاتجاه الكتابة من اليمين إلى اليسار.",
                style: .basic,
                position: .end,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "🎨 النسخة الكاملة من النمط الملون العربي النابض بالحياة! تصميم جذاب بألوان زاهية، تسطير ساحر، وعناصر بصرية تلفت الأنظار في عرض شامل ومتكامل. هذا العرض التوضيحي الشامل يُظهر النمط الملون مع موضع newLine حيث يظهر الزر في سطر منفصل. يضيف جاذبية بصرية كبيرة مع الحفاظ على فصل تخطيط نظيف وقابلية قراءة ممتازة ومظهر احترافي. مثالي للتطبيقات الحديثة التي تتطلب واجهات مستخدم مميزة ولا تُنسى مع تسلسل هرمي بصري محسّن ودعم كامل لاتجاه الكتابة العربية.",
                style: .colorful,
                position: .newLine,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "✨ مثال موسع للرموز التعبيرية العربية مع عناصر زخرفية متعددة! 🚀 هذا التطبيق الشامل لـ ReadMoreLabel يستخدم رموز تعبيرية متنوعة ونصوص مصممة بشكل جميل لخلق تجربة مستخدم جذابة بصرياً ومثيرة للاهتمام. مثالي لتطبيقات وسائل التواصل الاجتماعي والواجهات الحديثة التي تعطي الأولوية لمشاركة المستخدمين. 📱💻🎨 نمط الرموز التعبيرية يضمن تفاعل مستخدم آسر مع عناصر بصرية ملونة وحركات سلسة وتصميم متجاوب يعمل بشكل مثالي عبر جميع أجهزة iOS وأحجام الشاشات مع دعم كامل لاتجاه الكتابة من اليمين إلى اليسار.",
                style: .emoji,
                position: .end,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "النمط المتدرج العربي الأنيق والمتطور يوفر مظهراً راقياً مع طباعة مائلة جميلة وألوان تيل مختارة بعناية في جميع أنحاء الواجهة. مثالي لتطبيقات iOS المتميزة التي تتطلب قدرات معالجة نصوص متقدمة وتصميم احترافي. تصميم التدرج يوفر تجربة مستخدم متميزة استثنائية مع عناصر تصميم مصنوعة بدقة، انتقالات سلسة، وحركات أنيقة تعزز جودة التطبيق الإجمالية ورضا المستخدمين بشكل كبير مع دعم شامل للغة العربية واتجاه الكتابة من اليمين إلى اليسار.",
                style: .gradient,
                position: .newLine,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "🔥 مثال عربي غامق قوي ومؤثر! يتمتع بأقصى درجات البروز البصري! هذا العرض التوضيحي الشامل يُظهر النمط الغامق الذي يجعل المحتوى المهم جداً يبرز بوضوح استثنائي وتأثير بصري قوي. مثالي للعناوين والإعلانات والاتصالات الطارئة التي تحتاج إلى انتباه فوري للمستخدم وعرض لا يُنسى. التصميم الغامق يضمن أقصى قابلية للقراءة مع الحفاظ على المظهر المهني وتجربة مستخدم ممتازة عبر جميع أجهزة iOS وسيناريوهات الاستخدام مع دعم كامل لاتجاه الكتابة من اليمين إلى اليسار.",
                style: .bold,
                position: .end,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "📱 مثال الجوال المحسن العربي مع ميزات التصميم المتجاوب الشاملة! يُظهر هذا النص التفصيلي كيف يتكيف ReadMoreLabel بذكاء مع أحجام الشاشات المختلفة والاتجاهات وتكوينات الأجهزة المتنوعة. النمط المحمول يضمن قابلية قراءة مثلى عبر جميع أجهزة iOS مع إبراز خلفية نظيف وتصميم واجهة سهل الاستخدام وميزات إمكانية الوصول. مثالي للتطبيقات التي تعطي الأولوية لمبادئ التصميم المحمول أولاً وتجربة مستخدم استثنائية على كل من الهواتف والأجهزة اللوحية مع وظائف سلسة ودعم كامل لاتجاه الكتابة العربية.",
                style: .mobile,
                position: .newLine,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "📚 عرض توضيحي عربي بحجم خط متوسط مع ميزات قابلية قراءة محسنة (18pt)! يُظهر هذا النص الشامل ReadMoreLabel بحجم خط متوسط متوازن تماماً يوفر قابلية قراءة ممتازة وكثافة محتوى مثلى لجلسات القراءة الممتدة. مثالي لمعظم محتوى النص القياسي في تطبيقات الهاتف المحمول الحديثة مع تجربة مستخدم فائقة عبر جميع الأجهزة. حجم الخط المتوسط يضمن قراءة مريحة مع تعظيم رؤية المحتوى والحفاظ على المظهر المهني في جميع أنحاء واجهة التطبيق مع دعم كامل لاتجاه الكتابة العربية.",
                style: .fontSizeMedium,
                position: .end,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "📖 عرض عربي بخط كبير مع تصميم يركز على إمكانية الوصول (25pt)! يُظهر هذا النص التفصيلي ReadMoreLabel بحجم خط كبير يضمن قابلية قراءة استثنائية للمستخدمين ذوي الإعاقات البصرية أو عندما تكون ميزات إمكانية الوصول في النظام مفعلة. يوفر الخط الأكبر رؤية محسنة لإمكانية الوصول المحسنة للمستخدم والراحة. مثالي للتطبيقات الشاملة التي تعطي الأولوية لمبادئ التصميم الشامل وتضمن تجربة مستخدم ممتازة لجميع المستخدمين بغض النظر عن قدراتهم أو تفضيلاتهم البصرية مع دعم كامل لاتجاه الكتابة العربية.",
                style: .fontSizeLarge,
                position: .newLine,
                language: "ar"
            ),
            ReadMoreSampleData(
                text: "🎯 مثال عربي بخط كبير جداً مع أقصى تأثير بصري (32pt)! يُظهر هذا وظيفة ReadMoreLabel بحجم خط كبير جداً مثالي للعناوين والإعلانات والمحتوى الترويجي الذي يتطلب أقصى قابلية للقراءة ووجود بصري قوي. مثالي للمواد التسويقية والإشعارات المهمة التي تحتاج إلى جذب انتباه المستخدم الفوري مع الحفاظ على قابلية قراءة ممتازة عبر جميع أحجام الأجهزة وظروف المشاهدة مع دعم كامل لاتجاه الكتابة من اليمين إلى اليسار.",
                style: .fontSizeXLarge,
                position: .end,
                language: "ar"
            ),
            
            // 엣지 케이스
            ReadMoreSampleData(
                text: "1\n2\n🚀🔥💯 이모지가 포함된 텍스트 예제입니다! ",
                style: .mobile,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "1\n2\n3\n🚀🔥💯 이모지가 포함된 텍스트 예제입니다! ",
                style: .mobile,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "\n\n\n🚀🔥💯 이모지가 포함된 텍스트 예제입니다! ",
                style: .mobile,
                position: .end,
                language: "ko"
            ),
            ReadMoreSampleData(
                text: "1\n2\n🚀🔥💯 이모지가 포함된 텍스트 예제입니다! 🎉✨🌟 ReadMoreLabel은 복잡한 유니코드 문자도 정확하게 처리할 수 있습니다.",
                style: .mobile,
                position: .end,
                language: "ko"
            ),
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
                return ("اقرأ المزيد..", "...")
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
