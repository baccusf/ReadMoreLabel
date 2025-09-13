# ReadMoreLabel

[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

우아한 텍스트 자르기와 확장 기능을 제공하는 강력하고 유연한 UILabel 서브클래스입니다.

[English](README.md) | [日本語](README-ja.md) | **한국어**

## 🎬 데모

> **참고**: 최고의 경험을 위해 [데모 영상](screenshots/ReadMoreLabel_Demo.mp4)을 다운로드하여 로컬에서 보시거나 아래 애니메이션 스크린샷을 확인해주세요.

[![데모 영상](https://img.shields.io/badge/📹_데모_영상-다운로드_클릭-blue.svg)](screenshots/ReadMoreLabel_Demo.mp4)

## 📱 스크린샷

### 애니메이션 예제
<img src="screenshots/01_animation_examples.png" width="300" alt="애니메이션 예제"> <img src="screenshots/02_animation_examples_rtl.png" width="300" alt="RTL 지원이 포함된 애니메이션 예제">

### 테이블 뷰 예제
<img src="screenshots/03_table_view_examples.png" width="300" alt="테이블 뷰 예제"> <img src="screenshots/04_table_view_with_rtl.png" width="300" alt="RTL 지원이 포함된 테이블 뷰">

## ✨ 주요 기능

- **스마트 텍스트 자르기**: 정확한 텍스트 레이아웃 계산으로 지정된 위치에 "더보기" 표시
- **자연스러운 텍스트 연결**: 커스터마이징 가능한 ellipsis 텍스트로 매끄러운 시각적 연결 (`텍스트.. 더보기..`)
- **유연한 위치 제어**: "더보기"가 잘린 콘텐츠의 끝이나 시작 부분에 나타나도록 선택 가능
- **문자 단위 정밀도**: 단어와 문자 레벨에서 잘림 위치를 미세 조정하여 공간 활용 최적화
- **RTL 언어 지원**: 아랍어, 히브리어 등 오른쪽에서 왼쪽으로 쓰는 언어 완벽 지원 및 BiDi 텍스트 처리
- **부드러운 애니메이션**: 내장된 확장/축소 애니메이션과 델리게이트 콜백
- **커스터마이징 가능한 외관**: "더보기" 텍스트에 NSAttributedString 스타일링 지원
- **유연한 설정**: `numberOfLines = 0`으로 "더보기" 기능 비활성화 가능
- **UILabel 호환성**: 최소한의 코드 변경으로 기존 UILabel 대체 가능
- **Interface Builder 지원**: IBDesignable과 IBInspectable 프로퍼티 지원
- **안전한 API 설계**: 상속받은 UILabel 프로퍼티의 직접 수정 방지

## 🚀 설치

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/baccusf/ReadMoreLabel.git", from: "0.1.0")
]
```

### CocoaPods

```ruby
pod 'ReadMoreLabel', '~> 0.1.0'
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
        readMoreLabel.numberOfLines = 3
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
readMoreLabel.numberOfLines = 2
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

// 프로그래매틱 확장 상태 설정
readMoreLabel.setExpanded(true)

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
readMoreLabel.numberOfLines = 0
```

## 🎨 커스터마이징

### 프로퍼티

| 프로퍼티 | 타입 | 설명 | 기본값 |
|----------|------|------|--------|
| `numberOfLines` | `Int` | 축소 시 표시할 줄 수 (0 = 무제한) | `3` |
| `readMoreText` | `NSAttributedString` | 스타일링 가능한 "더보기" 텍스트 | `"Read More.."` |
| `ellipsisText` | `NSAttributedString` | "더보기" 앞의 커스터마이징 가능한 ellipsis 텍스트 | `".."` |
| `readMorePosition` | `ReadMoreLabel.Position` | "더보기" 텍스트 위치 (`.end`, `.newLine`) | `.end` |
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
readMoreLabel.readMoreText = NSAttributedString(string: "اقرأ المزيد")  // 아랍어

// 커스텀 ellipsis와 위치 제어
readMoreLabel.ellipsisText = NSAttributedString(string: "→")              // 점 대신 화살표
readMoreLabel.ellipsisText = NSAttributedString(string: "***")            // 별표
readMoreLabel.ellipsisText = NSAttributedString(string: "✨")             // 이모지

// 위치 제어
readMoreLabel.readMorePosition = .end         // 마지막 줄: "텍스트.. 더보기.." (기본값)
readMoreLabel.readMorePosition = .newLine     // 새 줄에 "더보기.." 표시
```

## 🌐 RTL 언어 지원

ReadMoreLabel은 아랍어 및 히브리어와 같은 오른쪽에서 왼쪽으로 쓰는 언어를 포괄적으로 지원합니다:

### RTL 설정

```swift
// 아랍어 RTL 설정
let arabicLabel = ReadMoreLabel()
arabicLabel.semanticContentAttribute = .forceRightToLeft
arabicLabel.textAlignment = .right
arabicLabel.numberOfLines = 3
arabicLabel.text = "هذا نص طويل باللغة العربية يوضح وظائف ReadMoreLabel..."
arabicLabel.readMoreText = NSAttributedString(
    string: "اقرأ المزيد",
    attributes: [.foregroundColor: UIColor.systemBlue]
)

// 히브리어 RTL 설정
let hebrewLabel = ReadMoreLabel()
hebrewLabel.semanticContentAttribute = .forceRightToLeft  
hebrewLabel.textAlignment = .right
hebrewLabel.text = "זה טקסט ארוך בעברית המדגים את הפונקציות של ReadMoreLabel..."
hebrewLabel.readMoreText = NSAttributedString(string: "קרא עוד")
```

### RTL 기능

- **자동 RTL 감지**: `semanticContentAttribute`와 `effectiveUserInterfaceLayoutDirection`에서 RTL 컨텍스트 자동 감지
- **RTL 인식 텍스트 자르기**: RTL 텍스트 레이아웃에 맞는 정확한 자르기 위치 계산
- **BiDi 텍스트 처리**: 적절한 유니코드 방향 마커를 통한 양방향 텍스트 지원
- **RTL 접미사 순서**: 자연스러운 RTL 접미사 구성 (ellipsis + "더보기" 올바른 순서)
- **터치 영역 보존**: RTL 레이아웃에서 정확한 터치 감지 유지


## ⚠️ 중요 사항


### 모범 사례

1. **Auto Layout**: 적절한 텍스트 측정을 위해 항상 Auto Layout 제약 조건 사용
2. **성능**: 대용량 텍스트의 경우 처음에 `numberOfLines = 0`으로 설정하고 필요할 때 자르기 활성화 고려
3. **접근성**: 컴포넌트는 VoiceOver와 Dynamic Type을 자동으로 지원
4. **스레드 안전성**: 항상 메인 스레드에서 프로퍼티 업데이트
5. **다국어 지원**: TextKit2를 사용하여 다양한 언어에서 글리프 계산 이슈를 해결하고 정확한 텍스트 측정을 제공
5. **TextKit 1**: 안정적인 텍스트 처리를 위해 검증된 TextKit 1 API를 기반으로 구축
6. **메모리 관리**: 안정성을 위해 적절한 TextKit 스택 참조를 유지하는 컴포넌트

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
// 테이블뷰 셀에서
class ExampleTableViewCell: UITableViewCell {
    private let readMoreLabel: ReadMoreLabel = {
        let label = ReadMoreLabel()
        label.numberOfLines = 3
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func configure(with text: String, isExpanded: Bool, delegate: ReadMoreLabelDelegate?) {
        // 델리게이트 먼저 설정
        readMoreLabel.delegate = delegate
        
        // 텍스트 내용 설정
        readMoreLabel.text = text
        
        // 확장 상태 설정
        readMoreLabel.setExpanded(isExpanded)
    }
    
}

// 뷰 컨트롤러에서
class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var expandedStates: [Bool] = []  // 각 셀의 확장 상태 추적
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath) as! ExampleTableViewCell
        let isExpanded = expandedStates[indexPath.row]
        cell.configure(with: sampleTexts[indexPath.row], isExpanded: isExpanded, delegate: self)
        return cell
    }
}

