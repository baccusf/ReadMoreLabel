import ReadMoreLabel
import UIKit

// MARK: - Table View Example Controller

/// Table View Examples showing ReadMoreLabel in table cells
final class TableExampleViewController: UIViewController {

    // MARK: - Properties

    private let tableView = UITableView()

    private let examples = [
        "This is a short text example.",
        "This is a medium length text that should span approximately 2-3 lines when displayed in a table cell with standard font size.",
        "This is a very long text example that will definitely require multiple lines and should demonstrate the ReadMoreLabel functionality when used in table view cells with various content lengths and different text wrapping scenarios."
    ]

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Table View Examples"
        setupTableView()
    }

    // MARK: - Private Methods

    private func setupTableView() {
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource

extension TableExampleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examples.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Remove existing ReadMoreLabel if any
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }

        let readMoreLabel = ReadMoreLabel()
        readMoreLabel.translatesAutoresizingMaskIntoConstraints = false
        readMoreLabel.text = examples[indexPath.row]
        readMoreLabel.numberOfLines = 3
        readMoreLabel.font = .systemFont(ofSize: 16)

        cell.contentView.addSubview(readMoreLabel)

        NSLayoutConstraint.activate([
            readMoreLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 16),
            readMoreLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            readMoreLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
            readMoreLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -16)
        ])

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TableExampleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}