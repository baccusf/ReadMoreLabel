# ReadMoreLabel

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A powerful and flexible UILabel subclass that provides "Read More" functionality with elegant text truncation and expansion capabilities.

[한국어](README-ko.md) | [日本語](README-ja.md) | **English**

## ✨ Features

- **Smart Text Truncation**: Precisely calculates text layout to show "Read More" at the specified position
- **Natural Text Flow**: Customizable ellipsis text before "Read More" for seamless visual connection (`text.. Read More..`)
- **Flexible Positioning**: Choose whether "Read More" appears at the end or beginning of truncated content
- **Character-Level Precision**: Fine-tunes truncation at both word and character levels for optimal space utilization
- **Smooth Animations**: Built-in expand/collapse animations with delegate callbacks
- **Customizable Appearance**: Support for NSAttributedString styling on "Read More" text
- **Flexible Configuration**: Disable "Read More" functionality by setting `numberOfLinesWhenCollapsed = 0`
- **UILabel Compatibility**: Drop-in replacement with minimal code changes
- **Interface Builder Support**: IBDesignable with IBInspectable properties
- **Safe API Design**: Prevents direct modification of inherited UILabel properties

## 🚀 Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ReadMoreLabel.git", from: "1.0.0")
]
```

### CocoaPods

```ruby
pod 'ReadMoreLabel'
```

### Manual Installation

1. Download the repository
2. Drag `ReadMoreLabel.swift` into your Xcode project

## 📖 Usage

### Basic Implementation

```swift
import ReadMoreLabel

class ViewController: UIViewController {
    @IBOutlet weak var readMoreLabel: ReadMoreLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Basic configuration
        readMoreLabel.numberOfLinesWhenCollapsed = 3
        readMoreLabel.text = "Your long text content here..."
        
        // Custom "Read More" text with styling
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        readMoreLabel.readMoreText = NSAttributedString(string: "Read More..", attributes: attributes)
        
        // Customize ellipsis text and position
        readMoreLabel.ellipsisText = "→"  // Custom ellipsis
        readMoreLabel.readMorePosition = .end  // Position at end (default)
        
        // Set delegate for expansion events
        readMoreLabel.delegate = self
    }
}

extension ViewController: ReadMoreLabelDelegate {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        print("Label expanded: \(isExpanded)")
        
        // Optional: Animate layout changes
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
```

### Programmatic Usage

```swift
let readMoreLabel = ReadMoreLabel()
readMoreLabel.numberOfLinesWhenCollapsed = 2
readMoreLabel.text = "Long text content..."
readMoreLabel.translatesAutoresizingMaskIntoConstraints = false

view.addSubview(readMoreLabel)
NSLayoutConstraint.activate([
    readMoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    readMoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    readMoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
])
```

### Manual Control

```swift
// Programmatically expand/collapse
readMoreLabel.expand()
readMoreLabel.collapse()

// Or with animation control
readMoreLabel.setExpanded(true, animated: true)

// Check current state
if readMoreLabel.isExpanded {
    print("Currently expanded")
}

// Check if text can be expanded
if readMoreLabel.isExpandable {
    print("Text is truncated and can be expanded")
}
```

### Disable "Read More" Functionality

```swift
// Set to 0 to disable truncation (behaves like normal UILabel)
readMoreLabel.numberOfLinesWhenCollapsed = 0
```

## 🎨 Customization

### Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `numberOfLinesWhenCollapsed` | `Int` | Number of lines to show when collapsed (0 = unlimited) | `3` |
| `readMoreText` | `NSAttributedString` | Customizable "Read More" text with styling | `"Read More.."` |
| `ellipsisText` | `String` | Customizable ellipsis text before "Read More" | `".."` |
| `readMorePosition` | `ReadMoreLabel.Position` | Position of "Read More" text (`.end`, `.beginningNewLine`) | `.end` |
| `isExpanded` | `Bool` | Current expansion state (read-only) | `false` |
| `isExpandable` | `Bool` | Whether text can be expanded (read-only) | `computed` |
| `delegate` | `ReadMoreLabelDelegate?` | Delegate for expansion events | `nil` |

### Delegate Methods

```swift
protocol ReadMoreLabelDelegate: AnyObject {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool)
}
```

### Styling Examples

```swift
// Custom styling for "Read More" text
let readMoreAttributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.systemBlue,
    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
    .underlineStyle: NSUnderlineStyle.single.rawValue
]
readMoreLabel.readMoreText = NSAttributedString(string: "Show More →", attributes: readMoreAttributes)

