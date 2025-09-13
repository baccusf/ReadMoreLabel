import ReadMoreLabel
import UIKit

// MARK: - Main View Controller

class ViewController: UIViewController {
    private let tableView = UITableView()
    private var progressAlert: UIAlertController?

    private let examples: [(title: String, subtitle: String, isPerformanceTest: Bool)] = [
        (
            title: "📋 Table View Examples",
            subtitle: "Multiple styles with different languages and positions",
            isPerformanceTest: false
        ),
        (
            title: "🎬 Animation Examples",
            subtitle: "ScrollView with animation controls",
            isPerformanceTest: false
        ),
        (
            title: "⚡ Performance Tests",
            subtitle: "Comprehensive performance measurement and analysis",
            isPerformanceTest: true
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
    }

    private func setupUI() {
        title = "ReadMoreLabel Demo"
        view.backgroundColor = .systemBackground

        // Setup navigation bar - use standard title size
        navigationController?.navigationBar.prefersLargeTitles = false

        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        // Style the table view
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let example = examples[indexPath.row]

        // Configure cell
        cell.textLabel?.text = example.title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cell.textLabel?.textColor = .label

        cell.detailTextLabel?.text = example.subtitle
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.numberOfLines = 2

        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default

        // Add custom styling
        cell.backgroundColor = .secondarySystemBackground
        cell.layer.cornerRadius = 12
        cell.layer.masksToBounds = true

        // Add some spacing between cells
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let example = examples[indexPath.row]

        if example.isPerformanceTest {
            // Execute performance test menu
            showPerformanceTestMenu()
        } else {
            // Navigate to existing view controllers
            let viewController: UIViewController = indexPath.row == 0 ?
                TableViewController() : LabelViewController()

            navigationController?.pushViewController(viewController, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }

    // MARK: - Performance Test Menu

    private func showPerformanceTestMenu() {
        let alert = UIAlertController(
            title: "⚡ Performance Tests",
            message: "Select ReadMoreLabel performance measurement",
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "📊 Basic Performance Test", style: .default) { _ in
            self.runBasicPerformanceTest()
        })

        alert.addAction(UIAlertAction(title: "💾 Memory Usage Test", style: .default) { _ in
            self.runMemoryUsageTest()
        })

        alert.addAction(UIAlertAction(title: "🔄 Text Update Performance", style: .default) { _ in
            self.runTextUpdateTest()
        })

        alert.addAction(UIAlertAction(title: "🎯 Comprehensive Performance Test", style: .default) { _ in
            self.runCompletePerformanceTest()
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        // iPad support
        if let popover = alert.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        present(alert, animated: true)
    }

    private func runBasicPerformanceTest() {
        showProgressAlert("Running Basic Performance Test...")

        DispatchQueue.global(qos: .userInitiated).async {
            let results = self.measureBasicPerformanceWithResults()

            DispatchQueue.main.async {
                self.dismissProgressAlert()
                self.showTestResults("Basic Performance Test Completed", message: results)
            }
        }
    }

    private func runMemoryUsageTest() {
        showProgressAlert("Running Memory Usage Test...")

        DispatchQueue.global(qos: .userInitiated).async {
            let results = self.measureMemoryUsageWithResults()

            DispatchQueue.main.async {
                self.dismissProgressAlert()
                self.showTestResults("Memory Usage Test Completed", message: results)
            }
        }
    }

    private func runTextUpdateTest() {
        showProgressAlert("Running Text Update Performance Test...")

        DispatchQueue.global(qos: .userInitiated).async {
            let results = self.measureTextUpdatePerformanceWithResults()

            DispatchQueue.main.async {
                self.dismissProgressAlert()
                self.showTestResults("Text Update Performance Test Completed", message: results)
            }
        }
    }

    private func runCompletePerformanceTest() {
        showProgressAlert("Running Comprehensive Performance Test... (approx. 30 seconds)")

        DispatchQueue.global(qos: .userInitiated).async {
            let results = self.runAllPerformanceTestsWithResults()

            DispatchQueue.main.async {
                self.dismissProgressAlert()
                self.showComprehensiveResults(with: results)
            }
        }
    }

    // MARK: - Performance Test Implementation

    private func measureBasicPerformanceWithResults() -> String {
        print("🚀 ReadMoreLabel Basic Performance Test")
        print("=" * 50)

        let testTexts = [
            "Short text",
            "This is a medium length text. It is expected to be approximately 2-3 lines long. This is typical length written in English.",
            """
            This is very long text that will be displayed across multiple lines. This text was written to accurately measure the performance of ReadMoreLabel.
            You can check what performance ReadMoreLabel shows in long text displayed across multiple lines.
            It includes complex tasks such as text processing using TextKit, line count calculation, and truncation position determination.
            """
        ]

        var results = "📊 Basic Performance Test Results\n\n"

        for (index, text) in testTexts.enumerated() {
            print("Test case \(index + 1) (length: \(text.count) chars)")

            let readMoreTime = measureReadMoreLabelOnMain(text: text)
            let uiLabelTime = measureUILabelOnMain(text: text)
            let overhead = readMoreTime/max(uiLabelTime, 0.001)

            let testResult = """
            Test \(index + 1) (length: \(text.count) chars):
            ReadMoreLabel: \(String(format: "%.3f", readMoreTime))ms
            UILabel: \(String(format: "%.3f", uiLabelTime))ms
            Overhead: \(String(format: "%.1f", overhead))x

            """

            results += testResult

            print("  ReadMoreLabel: \(String(format: "%.3f", readMoreTime))ms")
            print("  UILabel:       \(String(format: "%.3f", uiLabelTime))ms")
            print("  Overhead:      \(String(format: "%.1f", overhead))x")
            print()
        }

        return results
    }

    private func measureBasicPerformance() {
        print("🚀 ReadMoreLabel Basic Performance Test")
        print("=" * 50)

        let testTexts = [
            "Short text",
            "This is a medium length text. It is expected to be approximately 2-3 lines long. This is typical length written in English.",
            """
            This is very long text that will be displayed across multiple lines. This text was written to accurately measure the performance of ReadMoreLabel.
            You can check what performance ReadMoreLabel shows in long text displayed across multiple lines.
            It includes complex tasks such as text processing using TextKit, line count calculation, and truncation position determination.
            """
        ]

        for (index, text) in testTexts.enumerated() {
            print("Test case \(index + 1) (length: \(text.count) chars)")

            let readMoreTime = measureReadMoreLabel(text: text)
            let uiLabelTime = measureUILabel(text: text)

            print("  ReadMoreLabel: \(String(format: "%.3f", readMoreTime))ms")
            print("  UILabel:       \(String(format: "%.3f", uiLabelTime))ms")
            print("  Overhead:      \(String(format: "%.1f", readMoreTime/max(uiLabelTime, 0.001)))x")
            print()
        }
    }

    private func measureReadMoreLabelOnMain(text: String) -> Double {
        var result: Double = 0

        DispatchQueue.main.sync {
            result = self.measureReadMoreLabel(text: text)
        }

        return result
    }

    private func measureUILabelOnMain(text: String) -> Double {
        var result: Double = 0

        DispatchQueue.main.sync {
            result = self.measureUILabel(text: text)
        }

        return result
    }

    private func measureReadMoreLabel(text: String) -> Double {
        let iterations = 50
        var totalTime: Double = 0

        // Perform UI operations on main thread
        assert(Thread.isMainThread, "UI operations must be executed on the main thread")

        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()

            let label = ReadMoreLabel()
            label.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
            label.numberOfLines = 3
            label.text = text

            // Use sizeThatFits instead of layoutIfNeeded to bypass layout system
            _ = label.sizeThatFits(CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude))

            let endTime = CFAbsoluteTimeGetCurrent()
            totalTime += (endTime - startTime)
        }

        return (totalTime / Double(iterations)) * 1000
    }

    private func measureUILabel(text: String) -> Double {
        let iterations = 50
        var totalTime: Double = 0

        // Perform UI operations on main thread
        assert(Thread.isMainThread, "UI operations must be executed on the main thread")

        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()

            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
            label.numberOfLines = 3
            label.text = text

            // Use sizeThatFits instead of layoutIfNeeded to bypass layout system
            _ = label.sizeThatFits(CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude))

            let endTime = CFAbsoluteTimeGetCurrent()
            totalTime += (endTime - startTime)
        }

        return (totalTime / Double(iterations)) * 1000
    }

