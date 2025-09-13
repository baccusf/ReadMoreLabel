import Foundation
import UIKit

// MARK: - Navigation Service

/// Single Responsibility: Navigation logic and view controller coordination
final class NavigationService {

    // MARK: - Private Properties

    private weak var navigationController: UINavigationController?

    // MARK: - Initialization

    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    // MARK: - Public Interface

    func navigateToTableViewExamples() {
        let tableViewController = TableViewController()
        navigationController?.pushViewController(tableViewController, animated: true)
    }

    func navigateToAnimationExamples() {
        let animationViewController = AnimationExampleViewController()
        navigationController?.pushViewController(animationViewController, animated: true)
    }

    func presentPerformanceTestOptions() {
        guard let viewController = navigationController?.topViewController else { return }

        let alert = UIAlertController(
            title: "⚡ Performance Tests",
            message: "Choose the type of performance test to run:",
            preferredStyle: .actionSheet
        )

        let performanceViewModel = PerformanceTestViewModel.create(for: viewController)

        // Basic Performance Test
        alert.addAction(UIAlertAction(title: "🚀 Basic Performance Test", style: .default) { _ in
            performanceViewModel.executeBasicPerformanceTest()
        })

        // Memory Usage Analysis
        alert.addAction(UIAlertAction(title: "💾 Memory Usage Analysis", style: .default) { _ in
            performanceViewModel.executeMemoryAnalysis()
        })

        // Comprehensive Performance Test
        alert.addAction(UIAlertAction(title: "🎉 Comprehensive Test", style: .default) { _ in
            performanceViewModel.executeComprehensiveTest()
        })

        // Cancel
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // For iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }

        viewController.present(alert, animated: true)
    }
}