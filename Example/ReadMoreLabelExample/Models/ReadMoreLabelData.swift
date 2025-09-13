//
//  ReadMoreLabelData.swift
//  ReadMoreLabelExample
//
//  Created by Claude Code on 9/7/25.
//

import Foundation
import UIKit

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