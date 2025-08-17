import UIKit

@available(iOS 16.0, *)
@objc public protocol ReadMoreLabelDelegate: AnyObject {
    @objc optional func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool)
}

/// UILabel with "Read More" functionality for truncated text
@available(iOS 16.0, *)
@objc @IBDesignable
public class ReadMoreLabel: UILabel {
    
    @objc public enum Position: Int {
        case end = 0
        case beginningNewLine = 1
    }
    
    // MARK: - Public Properties
    
    @objc public weak var delegate: ReadMoreLabelDelegate?
    
    private var numberOfLinesWhenCollapsed: Int = 3 {
        didSet {
            let finalValue = max(0, numberOfLinesWhenCollapsed)
            if finalValue != numberOfLinesWhenCollapsed {
                numberOfLinesWhenCollapsed = finalValue
                return
            }
            invalidateDisplayAndLayout()
        }
    }
    
    @objc public var readMoreText: NSAttributedString = NSAttributedString(string: "더보기..") {
        didSet {
            invalidateDisplayAndLayout()
        }
    }
    
    @IBInspectable public var ellipsisText: String = ".." {
        didSet {
            invalidateDisplayAndLayout()
        }
    }
    
    @objc public var readMorePosition: Position = .end {
        didSet {
            invalidateDisplayAndLayout()
        }
    }
    @objc public private(set) var isExpanded: Bool = false
    
    @objc public var isExpandable: Bool {
        guard numberOfLinesWhenCollapsed > 0,
              let readMoreTextRange = readMoreTextRange else {
            return false
        }
        return readMoreTextRange.length > 0
    }
    
    // MARK: - Private Properties
    
    private var readMoreTextRange: NSRange?
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var originalAttributedText: NSAttributedString?
    private var internalNumberOfLines: Int = 0
    
    // 캐시 시스템
    private var cachedIsExpandable: Bool?
    private var cachedExpandableKey: String?
    private var lastLayoutBounds: CGRect = .zero
    
    // TextKit 재사용을 위한 캐시
    private var reusableTextLayoutManager: NSTextLayoutManager?
    private var reusableTextContainer: NSTextContainer?
    private var reusableTextContentStorage: NSTextContentStorage?
    
    // 상수 정의
    private static let defaultFallbackWidth: CGFloat = 300.0
    private static let animationDuration: TimeInterval = 0.3
       
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    // MARK: - Setup
    
    private func setupLabel() {
        setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
        lineBreakMode = .byClipping
        isUserInteractionEnabled = true
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer = tapGesture
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    
    @objc public func expand() {
        setExpanded(true, animated: true)
    }
    
    @objc public func collapse() {
        setExpanded(false, animated: true)
    }
    
    @objc public func setExpanded(_ expanded: Bool, animated: Bool) {
        // 확장하려는 경우 isExpandable 체크, 축소하려는 경우는 항상 허용
        guard expanded == false || isExpandable else { return }
        
        // 같은 상태로 변경하려는 경우 early return
        guard expanded != isExpanded else { return }
        
        isExpanded = expanded
        updateDisplay()
        
        if animated {
            UIView.animate(withDuration: Self.animationDuration) {
                self.invalidateIntrinsicContentSize()
            }
        } else {
            invalidateDisplayAndLayout()
        }
        
        delegate?.readMoreLabel?(self, didChangeExpandedState: isExpanded)
    }
    
    @objc public func prepareForCellReuse() {
        invalidateExpandableCache()
        if isExpanded {
            setExpanded(false, animated: false)
        }
    }
    
    // MARK: - TextKit 2 Implementation
    
    /// 텍스트 자르기 결과 열거형
    private enum TextTruncationResult {
        case noTruncationNeeded
        case truncated(NSAttributedString, NSRange)
        
        /// 자르기가 필요한지 여부
        var needsTruncation: Bool {
            switch self {
            case .noTruncationNeeded:
                return false
            case .truncated:
                return true
            }
        }
        
        /// 최종 텍스트와 더보기 범위 추출
        var textAndRange: (NSAttributedString, NSRange?)? {
            switch self {
            case .noTruncationNeeded:
                return nil
            case .truncated(let text, let range):
                return (text, range)
            }
        }
    }
    private func applyReadMoreWithTextKit2(
        originalText: NSAttributedString,
        numberOfLines: Int,
        containerWidth: CGFloat,
        suffix: NSAttributedString
    ) -> TextTruncationResult {
        
        let suffixWidth = measureSuffixWidth(suffix: suffix)
        let (textLayoutManager, textContainer, textContentStorage) = getReusableTextKit(
            containerWidth: containerWidth,
            attributedText: applyTextAlignment(to: originalText)
        )
        
        textLayoutManager.ensureLayout(for: textLayoutManager.documentRange)
        
        let alignedText = applyTextAlignment(to: originalText)
        let lineAnalysis = analyzeTextLines(
            textLayoutManager: textLayoutManager,
            targetLineCount: numberOfLines
        )
        
        guard lineAnalysis.totalLineCount >= numberOfLines,
              let targetFragment = lineAnalysis.targetFragment else {
            return .noTruncationNeeded
        }
        
        let truncateLocation = calculateTruncateLocation(
            targetFragment: targetFragment,
            containerWidth: containerWidth,
            suffixWidth: suffixWidth,
            textLayoutManager: textLayoutManager,
            alignedText: alignedText
        )
        
        guard let truncateLoc = truncateLocation else {
            return .noTruncationNeeded
        }
        
        let truncateOffset = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: truncateLoc)
        let truncatedText = originalText.attributedSubstring(from: NSRange(location: 0, length: truncateOffset))
        
        // 줄바꿈 문자로 끝나는 경우 제거 (suffix가 다음 줄로 이동하는 것 방지)
        let cleanedTruncatedText = NSMutableAttributedString(attributedString: truncatedText)
        if cleanedTruncatedText.string.hasSuffix("\n") {
            let newLength = cleanedTruncatedText.length - 1
            cleanedTruncatedText.deleteCharacters(in: NSRange(location: newLength, length: 1))
        }
        
        let finalText = NSMutableAttributedString(attributedString: cleanedTruncatedText)
        finalText.append(suffix)
        
        let readMoreRange = NSRange(location: cleanedTruncatedText.length, length: suffix.length)
        
        return .truncated(finalText, readMoreRange)
    }
    