    private func measureMemoryUsageWithResults() -> String {
        var results = "💾 Memory Usage Measurement Results\n\n"

        DispatchQueue.main.sync {
            print("💾 Memory Usage Measurement")
            print("=" * 50)

            let memoryBefore = self.getMemoryUsage()
            print("Base Memory: \(memoryBefore)KB")

            // ReadMoreLabel 100 items create
            var readMoreLabels: [ReadMoreLabel] = []
            for i in 0..<100 {
                let label = ReadMoreLabel()
                label.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
                label.numberOfLines = 3
                label.text = "ReadMore Test \(i): Long text including sample data for memory usage measurement."
                readMoreLabels.append(label)
            }

            let memoryAfterReadMore = self.getMemoryUsage()
            let readMoreUsage = memoryAfterReadMore - memoryBefore

            readMoreLabels.removeAll()

            // UILabel 100 items create (for comparison)
            var uiLabels: [UILabel] = []
            for i in 0..<100 {
                let label = UILabel()
                label.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
                label.numberOfLines = 3
                label.text = "UILabel Test \(i): Long text including sample data for memory usage measurement."
                uiLabels.append(label)
            }

            let memoryAfterUILabel = self.getMemoryUsage()
            let uiLabelUsage = memoryAfterUILabel - memoryAfterReadMore

            results += """
            Base Memory: \(memoryBefore)KB
            ReadMoreLabel (100 items): \(readMoreUsage)KB
            Average per label: \(readMoreUsage/100)KB
            UILabel (100 items): \(uiLabelUsage)KB
            Average per label: \(uiLabelUsage/100)KB
            Memory Overhead: \(readMoreUsage - uiLabelUsage)KB
            """

            print("ReadMoreLabel (100 items): \(readMoreUsage)KB")
            print("  Average per label: \(readMoreUsage/100)KB")
            print("UILabel (100 items):       \(uiLabelUsage)KB")
            print("  Average per label: \(uiLabelUsage/100)KB")
            print("Memory Overhead:       \(readMoreUsage - uiLabelUsage)KB")

            uiLabels.removeAll()
        }

        return results
    }

