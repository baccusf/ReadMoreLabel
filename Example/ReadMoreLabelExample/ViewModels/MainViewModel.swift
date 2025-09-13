import Foundation
import UIKit

// MARK: - Main View Model

/// MVVM ViewModel for main screen
/// Single Responsibility: Main screen business logic and navigation coordination
final class MainViewModel {

    // MARK: - Types

    struct ExampleItem {
        let title: String
        let subtitle: String
        let type: ExampleType
    }

    enum ExampleType {
        case tableView
        case animation
        case performance
    }

    // MARK: - Private Properties

    private let navigationService: NavigationService

    // MARK: - Public Properties

    let examples: [ExampleItem] = [
        ExampleItem(
            title: "📋 Table View Examples",
            subtitle: "Multiple styles with different languages and positions",
            type: .tableView
        ),
        ExampleItem(
            title: "🎬 Animation Examples",
            subtitle: "ScrollView with animation controls",
            type: .animation
        ),
        ExampleItem(
            title: "⚡ Performance Tests",
            subtitle: "Comprehensive performance measurement and analysis",
            type: .performance
        )
    ]

    // MARK: - Initialization

    init(navigationService: NavigationService) {
        self.navigationService = navigationService
    }

    // MARK: - Public Interface

    func numberOfItems() -> Int {
        return examples.count
    }

    func item(at index: Int) -> ExampleItem {
        return examples[index]
    }

    func selectItem(at index: Int) {
        guard index < examples.count else { return }

        let selectedExample = examples[index]

        switch selectedExample.type {
        case .tableView:
            navigationService.navigateToTableViewExamples()

        case .animation:
            navigationService.navigateToAnimationExamples()

        case .performance:
            navigationService.presentPerformanceTestOptions()
        }
    }
}

// MARK: - Factory Methods

extension MainViewModel {

    /// Create MainViewModel with dependencies injected
    static func create(navigationController: UINavigationController?) -> MainViewModel {
        let navigationService = NavigationService(navigationController: navigationController)
        return MainViewModel(navigationService: navigationService)
    }
}