extension ViewController: ReadMoreLabelDelegate {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        // label의 중심점을 tableView 좌표계로 변환
        let labelCenterInTableView = label.convert(label.center, to: tableView)
        
        // 해당 위치의 indexPath를 찾음
        guard let indexPath = tableView.indexPathForRow(at: labelCenterInTableView) else {
            return
        }
        
        expandedStates[indexPath.row] = isExpanded
        
        // 레이아웃 변경 애니메이션
        UIView.animate(withDuration: 0.3) {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
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

ReadMoreLabel은 **Git Flow** 워크플로우를 따릅니다. 다음 가이드라인을 준수해 주세요:

1. 저장소 포크
2. `develop`에서 기능 브랜치 생성 (`git checkout develop && git checkout -b feature/amazing-feature`)
3. 커밋 메시지 형식을 준수: `<type>: <description>`
   - 타입: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
4. Swift Style Guide 원칙을 준수하세요
5. 새 기능에 테스트를 추가하세요
6. 적절한 형식으로 변경사항 커밋:
   ```
   feat: 놀라운 새 기능 추가
   
   변경사항에 대한 자세한 설명
   
   🎯 Generated with Claude Code
   Co-Authored-By: Claude <noreply@anthropic.com>
   ```
7. 브랜치에 푸시 (`git push origin feature/amazing-feature`)
8. `develop` 브랜치를 대상으로 Pull Request 열기
9. PR 템플릿을 완전히 작성하세요


## 📞 지원

- 버그 신고나 기능 요청은 이슈를 생성해 주세요
- 새 이슈를 생성하기 전에 기존 이슈를 확인해 주세요
- 버그 신고 시 상세한 재현 단계를 제공해 주세요

## 🙏 감사의 말

**Claude와의 AI 페어 프로그래밍**을 통해 iOS 개발 커뮤니티를 위해 ❤️로 제작되었습니다.

---

**Swift & AI로 제작됨** 🚀