import Foundation
import UIKit

// MARK: - Performance Reporter Service

/// Single Responsibility: Performance result presentation and reporting
final class PerformanceReporter {

    // MARK: - Types

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

    // MARK: - Private Properties

    private weak var presentingViewController: UIViewController?

    // MARK: - Initialization

    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }

    // MARK: - Public Interface

    /// Present performance result as alert
    func presentResult(_ report: PerformanceReport) {
        guard let viewController = presentingViewController else { return }

        // Wait briefly if another presentation is in progress before showing
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

    /// Create basic performance report
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

    /// Create memory usage report
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

    /// Create comprehensive performance report
    func createComprehensiveReport(
        basicResults: [PerformanceMeasurement.ComparisonResult],
        memoryResults: [MemoryProfiler.MemoryUsageResult],
        textUpdateResult: PerformanceMeasurement.BenchmarkResult
    ) -> PerformanceReport {
        var sections: [PerformanceReport.ReportSection] = []

        // Basic performance section
        let basicContent = basicResults.enumerated().map { index, comparison in
            let testNumber = index + 1
            return "Test \(testNumber): \(comparison.formattedRatio)x slower (\(comparison.readMoreLabelResult.formattedTime)ms vs \(comparison.uiLabelResult.formattedTime)ms)"
        }.joined(separator: "\n")

        sections.append(PerformanceReport.ReportSection(
            title: "Basic Performance",
            content: basicContent
        ))

        // Memory usage section
        let memoryContent = memoryResults.map { result in
            "\(result.testName): \(result.formattedMemoryIncrease)"
        }.joined(separator: "\n")

        sections.append(PerformanceReport.ReportSection(
            title: "Memory Usage",
            content: memoryContent
        ))

        // Text update section
        sections.append(PerformanceReport.ReportSection(
            title: "Text Update Performance",
            content: "Average: \(textUpdateResult.formattedTime)ms per update"
        ))

        return PerformanceReport(
            title: "🎉 Comprehensive Performance Test Results",
            sections: sections
        )
    }

    // MARK: - Private Methods

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

// MARK: - String Extension

private extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}