// Different languages
readMoreLabel.readMoreText = NSAttributedString(string: "続きを読む..")  // Japanese
readMoreLabel.readMoreText = NSAttributedString(string: "더보기..")     // Korean
readMoreLabel.readMoreText = NSAttributedString(string: "Ver más..")   // Spanish

// Custom ellipsis and positioning
readMoreLabel.ellipsisText = "→"              // Arrow instead of dots
readMoreLabel.ellipsisText = "***"            // Asterisks
readMoreLabel.ellipsisText = "✨"             // Emoji

// Position control  
readMoreLabel.readMorePosition = .end                    // Last line: "text.. Read More.." (default)
readMoreLabel.readMorePosition = .beginningNewLine       // After n full lines: "Read More.." only
```

## ⚠️ Important Notes

### Protected Properties

ReadMoreLabel overrides certain UILabel properties to ensure proper functionality:

- **`numberOfLines`**: Use `numberOfLinesWhenCollapsed` instead
- **`lineBreakMode`**: Fixed to `.byWordWrapping`

Attempting to set these properties directly will show debug warnings and be ignored.

### Naming Conflicts

If you encounter naming conflicts with other libraries that also have a `ReadMoreLabel` class, you can resolve them using Swift's module namespace system:

```swift
// Method 1: Use full module name
import ReadMoreLabel
let label = ReadMoreLabel.ReadMoreLabel()

// Method 2: Create a typealias
import ReadMoreLabel
typealias BFReadMoreLabel = ReadMoreLabel.ReadMoreLabel
let label = BFReadMoreLabel()

// Method 3: Selective import (Swift 5.2+)
import ReadMoreLabel.ReadMoreLabel
let label = ReadMoreLabel()
```

### Best Practices

1. **Auto Layout**: Always use Auto Layout constraints for proper text measurement
2. **Performance**: For large amounts of text, consider setting `numberOfLinesWhenCollapsed = 0` initially and enabling truncation when needed
3. **Accessibility**: The component automatically supports VoiceOver and Dynamic Type
4. **Thread Safety**: Always update properties on the main thread
5. **Naming Conflicts**: Use module namespaces or typealiases to resolve class name conflicts

## 🔧 Advanced Usage

### Custom Animation

```swift
func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
    // Custom spring animation
    UIView.animate(
        withDuration: 0.6,
        delay: 0,
        usingSpringWithDamping: 0.8,
        initialSpringVelocity: 0.2,
        options: .curveEaseInOut
    ) {
        self.view.layoutIfNeeded()
    }
}
```

### Integration with UITableView/UICollectionView

```swift
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
}

func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
}

// In your cell configuration
cell.readMoreLabel.delegate = self

func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
    // Update table view with animation
    tableView.beginUpdates()
    tableView.endUpdates()
}
```

## 🛠 Requirements

- iOS 13.0+
- Swift 5.0+
- Xcode 13.0+

## 📄 License

ReadMoreLabel is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

- Create an issue for bug reports or feature requests
- Check existing issues before creating a new one
- Provide detailed reproduction steps for bug reports

## 🙏 Acknowledgments

Built with ❤️ for the iOS development community using **AI-powered pair programming** with Claude.

---

**Made with Swift & AI** 🚀