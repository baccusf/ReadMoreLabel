import ReadMoreLabel
import UIKit

// MARK: - Main View Controller

class ViewController: UIViewController {
    private let tableView = UITableView()

    private let examples: [(title: String, subtitle: String, viewController: UIViewController.Type)] = [
        (
            title: "📋 Table View Examples",
            subtitle: "Multiple styles with different languages and positions",
            viewController: TableViewController.self
        ),
        (
            title: "🎬 Animation Examples",
            subtitle: "ScrollView with animation controls",
            viewController: LabelViewController.self
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupTableView()
    }

    private func setupUI() {
        title = "ReadMoreLabel Demo"
        view.backgroundColor = .systemBackground

        // Setup navigation bar - use standard title size
        navigationController?.navigationBar.prefersLargeTitles = false

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.tableView)

        NSLayoutConstraint.activate([
            self.tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            self.tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        // Style the table view
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let example = self.examples[indexPath.row]

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

        let example = self.examples[indexPath.row]

        // Create and present the selected view controller
        let viewController: UIViewController = if example.viewController == TableViewController.self {
            TableViewController()
        } else {
            LabelViewController()
        }

        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}
