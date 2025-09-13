//
//  ReadMoreSampleData.swift
//  ReadMoreLabelExample
//
//  Created by Claude Code on 9/7/25.
//

import Foundation
import ReadMoreLabel

struct ReadMoreSampleData: Identifiable {
    let id = UUID()
    let text: String
    let style: ReadMoreLabel.Style
    let position: ReadMoreLabel.Position
    let language: String
    
    init(text: String, style: ReadMoreLabel.Style, position: ReadMoreLabel.Position, language: String) {
        self.text = text
        self.style = style
        self.position = position
        self.language = language
    }
}