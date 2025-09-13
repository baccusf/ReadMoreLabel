import Foundation
import UIKit
import ReadMoreLabel

// MARK: - Performance Measurement Service

/// Single Responsibility: Performance measurement and benchmarking
final class PerformanceMeasurement {

    // MARK: - Types

    struct BenchmarkResult {
        let averageTime: Double
        let iterations: Int
        let testName: String

        var formattedTime: String {
            return String(format: "%.3f", averageTime)
        }
    }

    struct ComparisonResult {
        let readMoreLabelResult: BenchmarkResult
        let uiLabelResult: BenchmarkResult

        var performanceRatio: Double {
            guard uiLabelResult.averageTime > 0 else { return 0 }
            return readMoreLabelResult.averageTime / uiLabelResult.averageTime
        }

        var formattedRatio: String {
            return String(format: "%.1f", performanceRatio)
        }
    }

    // MARK: - Constants

    private enum Constants {
        static let defaultIterations = 50
        static let testFrameSize = CGSize(width: 300, height: 200)
        static let testLines = 3
        static let millisecondsMultiplier = 1000.0
    }

    // MARK: - Public Interface

    /// Measure ReadMoreLabel performance with given text
    func measureReadMoreLabel(text: String, iterations: Int = Constants.defaultIterations) -> BenchmarkResult {
        assert(Thread.isMainThread, "UI operations must be executed on the main thread")

        var totalTime: Double = 0

        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()

            let label = ReadMoreLabel()
            label.frame = CGRect(origin: .zero, size: Constants.testFrameSize)
            label.numberOfLines = Constants.testLines
            label.text = text

            _ = label.sizeThatFits(CGSize(width: Constants.testFrameSize.width, height: .greatestFiniteMagnitude))

            let endTime = CFAbsoluteTimeGetCurrent()
            totalTime += (endTime - startTime)
        }

        return BenchmarkResult(
            averageTime: (totalTime / Double(iterations)) * Constants.millisecondsMultiplier,
            iterations: iterations,
            testName: "ReadMoreLabel"
        )
    }

    /// Measure UILabel performance with given text
    func measureUILabel(text: String, iterations: Int = Constants.defaultIterations) -> BenchmarkResult {
        assert(Thread.isMainThread, "UI operations must be executed on the main thread")

        var totalTime: Double = 0

        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()

            let label = UILabel()
            label.frame = CGRect(origin: .zero, size: Constants.testFrameSize)
            label.numberOfLines = Constants.testLines
            label.text = text

            _ = label.sizeThatFits(CGSize(width: Constants.testFrameSize.width, height: .greatestFiniteMagnitude))

            let endTime = CFAbsoluteTimeGetCurrent()
            totalTime += (endTime - startTime)
        }

        return BenchmarkResult(
            averageTime: (totalTime / Double(iterations)) * Constants.millisecondsMultiplier,
            iterations: iterations,
            testName: "UILabel"
        )
    }

    /// Compare ReadMoreLabel vs UILabel performance
    func comparePerformance(text: String, iterations: Int = Constants.defaultIterations) -> ComparisonResult {
        let readMoreResult = measureReadMoreLabel(text: text, iterations: iterations)
        let uiLabelResult = measureUILabel(text: text, iterations: iterations)

        return ComparisonResult(
            readMoreLabelResult: readMoreResult,
            uiLabelResult: uiLabelResult
        )
    }

    /// Measure text update performance
    func measureTextUpdatePerformance(texts: [String], iterations: Int = 10) -> BenchmarkResult {
        assert(Thread.isMainThread, "UI operations must be executed on the main thread")

        let label = ReadMoreLabel()
        label.frame = CGRect(origin: .zero, size: Constants.testFrameSize)
        label.numberOfLines = Constants.testLines

        var totalTime: Double = 0

        for _ in 0..<iterations {
            for text in texts {
                let startTime = CFAbsoluteTimeGetCurrent()

                label.text = text
                _ = label.sizeThatFits(CGSize(width: Constants.testFrameSize.width, height: .greatestFiniteMagnitude))

                let endTime = CFAbsoluteTimeGetCurrent()
                totalTime += (endTime - startTime)
            }
        }

        let totalOperations = iterations * texts.count

        return BenchmarkResult(
            averageTime: (totalTime / Double(totalOperations)) * Constants.millisecondsMultiplier,
            iterations: totalOperations,
            testName: "Text Update"
        )
    }
}
