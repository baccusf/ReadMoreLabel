import Foundation
import UIKit
import mach

// MARK: - Performance Module (MVVM + SOLID)

/// Performance measurement service following Single Responsibility Principle
final class PerformanceMeasurement {

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

    private enum Constants {
        static let defaultIterations = 50
        static let testFrameSize = CGSize(width: 300, height: 200)
        static let testLines = 3
        static let millisecondsMultiplier = 1000.0
    }

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

    func comparePerformance(text: String, iterations: Int = Constants.defaultIterations) -> ComparisonResult {
        let readMoreResult = measureReadMoreLabel(text: text, iterations: iterations)
        let uiLabelResult = measureUILabel(text: text, iterations: iterations)

        return ComparisonResult(
            readMoreLabelResult: readMoreResult,
            uiLabelResult: uiLabelResult
        )
    }

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

/// Memory profiler service following Single Responsibility Principle
final class MemoryProfiler {

    struct MemorySnapshot {
        let timestamp: Date
        let residentMemoryMB: Double
        let virtualMemoryMB: Double

        var formattedResident: String {
            return String(format: "%.2f MB", residentMemoryMB)
        }
    }

    struct MemoryUsageResult {
        let initialSnapshot: MemorySnapshot
        let finalSnapshot: MemorySnapshot
        let peakSnapshot: MemorySnapshot
        let testName: String

        var memoryIncrease: Double {
            return finalSnapshot.residentMemoryMB - initialSnapshot.residentMemoryMB
        }

        var formattedMemoryIncrease: String {
            let increase = memoryIncrease
            let sign = increase >= 0 ? "+" : ""
            return String(format: "%@%.2f MB", sign, increase)
        }
    }

    private enum Constants {
        static let bytesToMB = 1024.0 * 1024.0
        static let measurementDelay: TimeInterval = 0.01
    }

    private var snapshots: [MemorySnapshot] = []

    func takeSnapshot() -> MemorySnapshot {
        let memoryInfo = getCurrentMemoryInfo()

        let snapshot = MemorySnapshot(
            timestamp: Date(),
            residentMemoryMB: Double(memoryInfo.resident_size) / Constants.bytesToMB,
            virtualMemoryMB: Double(memoryInfo.virtual_size) / Constants.bytesToMB
        )

        snapshots.append(snapshot)
        return snapshot
    }

    func measureMemoryUsage<T>(testName: String, operation: () throws -> T) rethrows -> (result: T, memoryResult: MemoryUsageResult) {
        snapshots.removeAll()
        let initialSnapshot = takeSnapshot()

        let result = try operation()

        Thread.sleep(forTimeInterval: Constants.measurementDelay)

        let finalSnapshot = takeSnapshot()
        let peakSnapshot = findPeakMemoryUsage() ?? finalSnapshot

        let memoryResult = MemoryUsageResult(
            initialSnapshot: initialSnapshot,
            finalSnapshot: finalSnapshot,
            peakSnapshot: peakSnapshot,
            testName: testName
        )

        return (result: result, memoryResult: memoryResult)
    }

    private func getCurrentMemoryInfo() -> mach_task_basic_info {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            return mach_task_basic_info()
        }

        return info
    }

    private func findPeakMemoryUsage() -> MemorySnapshot? {
        return snapshots.max { $0.residentMemoryMB < $1.residentMemoryMB }
    }
}

/// Performance reporter service following Single Responsibility Principle
final class PerformanceReporter {

    struct PerformanceReport {
        let title: String
        let sections: [ReportSection]

        struct ReportSection {
            let title: String
            let content: String
        }

        var formattedReport: String {
            var report = ""
            for section in sections {
                if !report.isEmpty {
                    report += "\n\n"
                }
                report += "📊 \(section.title)\n"
                report += section.content
            }
            return report
        }
    }

