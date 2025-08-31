# Newline Character Issue Investigation

## Test Cases to Examine:

### Case 1: Without newline (should work normally)
```
"🚀🔥💯 이모지가 포함된 텍스트 예제입니다! 🎉✨🌟 ReadMoreLabel은 복잡한 유니코드 문자도 정확하게 처리할 수 있습니다. 😊📱💻 다양한 이모지와 함께 텍스트가 올바르게 잘리는지 확인해보세요! 🎯🚀⭐ 이진 탐색 알고리즘을 사용하여 효율적으로 처리됩니다. 🔍💡🎨"
```

### Case 2: With newline (problematic?)
```
"🚀🔥💯 이모지가 포함된 텍스트 예제입니다! 🎉✨🌟 ReadMoreLabel은 복잡한 유니코드 문자도 정확하게 처리할 수 있습니다. \n😊📱💻 다양한 이모지와 함께 텍스트가 올바르게 잘리는지 확인해보세요! 🎯🚀⭐ 이진 탐색 알고리즘을 사용하여 효율적으로 처리됩니다. 🔍💡🎨"
```

## Hypothesis:
The explicit newline character `\n` may be:
1. Creating an extra line that affects line counting
2. Causing the target line selection to be incorrect
3. Affecting how the suffix is positioned relative to the text

## Expected Behavior:
Both should show the suffix at the END of the target line (not on a new line) when position = .end

## Investigation needed:
- Check how line counting handles explicit newlines
- Verify target line selection logic
- Ensure suffix positioning is consistent regardless of newlines in text