    private func findOptimalTruncateLocationInline(
        in range: NSTextRange,
        availableWidth: CGFloat,
        textLayoutManager: NSTextLayoutManager
    ) -> NSTextLocation {
        
        let rangeStartOffset = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: range.location)
        let rangeEndOffset = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: range.endLocation)
        
        let fullLineWidth = measureTextWidth(in: range, textLayoutManager: textLayoutManager)
        
        if fullLineWidth <= availableWidth {
            return range.endLocation
        }
        
        let totalLength = rangeEndOffset - rangeStartOffset
        for truncateLength in (1...totalLength).reversed() {
            guard let truncateLocation = textLayoutManager.location(range.location, offsetBy: truncateLength) else {
                continue
            }
            
            guard let testRange = NSTextRange(location: range.location, end: truncateLocation) else {
                continue
            }
            
            let testWidth = measureTextWidth(in: testRange, textLayoutManager: textLayoutManager)
            
            if testWidth <= availableWidth {
                return truncateLocation
            }
        }
        
        return textLayoutManager.location(range.location, offsetBy: 1) ?? range.location
    }
    
    private func measureTextWidth(in range: NSTextRange, textLayoutManager: NSTextLayoutManager) -> CGFloat {
        var totalWidth: CGFloat = 0
        
        textLayoutManager.enumerateTextSegments(in: range, type: .standard, options: []) { 
            segmentRange, segmentFrame, baselineOffset, textContainer in
            totalWidth += segmentFrame.width
            return true
        }
        
        return totalWidth
    }
    
    private func createReadMoreSuffix(from originalText: NSAttributedString) -> NSAttributedString {
        let lastAttributes = originalText.length > 0 ?
            originalText.attributes(at: originalText.length - 1, effectiveRange: nil) :
            defaultTextAttributes
        
        let suffix = NSMutableAttributedString()
        
        suffix.append(NSAttributedString(string: ellipsisText, attributes: lastAttributes))
        suffix.append(NSAttributedString(string: " ", attributes: lastAttributes))
        suffix.append(readMoreText)
        
        return suffix
    }
    
    private func measureSuffixWidth(suffix: NSAttributedString) -> CGFloat {
        let (suffixLayoutManager, _, _) = getReusableTextKit(
            containerWidth: .greatestFiniteMagnitude,
            attributedText: suffix
        )
                
        var totalWidth: CGFloat = 0
        
        suffixLayoutManager.enumerateTextSegments(
            in: suffixLayoutManager.documentRange,
            type: .standard,
            options: []
        ) { _, frame, _, _ in
            totalWidth += frame.width
            return true
        }
        
        return totalWidth
    }
    
    // MARK: - Utility Methods
        
    private func setInternalNumberOfLines(_ lines: Int) {
        internalNumberOfLines = lines
        super.numberOfLines = lines
    }
    
    // MARK: - TextKit Helper Methods
    
    /// 라인 분석 결과 구조체
    private struct LineAnalysisResult {
        let totalLineCount: Int
        let targetFragment: NSTextLineFragment?
        let allFragments: [NSTextLineFragment]
    }
    
    /// TextKit 컴포넌트 재사용 헬퍼
    /// - Parameters:
    ///   - containerWidth: 컨테이너 너비
    ///   - attributedText: 표시할 속성 문자열
    /// - Returns: 재사용 가능한 TextKit 컴포넌트 튜플
    /// - Note: 성능 최적화를 위해 TextKit 객체를 재사용하며, 설정이 변경된 경우에만 새로 생성
    private func getReusableTextKit(
        containerWidth: CGFloat,
        attributedText: NSAttributedString
    ) -> (NSTextLayoutManager, NSTextContainer, NSTextContentStorage) {
        
        // 텍스트 컨테이너 설정
        let textContainer: NSTextContainer
        if let reusableContainer = reusableTextContainer {
            reusableContainer.size = CGSize(width: containerWidth, height: .greatestFiniteMagnitude)
            textContainer = reusableContainer
        } else {
            textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))
            reusableTextContainer = textContainer
        }
        
        textContainer.lineFragmentPadding = self.lineFragmentPadding
        textContainer.maximumNumberOfLines = 0
        textContainer.lineBreakMode = self.lineBreakMode
        
        // 레이아웃 매니저 설정
        let textLayoutManager: NSTextLayoutManager
        if let reusableManager = reusableTextLayoutManager {
            textLayoutManager = reusableManager
        } else {
            textLayoutManager = NSTextLayoutManager()
            reusableTextLayoutManager = textLayoutManager
        }
        textLayoutManager.textContainer = textContainer
        
        // 텍스트 스토리지 설정
        let textContentStorage: NSTextContentStorage
        if let reusableStorage = reusableTextContentStorage {
            reusableStorage.attributedString = attributedText
            textContentStorage = reusableStorage
        } else {
            textContentStorage = NSTextContentStorage()
            textContentStorage.attributedString = attributedText
            reusableTextContentStorage = textContentStorage
        }
        
        // 연결이 끊어진 경우 다시 연결
        if !textContentStorage.textLayoutManagers.contains(textLayoutManager) {
            textContentStorage.addTextLayoutManager(textLayoutManager)
        }
        
        return (textLayoutManager, textContainer, textContentStorage)
    }
    
    /// 텍스트 라인 분석
    /// - Parameters:
    ///   - textLayoutManager: 텍스트 레이아웃 매니저
    ///   - targetLineCount: 대상 라인 수
    /// - Returns: 라인 분석 결과 (총 라인 수, 대상 라인 프래그먼트, 모든 프래그먼트)
    /// - Note: TextKit 2의 enumerateTextLayoutFragments를 사용하여 정확한 라인 계산
    private func analyzeTextLines(
        textLayoutManager: NSTextLayoutManager,
        targetLineCount: Int
    ) -> LineAnalysisResult {
        
        var totalLineCount = 0
        var targetFragment: NSTextLineFragment?
        var allFragments: [NSTextLineFragment] = []
        
        textLayoutManager.enumerateTextLayoutFragments(
            from: textLayoutManager.documentRange.location,
            options: [.ensuresLayout]
        ) { layoutFragment in
            let lineFragments = layoutFragment.textLineFragments
            totalLineCount += lineFragments.count
            
            allFragments.append(contentsOf: lineFragments)
            
            if allFragments.count >= targetLineCount && targetFragment == nil {
                targetFragment = allFragments[targetLineCount - 1]
            }
            
            return true
        }
        
        return LineAnalysisResult(
            totalLineCount: totalLineCount,
            targetFragment: targetFragment,
            allFragments: allFragments
        )
    }
    
    /// 자르기 위치 계산
    /// - Parameters:
    ///   - targetFragment: 대상 라인 프래그먼트
    ///   - containerWidth: 컨테이너 너비
    ///   - suffixWidth: suffix 문자열 너비
    ///   - textLayoutManager: 텍스트 레이아웃 매니저
    ///   - alignedText: 정렬된 텍스트
    /// - Returns: 최적의 자르기 위치 또는 nil
    /// - Note: 줄바꿈 문자 처리와 suffix 공간 확보를 고려한 정밀한 계산
    private func calculateTruncateLocation(
        targetFragment: NSTextLineFragment,
        containerWidth: CGFloat,
        suffixWidth: CGFloat,
        textLayoutManager: NSTextLayoutManager,
        alignedText: NSAttributedString
    ) -> NSTextLocation? {
        
        let currentLineWidth = targetFragment.typographicBounds.width
        let characterRange = targetFragment.characterRange
        let targetLineText = alignedText.attributedSubstring(from: NSRange(location: characterRange.location, length: characterRange.length))
        let endsWithNewline = targetLineText.string.hasSuffix("\n")
        
        let availableWidth: CGFloat
        if endsWithNewline {
            // 줄바꿈으로 끝나는 경우, 전체 컨테이너 너비에서 suffix 공간 확보
            availableWidth = containerWidth - suffixWidth
        } else if currentLineWidth + suffixWidth <= containerWidth {
            availableWidth = currentLineWidth
        } else {
            availableWidth = containerWidth - suffixWidth
        }
        
        guard let lineStartLocation = textLayoutManager.location(textLayoutManager.documentRange.location, offsetBy: characterRange.location),
              let lineEndLocation = textLayoutManager.location(textLayoutManager.documentRange.location, offsetBy: characterRange.location + characterRange.length),
              let lineRange = NSTextRange(location: lineStartLocation, end: lineEndLocation) else {
            return nil
        }
        
        return findOptimalTruncateLocationInline(
            in: lineRange,
            availableWidth: availableWidth,
            textLayoutManager: textLayoutManager
        )
    }
    
    /// 탭 제스처용 TextKit 설정 (TextKit 1 사용)
    /// - Parameters:
    ///   - attributedText: 속성 문자열
    ///   - containerWidth: 컨테이너 너비
    /// - Returns: TextKit 1 컴포넌트 튜플
    /// - Note: 탭 제스처 인식을 위해 TextKit 1을 사용 (characterIndex 메서드 지원)
    private func createTapGestureTextKit(
        attributedText: NSAttributedString,
        containerWidth: CGFloat
    ) -> (NSLayoutManager, NSTextContainer, NSTextStorage) {
        
        let textStorage = NSTextStorage(attributedString: attributedText)
        let textContainer = NSTextContainer(size: CGSize(width: containerWidth, height: .greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = self.lineFragmentPadding
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLinesWhenCollapsed
        
        return (layoutManager, textContainer, textStorage)
    }
    
    // MARK: - Private Methods
    
    private func updateDisplay() {
        guard let attributedTextToDisplay = originalAttributedText, case let availableWidth = bounds.width, availableWidth > 0 else {
            return
        }
        
        // numberOfLinesWhenCollapsed가 0이면 일반 UILabel처럼 동작
        if numberOfLinesWhenCollapsed == 0 || isExpanded {
            super.attributedText = attributedTextToDisplay
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
            return
        }
        
        // 직접 truncation 처리 - 중복 계산 없이 한 번에 처리
        switch readMorePosition {
        case .end:
            displayTruncatedTextAtEnd(attributedTextToDisplay, availableWidth: availableWidth)
        case .beginningNewLine:
            break
        }
    }
    
    private func displayTruncatedTextAtEnd(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
        guard attributedText.length > 0 && availableWidth > 0 && numberOfLinesWhenCollapsed > 0 else {
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
            return
        }
        
        let suffix = createReadMoreSuffix(from: attributedText)
        
        let result = applyReadMoreWithTextKit2(
            originalText: attributedText,
            numberOfLines: numberOfLinesWhenCollapsed,
            containerWidth: availableWidth,
            suffix: suffix
        )
            
        if result.needsTruncation,
           let (finalText, readMoreRange) = result.textAndRange {
            // 텍스트가 잘린 경우
            super.attributedText = finalText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed)
            readMoreTextRange = readMoreRange
        } else {
            // 자르기가 필요하지 않은 경우
            super.attributedText = attributedText
            setInternalNumberOfLines(numberOfLinesWhenCollapsed == 0 ? 0 : numberOfLinesWhenCollapsed)
            readMoreTextRange = nil
        }
    }
    
    
    private func invalidateExpandableCache() {
        cachedIsExpandable = nil
        cachedExpandableKey = nil
    }
    
    private func invalidateDisplayAndLayout() {
        invalidateExpandableCache()
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        lastLayoutBounds = .zero // 레이아웃 캐시 무효화
    }
    
    private func generateExpandableCacheKey(text: String, width: CGFloat) -> String {
        let components = [
            text,
            "\(width)",
            "\(numberOfLinesWhenCollapsed)",
            "\(readMorePosition.rawValue)",
            readMoreText.string,
            ellipsisText,
            font?.fontName ?? "default",
            "\(font?.pointSize ?? 17)"
        ]
        
        let combined = components.joined(separator: "|")
        return String(combined.hashValue)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard isExpandable, let attributedText = attributedText, let readMoreRange = readMoreTextRange else {
            return
        }
        
        guard !isExpanded else {
            return
        }
        
        let locationInLabel = gesture.location(in: self)
        
        // TextKit 설정 - 탭 인식용
        guard attributedText.length > 0 && bounds.width > 0 else {
            return
        }
        
        let (layoutManager, textContainer, _) = createTapGestureTextKit(
            attributedText: attributedText,
            containerWidth: bounds.width
        )
        
        let characterIndex = layoutManager.characterIndex(for: locationInLabel, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        if NSLocationInRange(characterIndex, readMoreRange) {
            setExpanded(true, animated: true)
        }
    }
    
    // MARK: - Overrides
    
    public override var numberOfLines: Int {
        get {
            return numberOfLinesWhenCollapsed
        }
        set {
            numberOfLinesWhenCollapsed = newValue
        }
    }
    
    public override var lineBreakMode: NSLineBreakMode {
        didSet {
            updateDisplay()
        }
    }
    
    public override var text: String? {
        didSet {
            setOriginalText(NSAttributedString(string: text ?? ""))
        }
    }
    
    public override var attributedText: NSAttributedString? {
        get {
            return super.attributedText
        }
        set {
            setOriginalText(newValue ?? NSAttributedString())
        }
    }
    
    /// 원본 텍스트 설정 공통 로직
    /// - Parameter text: 설정할 속성 문자열
    /// - Note: 텍스트 정렬 적용, 캐시 무효화, 디스플레이 업데이트를 일괄 처리
    private func setOriginalText(_ text: NSAttributedString) {
        originalAttributedText = applyTextAlignment(to: text)
        invalidateDisplayAndLayout()
        updateDisplay()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // 크기 변경이 있을 때만 업데이트
        if bounds != lastLayoutBounds {
            lastLayoutBounds = bounds
            if bounds.width > 0 {
                invalidateExpandableCache()
                updateDisplay()
            }
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let attributedText = attributedText, attributedText.length > 0 else {
            return super.intrinsicContentSize
        }
        
        let width = bounds.width > 0 ? bounds.width : Self.defaultFallbackWidth
        let size = attributedText.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).size
        
        return CGSize(width: size.width, height: size.height)
    }
    
    private var lineFragmentPadding: CGFloat {
        return 0.0
    }
    
    private var defaultTextAttributes: [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = font
        attributes[.foregroundColor] = textColor
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 0
        paragraphStyle.lineHeightMultiple = 0
        paragraphStyle.paragraphSpacing = 0
        paragraphStyle.paragraphSpacingBefore = 0
        paragraphStyle.lineBreakMode = self.lineBreakMode
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.usesDefaultHyphenation = false
        
        attributes[.paragraphStyle] = paragraphStyle
        
        return attributes
    }
    
    // MARK: - TextKit 2 Text Alignment Helper
    private func applyTextAlignment(to attributedText: NSAttributedString) -> NSAttributedString {
        let range = NSRange(location: 0, length: attributedText.length)
        
        if let existingStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle,
           existingStyle.alignment == self.textAlignment {
            let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedText.addAttribute(.font, value: self.font, range: range)
            return mutableAttributedText
        }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedText.addAttribute(.font, value: self.font, range: range)

        var paragraphStyle: NSMutableParagraphStyle
        if let existingStyle = attributedText.attribute(.paragraphStyle, at: 0, effectiveRange: nil) as? NSParagraphStyle {
            paragraphStyle = existingStyle.mutableCopy() as! NSMutableParagraphStyle
        } else {
            paragraphStyle = NSMutableParagraphStyle()
        }
        
        paragraphStyle.alignment = self.textAlignment
        
        mutableAttributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        
        
        return mutableAttributedText
    }
}