    private weak var presentingViewController: UIViewController?

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    func presentResult(_ report: PerformanceReport) {
        guard let viewController = presentingViewController else { return }

        DispatchQueue.main.async { [weak viewController] in
            guard let viewController = viewController else { return }

            if viewController.presentedViewController != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showAlert(viewController: viewController, report: report)
                }
            } else {
                self.showAlert(viewController: viewController, report: report)
            }
        }
    }

    func createBasicReport(comparisons: [PerformanceMeasurement.ComparisonResult]) -> PerformanceReport {
        var sections: [PerformanceReport.ReportSection] = []

        for (index, comparison) in comparisons.enumerated() {
            let testNumber = index + 1
            let content = """
            ReadMoreLabel: \(comparison.readMoreLabelResult.formattedTime)ms
            UILabel: \(comparison.uiLabelResult.formattedTime)ms
            Ratio: \(comparison.formattedRatio)x slower
            """

            sections.append(PerformanceReport.ReportSection(
                title: "Test \(testNumber)",
                content: content
            ))
        }

        return PerformanceReport(
            title: "🚀 Basic Performance Test Results",
            sections: sections
        )
    }

    func createMemoryReport(results: [MemoryProfiler.MemoryUsageResult]) -> PerformanceReport {
        var sections: [PerformanceReport.ReportSection] = []

        for result in results {
            let content = """
            Initial: \(result.initialSnapshot.formattedResident)
            Final: \(result.finalSnapshot.formattedResident)
            Peak: \(result.peakSnapshot.formattedResident)
            Change: \(result.formattedMemoryIncrease)
            """

            sections.append(PerformanceReport.ReportSection(
                title: result.testName,
                content: content
            ))
        }

        return PerformanceReport(
            title: "💾 Memory Usage Analysis",
            sections: sections
        )
    }

    func createComprehensiveReport(
        basicResults: [PerformanceMeasurement.ComparisonResult],
        memoryResults: [MemoryProfiler.MemoryUsageResult],
        textUpdateResult: PerformanceMeasurement.BenchmarkResult
    ) -> PerformanceReport {
        var sections: [PerformanceReport.ReportSection] = []

        let basicContent = basicResults.enumerated().map { index, comparison in
            let testNumber = index + 1
            return "Test \(testNumber): \(comparison.formattedRatio)x slower (\(comparison.readMoreLabelResult.formattedTime)ms vs \(comparison.uiLabelResult.formattedTime)ms)"
        }.joined(separator: "\n")

        sections.append(PerformanceReport.ReportSection(
            title: "Basic Performance",
            content: basicContent
        ))

        let memoryContent = memoryResults.map { result in
            "\(result.testName): \(result.formattedMemoryIncrease)"
        }.joined(separator: "\n")

        sections.append(PerformanceReport.ReportSection(
            title: "Memory Usage",
            content: memoryContent
        ))

        sections.append(PerformanceReport.ReportSection(
            title: "Text Update Performance",
            content: "Average: \(textUpdateResult.formattedTime)ms per update"
        ))

        return PerformanceReport(
            title: "🎉 Comprehensive Performance Test Results",
            sections: sections
        )
    }

    private func showAlert(viewController: UIViewController, report: PerformanceReport) {
        let alert = UIAlertController(
            title: report.title,
            message: report.formattedReport,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
}

/// MVVM ViewModel coordinating performance testing services
final class PerformanceTestViewModel {

    private let performanceMeasurement: PerformanceMeasurement
    private let memoryProfiler: MemoryProfiler
    private let reporter: PerformanceReporter

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

    init(
        performanceMeasurement: PerformanceMeasurement = PerformanceMeasurement(),
        memoryProfiler: MemoryProfiler = MemoryProfiler(),
        reporter: PerformanceReporter
    ) {
        self.performanceMeasurement = performanceMeasurement
        self.memoryProfiler = memoryProfiler
        self.reporter = reporter
    }

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

    func executeComprehensiveTest() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.executeComprehensiveTest()
            }
            return
        }

        var basicResults: [PerformanceMeasurement.ComparisonResult] = []
        for text in testTexts {
            let comparison = performanceMeasurement.comparePerformance(text: text)
            basicResults.append(comparison)
        }

        var memoryResults: [MemoryProfiler.MemoryUsageResult] = []
        for (index, text) in testTexts.enumerated() {
            let testName = "Test \(index + 1)"

            let (_, memoryResult) = memoryProfiler.measureMemoryUsage(testName: testName) {
                return performanceMeasurement.measureReadMoreLabel(text: text)
            }

            memoryResults.append(memoryResult)
        }

        let textUpdateResult = performanceMeasurement.measureTextUpdatePerformance(texts: textUpdateTexts)

        let report = reporter.createComprehensiveReport(
            basicResults: basicResults,
            memoryResults: memoryResults,
            textUpdateResult: textUpdateResult
        )

        reporter.presentResult(report)
    }

    static func create(for viewController: UIViewController) -> PerformanceTestViewModel {
        let reporter = PerformanceReporter(presentingViewController: viewController)

        return PerformanceTestViewModel(
            performanceMeasurement: PerformanceMeasurement(),
            memoryProfiler: MemoryProfiler(),
            reporter: reporter
        )
    }
}