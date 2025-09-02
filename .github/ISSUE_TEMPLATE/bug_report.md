---
name: 🐛 Bug Report
about: Report a bug in ReadMoreLabel
title: 'fix: [Brief bug description]'
labels: ['bug']
assignees: ''
---

## 🐛 Bug Description

**Brief Summary**  
<!-- One-line summary of the bug -->

**Expected Behavior**  
<!-- What should happen -->

**Actual Behavior**  
<!-- What actually happens -->

## 🔄 Steps to Reproduce

1. 
2. 
3. 
4. 

**Minimal Code Example**
```swift
// Minimal code that reproduces the issue
let readMoreLabel = ReadMoreLabel()
readMoreLabel.numberOfLinesWhenCollapsed = 3
readMoreLabel.text = "Your text here..."
```

## 📱 Environment

**iOS Version**  
<!-- Target iOS version -->

**Xcode Version**  
<!-- Run: xcode-select --version -->

**Package Version**  
<!-- ReadMoreLabel version -->

**Installation Method**  
- [ ] Swift Package Manager
- [ ] CocoaPods
- [ ] Manual Installation

**Platform(s)**  
- [ ] iOS
- [ ] tvOS
- [ ] iPhone Simulator
- [ ] iPad Simulator

**Device/Simulator Details**  
<!-- Device model, OS version, etc. -->

## 📊 Error Details

**Error Messages/Logs**
```
<!-- Paste relevant error messages or logs here -->
```

**Console Output**
```
<!-- Any console debug output -->
```

**Screenshots/Videos**  
<!-- If applicable, add screenshots or screen recordings -->

## 🔍 Root Cause Analysis

**Suspected Cause**  
<!-- If you have insights into what might be causing this -->

**Affected Components**  
- [ ] Text Truncation Logic
- [ ] Hit Testing
- [ ] Animation
- [ ] TextKit 1 Integration
- [ ] Memory Management
- [ ] Position Handling (.end, .newLine)

## 🛠 Workaround

**Current Workaround**  
<!-- If you found a temporary solution -->

**Impact Level**  
- [ ] Critical (App crashes/unusable)
- [ ] High (Major functionality broken)
- [ ] Medium (Feature partially works)
- [ ] Low (Minor inconvenience)

## 🧪 Testing

- [ ] **Reproducible**: Can be reproduced consistently
- [ ] **Isolated**: Happens only with ReadMoreLabel
- [ ] **Recent**: Started happening recently
- [ ] **TextKit Related**: Issue seems related to TextKit 1 processing

## 📋 Additional Context

**Text Content**  
<!-- If related to specific text content, provide samples -->

**Configuration**
```swift
// Your ReadMoreLabel configuration
readMoreLabel.numberOfLinesWhenCollapsed = 
readMoreLabel.readMorePosition = 
readMoreLabel.readMoreText = 
```

---
*Bug report template for ReadMoreLabel*