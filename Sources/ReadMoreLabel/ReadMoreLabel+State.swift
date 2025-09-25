import UIKit

extension ReadMoreLabel {
    // MARK: - Public Types
    
    @objc public enum Position: Int {
        case end = 0
        case newLine = 1
    }
    
    public enum AttributeKey {
        public static let isReadMore = NSAttributedString.Key("ReadMoreLabel.isReadMore")
    }
    
    // MARK: - Private Structs
    
    /// Text content and layout state management
    private struct TextContentState {
        private(set) var originalText: NSAttributedString?
        private(set) var readMoreTextRange: NSRange?
        
        /// Updates original text and clears related state
        /// - Parameter newText: New attributed text to set
        mutating func updateOriginalText(_ newText: NSAttributedString?) {
            guard originalText != newText else {
                return
            }
            
            originalText = newText
            readMoreTextRange = nil
        }
        
        /// Updates ReadMore text range
        /// - Parameter range: New ReadMore text range
        mutating func updateReadMoreTextRange(_ range: NSRange?) {
            readMoreTextRange = range
        }
        
        /// Checks if content is expandable
        var isExpandable: Bool {
            guard let range = readMoreTextRange else {
                return false
            }
            return range.length > 0
        }
    }
    
    /// Manages layout configuration state
    private struct LayoutConfigState {
        private(set) var numberOfLines: Int = 3
        private(set) var internalNumberOfLines: Int = 0
        
        /// Updates number of lines with validation
        /// - Parameter newValue: New number of lines value
        mutating func updateNumberOfLines(_ newValue: Int) {
            let sanitizedValue = max(0, newValue)
            guard sanitizedValue != numberOfLines else {
                return
            }
            
            numberOfLines = sanitizedValue
        }
        
        /// Updates internal number of lines
        /// - Parameter lines: New internal number of lines
        mutating func updateInternalNumberOfLines(_ lines: Int) {
            internalNumberOfLines = lines
        }
    }
    
    /// Composite state management for ReadMoreLabel
    struct State {
        private(set) var isExpanded: Bool = false
        private var textContentState = TextContentState()
        private var layoutConfigState = LayoutConfigState()
        
        // MARK: - Computed Properties
        
        var numberOfLines: Int { layoutConfigState.numberOfLines }
        
        var originalText: NSAttributedString? { textContentState.originalText }
        
        var readMoreTextRange: NSRange? {
            get { textContentState.readMoreTextRange }
            set { textContentState.updateReadMoreTextRange(newValue) }
        }
        
        var internalNumberOfLines: Int {
            get { layoutConfigState.internalNumberOfLines }
            set { layoutConfigState.updateInternalNumberOfLines(newValue) }
        }
        
        var isExpandable: Bool {
            guard numberOfLines > 0 else {
                return false
            }
            return textContentState.isExpandable
        }
        
        // MARK: - Mutating Methods
        
        /// Updates the number of lines
        /// - Parameter newValue: New number of lines value
        mutating func updateNumberOfLines(_ newValue: Int) {
            layoutConfigState.updateNumberOfLines(newValue)
        }
        
        /// Updates the original text and resets related state
        /// - Parameter newText: New attributed text to set
        mutating func updateOriginalText(_ newText: NSAttributedString?) {
            textContentState.updateOriginalText(newText)
            
            if newText == nil, isExpanded {
                isExpanded = false
            }
        }
        
        /// Sets the expansion state with validation
        mutating func setExpanded(_ expanded: Bool) -> Bool {
            guard expanded != isExpanded else {
                return false
            }
            guard !expanded || isExpandable else {
                return false
            }
            isExpanded = expanded
            return true
        }
    }
    
    // MARK: - Internal Enums
    
    enum TextTruncationResult {
        case noTruncationNeeded
        case truncated(NSAttributedString, NSRange)
        
        var needsTruncation: Bool {
            switch self {
            case .noTruncationNeeded:
                false
            case .truncated:
                true
            }
        }
        
        var textAndRange: (NSAttributedString, NSRange?)? {
            switch self {
            case .noTruncationNeeded:
                nil
            case let .truncated(text, range):
                (text, range)
            }
        }
    }
}
