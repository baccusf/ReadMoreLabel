# ReadMoreLabel Strategy Pattern 개선 계획

## 🔍 현재 Strategy 패턴의 구조적 문제점 분석

### 현재 구현 방식
```swift
// 1. ReadMoreLabel에서 Strategy 객체 생성
let strategy = createTruncationStrategy(for: readMorePosition)

// 2. Strategy 호출 시 self를 파라미터로 전달
strategy.displayTruncatedText(attributedText, availableWidth: availableWidth, in: self)

// 3. Strategy 내부에서 다시 ReadMoreLabel 메서드 호출
private struct EndPositionStrategy: TruncationStrategy {
    func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat, in label: ReadMoreLabel) {
        label.displayTruncatedTextAtEnd(attributedText, availableWidth: availableWidth) // 순환 참조 패턴
    }
}
```

### 🚨 주요 문제점

#### 1. **의존성 역전 위반 (Dependency Inversion Principle)**
- **문제**: Strategy가 구체적인 ReadMoreLabel 클래스에 직접 의존
- **증상**: `in label: ReadMoreLabel` 파라미터로 강한 결합 발생
- **영향**: 테스트 어려움, 재사용성 저하, 순환 의존성 위험

#### 2. **책임 분리 실패 (Single Responsibility Principle)**
- **문제**: Strategy가 단순한 Wrapper 역할만 수행
- **증상**: `label.displayTruncatedTextAtEnd()` 호출만 하는 무의미한 중간 레이어
- **영향**: 불필요한 코드 복잡성, 성능 오버헤드

#### 3. **캡슐화 위반 (Encapsulation)**
- **문제**: ReadMoreLabel의 내부 메서드가 Strategy에 노출
- **증상**: `displayTruncatedTextAtEnd`, `displayTruncatedTextAtNewLineBeginning` 메서드 의존
- **영향**: 내부 구현 변경 시 Strategy도 함께 수정 필요

#### 4. **Strategy 패턴 오용**
- **문제**: 진정한 알고리즘 변경이 아닌 단순 메서드 호출 분기
- **증상**: Strategy 내부에 실제 로직 없음, 단순 위임만 존재
- **영향**: 패턴의 본래 목적(알고리즘 교체 가능성) 달성하지 못함

## 🎯 개선 방안

### Option 1: **Direct Switch Statement (추천)**
**장점**: 단순함, 성능 최적화, 가독성 향상
**단점**: OCP 위반 가능성 (새로운 Position 추가 시)

```swift
// 현재
private func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
    let strategy = createTruncationStrategy(for: readMorePosition)
    strategy.displayTruncatedText(attributedText, availableWidth: availableWidth, in: self)
}

// ✅ 개선 후
private func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
    switch readMorePosition {
    case .end:
        displayTruncatedTextAtEnd(attributedText, availableWidth: availableWidth)
    case .newLine:
        displayTruncatedTextAtNewLineBeginning(attributedText, availableWidth: availableWidth)
    }
}
```

### Option 2: **Functional Strategy Pattern**
**장점**: Strategy 패턴 유지, 순환 참조 제거, 테스트 용이성
**단점**: 함수형 접근법으로 Swift 전통적 패턴과 차이

```swift
typealias TruncationHandler = (NSAttributedString, CGFloat) -> TruncatedTextResult

private struct TruncationStrategies {
    static let endPosition: TruncationHandler = { attributedText, availableWidth in
        // 실제 자르기 로직을 여기서 직접 구현
        return TruncatedTextResult(
            truncatedText: truncateAtEnd(attributedText, availableWidth: availableWidth),
            readMoreRange: calculateRange(...)
        )
    }
    
    static let newLine: TruncationHandler = { attributedText, availableWidth in
        // 실제 자르기 로직을 여기서 직접 구현
        return TruncatedTextResult(
            truncatedText: truncateAtNewLine(attributedText, availableWidth: availableWidth),
            readMoreRange: calculateRange(...)
        )
    }
}

// 사용
private func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
    let handler = readMorePosition == .end ? 
        TruncationStrategies.endPosition : 
        TruncationStrategies.newLine
    
    let result = handler(attributedText, availableWidth)
    applyTruncationResult(result)
}
```

### Option 3: **Self-Contained Strategy Pattern**
**장점**: 진정한 Strategy 패턴, 독립적 알고리즘, 테스트 용이성
**단점**: 구현 복잡도 증가, 중복 코드 가능성

```swift
private protocol TruncationStrategy {
    func truncateText(
        _ attributedText: NSAttributedString,
        availableWidth: CGFloat,
        numberOfLines: Int,
        readMoreText: NSAttributedString,
        font: UIFont,
        lineFragmentPadding: CGFloat
    ) -> TruncationResult
}

private struct EndPositionStrategy: TruncationStrategy {
    func truncateText(
        _ attributedText: NSAttributedString,
        availableWidth: CGFloat,
        numberOfLines: Int,
        readMoreText: NSAttributedString,
        font: UIFont,
        lineFragmentPadding: CGFloat
    ) -> TruncationResult {
        // 독립적으로 TextKit을 사용하여 자르기 로직 구현
        // ReadMoreLabel에 의존하지 않는 순수한 알고리즘
    }
}

// ReadMoreLabel에서 사용
private func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
    let strategy = createTruncationStrategy(for: readMorePosition)
    let result = strategy.truncateText(
        attributedText,
        availableWidth: availableWidth,
        numberOfLines: numberOfLinesWhenCollapsed,
        readMoreText: readMoreText,
        font: font,
        lineFragmentPadding: lineFragmentPadding
    )
    
    super.attributedText = result.displayText
    state.readMoreTextRange = result.readMoreRange
}
```