    private func measureMemoryUsage() {
        print("💾 Memory Usage Measurement")
        print("=" * 50)

        let memoryBefore = getMemoryUsage()
        print("Base Memory: \(memoryBefore)KB")

        // Perform UI operations on main thread
        assert(Thread.isMainThread, "UI operations must be executed on the main thread")

        // ReadMoreLabel 100 items create
        var readMoreLabels: [ReadMoreLabel] = []
        for i in 0..<100 {
            let label = ReadMoreLabel()
            label.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
            label.numberOfLines = 3
            label.text = "ReadMore Test \(i): Long text including sample data for memory usage measurement."
            readMoreLabels.append(label)
        }

        let memoryAfterReadMore = getMemoryUsage()
        let readMoreUsage = memoryAfterReadMore - memoryBefore

        readMoreLabels.removeAll()

        // UILabel 100 items create (for comparison)
        var uiLabels: [UILabel] = []
        for i in 0..<100 {
            let label = UILabel()
            label.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
            label.numberOfLines = 3
            label.text = "UILabel Test \(i): Long text including sample data for memory usage measurement."
            uiLabels.append(label)
        }

        let memoryAfterUILabel = getMemoryUsage()
        let uiLabelUsage = memoryAfterUILabel - memoryAfterReadMore

        print("ReadMoreLabel (100 items): \(readMoreUsage)KB")
        print("  Average per label: \(readMoreUsage/100)KB")
        print("UILabel (100 items):       \(uiLabelUsage)KB")
        print("  Average per label: \(uiLabelUsage/100)KB")
        print("Memory Overhead:       \(readMoreUsage - uiLabelUsage)KB")

        uiLabels.removeAll()
    }

    private func getMemoryUsage() -> Int {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }

        return kerr == KERN_SUCCESS ? Int(info.resident_size) / 1024 : 0
    }

    private func measureTextUpdatePerformanceWithResults() -> String {
        var results = "🔄 Text Update Performance Results\n\n"

        DispatchQueue.main.sync {
            print("🔄 Text Update Performance Measurement")
            print("=" * 50)

            let testTexts = [
                "Short text",
                "This is a medium length text. It can be displayed across multiple lines.",
                "This is very long text. This text is displayed across multiple lines and is used to measure the text Update performance of ReadMoreLabel. It simulates situations that require complex text processing."
            ]

            let readMoreLabel = ReadMoreLabel()
            readMoreLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
            readMoreLabel.numberOfLines = 3
            readMoreLabel.text = testTexts[0]

            let uiLabel = UILabel()
            uiLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
            uiLabel.numberOfLines = 3
            uiLabel.text = testTexts[0]

            for (index, newText) in testTexts.enumerated() {
                print("Update \(index + 1) (length: \(newText.count)chars)")

                let readMoreUpdateTime = self.measureTextUpdate(label: readMoreLabel, newText: newText)
                let uiLabelUpdateTime = self.measureTextUpdate(label: uiLabel, newText: newText)
                let overhead = readMoreUpdateTime/max(uiLabelUpdateTime, 0.001)

                results += """
                Update \(index + 1) (length: \(newText.count)chars):
                ReadMoreLabel: \(String(format: "%.3f", readMoreUpdateTime))ms
                UILabel: \(String(format: "%.3f", uiLabelUpdateTime))ms
                Overhead: \(String(format: "%.1f", overhead))x

                """

                print("  ReadMoreLabel: \(String(format: "%.3f", readMoreUpdateTime))ms")
                print("  UILabel:       \(String(format: "%.3f", uiLabelUpdateTime))ms")
                print("  Overhead:      \(String(format: "%.1f", overhead))x")
                print()
            }
        }

        return results
    }

    private func measureTextUpdatePerformance() {
        print("🔄 Text Update Performance Measurement")
        print("=" * 50)

        let testTexts = [
            "Short text",
            "This is a medium length text. It can be displayed across multiple lines.",
            "This is very long text. This text is displayed across multiple lines and is used to measure the text Update performance of ReadMoreLabel. It simulates situations that require complex text processing."
        ]

        let readMoreLabel = ReadMoreLabel()
        readMoreLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        readMoreLabel.numberOfLines = 3
        readMoreLabel.text = testTexts[0]

        let uiLabel = UILabel()
        uiLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
        uiLabel.numberOfLines = 3
        uiLabel.text = testTexts[0]

        for (index, newText) in testTexts.enumerated() {
            print("Update \(index + 1) (length: \(newText.count)chars)")

            let readMoreUpdateTime = measureTextUpdate(label: readMoreLabel, newText: newText)
            let uiLabelUpdateTime = measureTextUpdate(label: uiLabel, newText: newText)

            print("  ReadMoreLabel: \(String(format: "%.3f", readMoreUpdateTime))ms")
            print("  UILabel:       \(String(format: "%.3f", uiLabelUpdateTime))ms")
            print("  Overhead:      \(String(format: "%.1f", readMoreUpdateTime/max(uiLabelUpdateTime, 0.001)))x")
            print()
        }
    }

    private func measureTextUpdate<T: UILabel>(label: T, newText: String) -> Double {
        let iterations = 30
        var totalTime: Double = 0

        // Perform UI operations on main thread
        assert(Thread.isMainThread, "UI operations must be executed on the main thread")

        for _ in 0..<iterations {
            let startTime = CFAbsoluteTimeGetCurrent()

            label.text = newText
            // Use sizeThatFits instead of layoutIfNeeded
            _ = label.sizeThatFits(CGSize(width: 300, height: CGFloat.greatestFiniteMagnitude))

            let endTime = CFAbsoluteTimeGetCurrent()
            totalTime += (endTime - startTime)
        }

        return (totalTime / Double(iterations)) * 1000
    }

    private func runAllPerformanceTestsWithResults() -> String {
        print("🎯 ReadMoreLabel Comprehensive Performance Test")
        print("=" * 60)

        var allResults = "🎯 ReadMoreLabel Comprehensive Performance Test Results\n" + ("=" * 60) + "\n\n"

        let basicResults = measureBasicPerformanceWithResults()
        allResults += basicResults + "\n"

        let memoryResults = measureMemoryUsageWithResults()
        allResults += memoryResults + "\n"

        let updateResults = measureTextUpdatePerformanceWithResults()
        allResults += updateResults + "\n"

        allResults += "✅ All performance tests have been completed."

        print("✅ Comprehensive Performance Test Completed")
        print("=" * 60)

        return allResults
    }

    private func runAllPerformanceTests() {
        print("🎯 ReadMoreLabel Comprehensive Performance Test")
        print("=" * 60)

        measureBasicPerformance()
        print()

        measureMemoryUsage()
        print()

        measureTextUpdatePerformance()
        print()

        print("✅ Comprehensive Performance Test Completed")
        print("=" * 60)
    }

    // MARK: - UI Helper Methods

    private func showProgressAlert(_ message: String) {
        progressAlert = UIAlertController(title: "Performance Test", message: message, preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()

        progressAlert?.view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: progressAlert!.view.centerXAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: progressAlert!.view.centerYAnchor, constant: 20)
        ])

        present(progressAlert!, animated: true)
    }

    private func dismissProgressAlert() {
        progressAlert?.dismiss(animated: true) { [weak self] in
            self?.progressAlert = nil
        }
    }

    private func showTestResults(_ title: String, message: String) {
        // Wait briefly if another presentation is in progress before showing
        if presentedViewController != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showTestResults(title, message: message)
            }
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showComprehensiveResults(with results: String) {
        // Wait briefly if another presentation is in progress before showing
        if presentedViewController != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.showComprehensiveResults(with: results)
            }
            return
        }

        let alert = UIAlertController(
            title: "🎉 Comprehensive Performance Test Completed",
            message: results,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - String Extension

private extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
