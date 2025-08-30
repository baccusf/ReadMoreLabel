# ReadMoreLabel

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

우아한 텍스트 자르기와 확장 기능을 제공하는 강력하고 유연한 UILabel 서브클래스입니다.

**한국어** | [日本語](README-ja.md) | [English](README.md)

## ✨ 주요 기능

- **스마트 텍스트 자르기**: 정확한 텍스트 레이아웃 계산으로 지정된 위치에 "더보기" 표시
- **자연스러운 텍스트 연결**: 커스터마이징 가능한 ellipsis 텍스트로 매끄러운 시각적 연결 (`텍스트.. 더보기..`)
- **유연한 위치 제어**: "더보기"가 잘린 콘텐츠의 끝이나 시작 부분에 나타나도록 선택 가능
- **문자 단위 정밀도**: 단어와 문자 레벨에서 잘림 위치를 미세 조정하여 공간 활용 최적화
- **부드러운 애니메이션**: 내장된 확장/축소 애니메이션과 델리게이트 콜백
- **커스터마이징 가능한 외관**: "더보기" 텍스트에 NSAttributedString 스타일링 지원
- **유연한 설정**: `numberOfLinesWhenCollapsed = 0`으로 "더보기" 기능 비활성화 가능
- **UILabel 호환성**: 최소한의 코드 변경으로 기존 UILabel 대체 가능
- **Interface Builder 지원**: IBDesignable과 IBInspectable 프로퍼티 지원
- **안전한 API 설계**: 상속받은 UILabel 프로퍼티의 직접 수정 방지

## 🚀 설치

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ReadMoreLabel.git", from: "0.1.0")
]
```

### CocoaPods

```ruby
pod 'ReadMoreLabel'
```

### 수동 설치

1. 저장소 다운로드
2. `ReadMoreLabel.swift` 파일을 Xcode 프로젝트에 드래그

## 📖 사용법

### 기본 구현

```swift
import ReadMoreLabel

class ViewController: UIViewController {
    @IBOutlet weak var readMoreLabel: ReadMoreLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 기본 설정
        readMoreLabel.numberOfLinesWhenCollapsed = 3
        readMoreLabel.text = "여기에 긴 텍스트 내용을 입력하세요..."
        
        // "더보기" 텍스트 커스터마이징
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 16, weight: .medium)
        ]
        readMoreLabel.readMoreText = NSAttributedString(string: "더보기..", attributes: attributes)
        
        // 확장 이벤트를 위한 델리게이트 설정
        readMoreLabel.delegate = self
    }
}

extension ViewController: ReadMoreLabelDelegate {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        print("레이블 확장됨: \(isExpanded)")
        
        // 선택사항: 레이아웃 변경 애니메이션
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
```

### 프로그래매틱 사용법

```swift
let readMoreLabel = ReadMoreLabel()
readMoreLabel.numberOfLinesWhenCollapsed = 2
readMoreLabel.text = "긴 텍스트 내용..."
readMoreLabel.translatesAutoresizingMaskIntoConstraints = false

view.addSubview(readMoreLabel)
NSLayoutConstraint.activate([
    readMoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    readMoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    readMoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
])
```

### 수동 제어

```swift
// 프로그래매틱 확장/축소
readMoreLabel.expand()
readMoreLabel.collapse()

// 애니메이션 제어
readMoreLabel.setExpanded(true, animated: true)

// 현재 상태 확인
if readMoreLabel.isExpanded {
    print("현재 확장됨")
}

// 텍스트 확장 가능 여부 확인
if readMoreLabel.isExpandable {
    print("텍스트가 잘렸으며 확장 가능함")
}
```

### "더보기" 기능 비활성화

```swift
// 0으로 설정하여 자르기 비활성화 (일반 UILabel처럼 동작)
readMoreLabel.numberOfLinesWhenCollapsed = 0
```

## 🎨 커스터마이징

### 프로퍼티

| 프로퍼티 | 타입 | 설명 | 기본값 |
|----------|------|------|--------|
| `numberOfLinesWhenCollapsed` | `Int` | 축소 시 표시할 줄 수 (0 = 무제한) | `3` |
| `readMoreText` | `NSAttributedString` | 스타일링 가능한 "더보기" 텍스트 | `"더보기.."` |
| `ellipsisText` | `String` | "더보기" 앞의 커스터마이징 가능한 ellipsis 텍스트 | `".."` |
| `readMorePosition` | `ReadMoreLabel.Position` | "더보기" 텍스트 위치 (`.end`, `.beginningNewLine`) | `.end` |
| `isExpanded` | `Bool` | 현재 확장 상태 (읽기 전용) | `false` |
| `isExpandable` | `Bool` | 텍스트 확장 가능 여부 (읽기 전용) | `계산됨` |
| `delegate` | `ReadMoreLabelDelegate?` | 확장 이벤트 델리게이트 | `nil` |

### 델리게이트 메서드

```swift
protocol ReadMoreLabelDelegate: AnyObject {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool)
}
```

### 스타일링 예제

```swift
// "더보기" 텍스트 커스터마이징
let readMoreAttributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.systemBlue,
    .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
    .underlineStyle: NSUnderlineStyle.single.rawValue
]
readMoreLabel.readMoreText = NSAttributedString(string: "더 보기 →", attributes: readMoreAttributes)