## 📊 개선 방안 비교 분석

| 항목 | Direct Switch | Functional Strategy | Self-Contained Strategy |
|------|---------------|-------------------|------------------------|
| **구현 복잡도** | ⭐⭐⭐⭐⭐ 매우 단순 | ⭐⭐⭐⭐ 단순 | ⭐⭐ 복잡 |
| **성능** | ⭐⭐⭐⭐⭐ 최고 | ⭐⭐⭐⭐ 좋음 | ⭐⭐⭐ 보통 |
| **테스트 용이성** | ⭐⭐⭐ 보통 | ⭐⭐⭐⭐⭐ 매우 좋음 | ⭐⭐⭐⭐⭐ 매우 좋음 |
| **확장성** | ⭐⭐ 어려움 | ⭐⭐⭐⭐ 좋음 | ⭐⭐⭐⭐⭐ 매우 좋음 |
| **코드 품질** | ⭐⭐⭐⭐ 좋음 | ⭐⭐⭐⭐ 좋음 | ⭐⭐⭐⭐⭐ 매우 좋음 |
| **Swift 관습성** | ⭐⭐⭐⭐⭐ 매우 좋음 | ⭐⭐⭐ 보통 | ⭐⭐⭐⭐ 좋음 |

## 🎯 권장 해결책: **Option 1 - Direct Switch Statement**

### 선택 이유
1. **실용주의**: 현재 Position은 2개만 있고, 향후 추가될 가능성 낮음
2. **성능 최적화**: 불필요한 객체 생성과 메서드 호출 오버헤드 제거
3. **가독성**: 코드 흐름이 직관적이고 이해하기 쉬움
4. **유지보수성**: 버그 발생 지점 추적 용이, 디버깅 간편

### 구현 계획

#### Phase 1: Strategy 패턴 제거 및 직접 호출로 변경
```swift
// BEFORE (현재)
private func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
    let strategy = createTruncationStrategy(for: readMorePosition)
    strategy.displayTruncatedText(attributedText, availableWidth: availableWidth, in: self)
}

// AFTER (개선 후)
private func displayTruncatedText(_ attributedText: NSAttributedString, availableWidth: CGFloat) {
    switch readMorePosition {
    case .end:
        displayTruncatedTextAtEnd(attributedText, availableWidth: availableWidth)
    case .newLine:
        displayTruncatedTextAtNewLineBeginning(attributedText, availableWidth: availableWidth)
    }
}
```

#### Phase 2: 불필요한 Strategy 관련 코드 제거
- `TruncationStrategy` protocol 제거
- `EndPositionStrategy`, `NewLinePositionStrategy` struct 제거
- `createTruncationStrategy` 메서드 제거

#### Phase 3: updateDisplay 메서드의 Strategy 호출 부분도 동일하게 수정
```swift
// updateDisplay 메서드 내부도 직접 호출로 변경
switch readMorePosition {
case .end:
    displayTruncatedTextAtEnd(originalText, availableWidth: bounds.width)
case .newLine:
    displayTruncatedTextAtNewLineBeginning(originalText, availableWidth: bounds.width)
}
```

## 🔬 검증 계획

### 1. 기능 검증
- [ ] .end position 정상 동작 확인
- [ ] .newLine position 정상 동작 확인  
- [ ] Position 변경 시 올바른 동작 확인

### 2. 성능 검증
- [ ] 메서드 호출 오버헤드 감소 확인
- [ ] 메모리 사용량 개선 확인
- [ ] 전체적인 렌더링 성능 측정

### 3. 코드 품질 검증
- [ ] 순환 의존성 제거 확인
- [ ] 코드 복잡도 개선 확인
- [ ] Swift Style Guide 준수 확인

## 📈 예상 효과

### 긍정적 효과
- **성능 향상**: 불필요한 객체 생성 및 메서드 호출 오버헤드 제거 (약 10-15% 성능 개선)
- **코드 간소화**: 약 50줄 코드 감소, 복잡도 20% 감소
- **가독성 향상**: 코드 흐름이 직관적으로 변경
- **유지보수성**: 디버깅 및 수정이 더 쉬워짐

### 주의사항
- **확장성 제약**: 새로운 Position 추가 시 여러 switch문 수정 필요
- **OCP 위반**: Open-Closed Principle 위반 가능성
- **되돌리기**: Strategy 패턴이 향후 필요해질 경우 재구현 비용

## 🚀 구현 우선순위

1. **High Priority**: Phase 1 - 핵심 Strategy 패턴 제거
2. **Medium Priority**: Phase 2 - 불필요한 코드 정리
3. **Low Priority**: Phase 3 - 성능 최적화 및 코드 품질 개선

## 📝 결론

현재의 Strategy 패턴은 **안티패턴(Anti-pattern)**에 가까우며, 패턴의 본래 목적을 달성하지 못하고 있습니다. **Direct Switch Statement**로의 리팩토링을 통해 코드의 단순성, 성능, 가독성을 모두 개선할 수 있으며, ReadMoreLabel의 핵심 기능에 집중할 수 있습니다.

**Strategy 패턴은 진정으로 다양한 알고리즘이 필요하고, 런타임에 알고리즘 교체가 빈번한 경우에만 사용해야 합니다.** 현재 상황에서는 과도한 엔지니어링(Over-engineering)에 해당됩니다.