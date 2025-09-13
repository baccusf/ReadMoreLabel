//
//  LabelViewModel.swift
//  ReadMoreLabelExample
//
//  Created by Claude Code on 9/7/25.
//

import Foundation
import UIKit

@available(iOS 16.0, *)
class LabelViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var labelData: [ReadMoreLabelData] = []
    @Published var isAnimationEnabled: Bool = true
    
    // MARK: - Initialization
    
    init() {
        loadLabelData()
    }
    
    // MARK: - Public Methods
    
    func expandAll() {
        for index in labelData.indices {
            labelData[index].isExpanded = true
        }
    }
    
    func collapseAll() {
        for index in labelData.indices {
            labelData[index].isExpanded = false
        }
    }
    
    func toggleAnimation(_ enabled: Bool) {
        isAnimationEnabled = enabled
    }
    
    func updateExpandedState(for id: UUID, isExpanded: Bool) {
        if let index = labelData.firstIndex(where: { $0.id == id }) {
            labelData[index].isExpanded = isExpanded
        }
    }
    
    func hasAnyExpandedLabels() -> Bool {
        return labelData.contains { $0.isExpanded }
    }
    
    // MARK: - Private Methods
    
    private func loadLabelData() {
        labelData = [
            ReadMoreLabelData(
                text: "🇺🇸 This is a long English text that demonstrates the ReadMoreLabel functionality. When you tap the 'Read More' button, the text will expand to show the full content with smooth animation. The library supports multiple languages and provides a clean way to handle text truncation in your iOS applications. You can customize the appearance, animation, and behavior according to your needs.",
                readMoreText: NSAttributedString(
                    string: "Read More",
                    attributes: [.foregroundColor: UIColor.systemBlue]
                ),
                language: "en",
                isExpanded: false
            ),
            ReadMoreLabelData(
                text: "🇰🇷 이것은 ReadMoreLabel 기능을 보여주는 긴 한국어 텍스트입니다. '더보기' 버튼을 탭하면 부드러운 애니메이션과 함께 전체 텍스트가 확장됩니다. 이 라이브러리는 다국어를 지원하며 iOS 애플리케이션에서 텍스트 자르기를 깔끔하게 처리하는 방법을 제공합니다. 필요에 따라 모양, 애니메이션 및 동작을 사용자 정의할 수 있습니다.",
                readMoreText: NSAttributedString(
                    string: "더보기",
                    attributes: [.foregroundColor: UIColor.systemBlue]
                ),
                language: "ko",
                isExpanded: false
            ),
            ReadMoreLabelData(
                text: "🇯🇵 これはReadMoreLabelの機能を示す長い日本語のテキストです。「続きを読む」ボタンをタップすると、スムーズなアニメーションとともにテキスト全体が展開されます。このライブラリは多言語をサポートし、iOSアプリケーションでテキストの切り詰めをきれいに処理する方法を提供します。必要に応じて、外観、アニメーション、動作をカスタマイズできます。",
                readMoreText: NSAttributedString(
                    string: "続きを読む",
                    attributes: [.foregroundColor: UIColor.systemBlue]
                ),
                language: "ja",
                isExpanded: false
            ),
            ReadMoreLabelData(
                text: "🇸🇦 هذا نص عربي طويل يوضح وظائف ReadMoreLabel. عندما تضغط على زر 'اقرأ المزيد'، سيتوسع النص لإظهار المحتوى الكامل مع حركة سلسة. تدعم هذه المكتبة لغات متعددة وتوفر طريقة نظيفة للتعامل مع اقتطاع النص في تطبيقات iOS. يمكنك تخصيص المظهر والرسوم المتحركة والسلوك وفقًا لاحتياجاتك.",
                readMoreText: NSAttributedString(
                    string: "اقرأ المزيد",
                    attributes: [.foregroundColor: UIColor.systemBlue]
                ),
                language: "ar",
                isExpanded: false
            )
        ]
    }
}

extension LabelViewModel {
    // MARK: - Nested Types
    
    struct ReadMoreLabelData: Identifiable {
        let id = UUID()
        let text: String
        let readMoreText: NSAttributedString
        let language: String
        var isExpanded: Bool
        
        init(text: String, readMoreText: NSAttributedString, language: String, isExpanded: Bool) {
            self.text = text
            self.readMoreText = readMoreText
            self.language = language
            self.isExpanded = isExpanded
        }
    }
}
