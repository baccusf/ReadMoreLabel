import Foundation
import UIKit

// MARK: - Performance Test ViewModel

/// MVVM ViewModel: Coordinates performance testing services and manages test data
final class PerformanceTestViewModel {

    // MARK: - Services (Dependency Injection)

    private let performanceMeasurement: PerformanceMeasurement
    private let memoryProfiler: MemoryProfiler
    private let reporter: PerformanceReporter

    // MARK: - Test Data

    private let testTexts = [
        "Short text",
        "This is a medium length text. It is expected to be approximately 2-3 lines long. This is typical length written in English.",
        """
        This is very long text that will be displayed across multiple lines. This text was written to accurately measure the performance of ReadMoreLabel.
        You can check what performance ReadMoreLabel shows in long text displayed across multiple lines.
        It includes complex tasks such as text processing using TextKit, line count calculation, and truncation position determination.
        """
    ]

    private let textUpdateTexts = [
        "First text for update test",
        "Second text with different length for testing",
        "Third text that is much longer and will require more processing time",
        "Fourth text",
        "Final text for the update performance measurement"
    ]

    // MARK: - Initialization

    init(
        performanceMeasurement: PerformanceMeasurement = PerformanceMeasurement(),
        memoryProfiler: MemoryProfiler = MemoryProfiler(),
        reporter: PerformanceReporter
    ) {
        self.performanceMeasurement = performanceMeasurement
        self.memoryProfiler = memoryProfiler
        self.reporter = reporter
    }

    // MARK: - Public Interface

    /// Execute basic performance test
    func executeBasicPerformanceTest() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.executeBasicPerformanceTest()
            }
            return
        }

        var comparisonResults: [PerformanceMeasurement.ComparisonResult] = []

        for text in testTexts {
            let comparison = performanceMeasurement.comparePerformance(text: text)
            comparisonResults.append(comparison)
        }

        let report = reporter.createBasicReport(comparisons: comparisonResults)
        reporter.presentResult(report)
    }

    /// Execute memory usage analysis
    func executeMemoryAnalysis() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.executeMemoryAnalysis()
            }
            return
        }

        var memoryResults: [MemoryProfiler.MemoryUsageResult] = []

        for (index, text) in testTexts.enumerated() {
            let testName = "Test \(index + 1)"

            let (_, memoryResult) = memoryProfiler.measureMemoryUsage(testName: testName) {
                return performanceMeasurement.measureReadMoreLabel(text: text)
            }

            memoryResults.append(memoryResult)
        }

        let report = reporter.createMemoryReport(results: memoryResults)
        reporter.presentResult(report)
    }

    /// Execute comprehensive performance test
    func executeComprehensiveTest() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.executeComprehensiveTest()
            }
            return
        }

        // Basic performance tests
        var basicResults: [PerformanceMeasurement.ComparisonResult] = []
        for text in testTexts {
            let comparison = performanceMeasurement.comparePerformance(text: text)
            basicResults.append(comparison)
        }

        // Memory analysis
        var memoryResults: [MemoryProfiler.MemoryUsageResult] = []
        for (index, text) in testTexts.enumerated() {
            let testName = "Test \(index + 1)"

            let (_, memoryResult) = memoryProfiler.measureMemoryUsage(testName: testName) {
                return performanceMeasurement.measureReadMoreLabel(text: text)
            }

            memoryResults.append(memoryResult)
        }

        // Text update performance
        let textUpdateResult = performanceMeasurement.measureTextUpdatePerformance(texts: textUpdateTexts)

        // Generate comprehensive report
        let report = reporter.createComprehensiveReport(
            basicResults: basicResults,
            memoryResults: memoryResults,
            textUpdateResult: textUpdateResult
        )

        reporter.presentResult(report)
    }

    /// Get test data for external use
    func getTestTexts() -> [String] {
        return testTexts
    }

    /// Get text update test data
    func getTextUpdateTexts() -> [String] {
        return textUpdateTexts
    }
}

// MARK: - Factory Methods

extension PerformanceTestViewModel {

    /// Create ViewModel with dependencies injected for given view controller
    static func create(for viewController: UIViewController) -> PerformanceTestViewModel {
        let reporter = PerformanceReporter(presentingViewController: viewController)

        return PerformanceTestViewModel(
            performanceMeasurement: PerformanceMeasurement(),
            memoryProfiler: MemoryProfiler(),
            reporter: reporter
        )
    }
}