// 다양한 언어
readMoreLabel.readMoreText = NSAttributedString(string: "続きを読む..")  // 일본어
readMoreLabel.readMoreText = NSAttributedString(string: "더보기..")     // 한국어
readMoreLabel.readMoreText = NSAttributedString(string: "Ver más..")   // 스페인어

// 커스텀 ellipsis와 위치 제어
readMoreLabel.ellipsisText = "→"              // 점 대신 화살표
readMoreLabel.ellipsisText = "***"            // 별표
readMoreLabel.ellipsisText = "✨"             // 이모지

// 위치 제어
readMoreLabel.readMorePosition = .end                    // 마지막 줄: "텍스트.. 더보기.." (기본값)
readMoreLabel.readMorePosition = .beginningNewLine       // n줄 모두 표시 후: "더보기.."만 표시
```

## ⚠️ 중요 사항

### 보호된 프로퍼티

ReadMoreLabel은 적절한 기능을 보장하기 위해 특정 UILabel 프로퍼티를 재정의합니다:

- **`numberOfLines`**: 대신 `numberOfLinesWhenCollapsed` 사용
- **`lineBreakMode`**: `.byWordWrapping`으로 고정

이러한 프로퍼티를 직접 설정하려고 하면 디버그 경고가 표시되고 무시됩니다.

### 네이밍 충돌

다른 라이브러리에도 `ReadMoreLabel` 클래스가 있어 네이밍 충돌이 발생하는 경우, Swift의 모듈 네임스페이스 시스템을 사용해 해결할 수 있습니다:

```swift
// 방법 1: 전체 모듈명 사용
import ReadMoreLabel
let label = ReadMoreLabel.ReadMoreLabel()

// 방법 2: typealias 생성
import ReadMoreLabel
typealias BFReadMoreLabel = ReadMoreLabel.ReadMoreLabel
let label = BFReadMoreLabel()

// 방법 3: 선택적 import (Swift 5.2+)
import ReadMoreLabel.ReadMoreLabel
let label = ReadMoreLabel()
```

### 모범 사례

1. **Auto Layout**: 적절한 텍스트 측정을 위해 항상 Auto Layout 제약 조건 사용
2. **성능**: 대용량 텍스트의 경우 처음에 `numberOfLinesWhenCollapsed = 0`으로 설정하고 필요할 때 자르기 활성화 고려
3. **접근성**: 컴포넌트는 VoiceOver와 Dynamic Type을 자동으로 지원
4. **스레드 안전성**: 항상 메인 스레드에서 프로퍼티 업데이트
5. **네이밍 충돌**: 클래스명 충돌 시 모듈 네임스페이스나 typealias 사용

## 🔧 고급 사용법

### 커스텀 애니메이션

```swift
func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
    // 커스텀 스프링 애니메이션
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

### UITableView/UICollectionView와 통합

```swift
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
}

func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
}

// 셀 설정에서
cell.readMoreLabel.delegate = self

func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
    // 애니메이션으로 테이블 뷰 업데이트
    tableView.beginUpdates()
    tableView.endUpdates()
}
```

## 🛠 요구사항

- iOS 16.0+
- Swift 5.0+
- Xcode 16.0+

## 💡 Swift 버전 호환성

ReadMoreLabel은 Swift 5.0+로 개발되었습니다. Swift 버전 호환성에 대한 참고사항:

### 상위 호환성 (Forward Compatibility)
- **Swift 5.0으로 개발된 라이브러리는 상위 버전(6.0, 7.0 등)에서도 정상 작동**합니다
- 사용자가 Swift 6.2를 사용하더라도 Swift 5.0 라이브러리를 문제없이 사용 가능
- Swift는 상위 호환성을 보장하도록 설계됨

### ABI 안정성 (ABI Stability)
- **Swift 5.1부터 ABI가 안정화**되어 서로 다른 Swift 버전으로 컴파일된 바이너리가 호환
- 런타임 호환성 보장
- 앱 스토어 배포 시에도 문제 없음

### 권장 사항
- 라이브러리 최소 요구 버전: **Swift 5.0**
- 사용자는 Swift 5.0 이상 어떤 버전이든 사용 가능
- 최신 기능이 필요한 경우에만 상위 버전 요구

## 📄 라이센스

ReadMoreLabel은 MIT 라이센스 하에 제공됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## 🤝 기여

1. 저장소 포크
2. 기능 브랜치 생성 (`git checkout -b feature/amazing-feature`)
3. 변경사항 커밋 (`git commit -m 'Add some amazing feature'`)
4. 브랜치에 푸시 (`git push origin feature/amazing-feature`)
5. Pull Request 열기

## 📞 지원

- 버그 신고나 기능 요청은 이슈를 생성해 주세요
- 새 이슈를 생성하기 전에 기존 이슈를 확인해 주세요
- 버그 신고 시 상세한 재현 단계를 제공해 주세요

## 🙏 감사의 말

**Claude와의 AI 페어 프로그래밍**을 통해 iOS 개발 커뮤니티를 위해 ❤️로 제작되었습니다.

---

**Swift & AI로 제작됨** 🚀