import ReadMoreLabel
import UIKit
import Foundation

// MARK: - Main View Controller

/// Main View Controller following MVVM pattern
/// Single Responsibility: UI presentation and navigation
class ViewController: UIViewController {

    // MARK: - Properties

    private let tableView = UITableView()
    private lazy var viewModel = MainViewModel.create(navigationController: navigationController)
    private let cellStyle = CellStyleProvider.mainScreenStyle()

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupTableView()
    }

    // MARK: - Private Methods

    private func setupUI() {
        title = "ReadMoreLabel Examples"
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

        // Remove extra separators
        tableView.tableFooterView = UIView()
    }


}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let example = viewModel.item(at: indexPath.row)

        cell.textLabel?.text = example.title
        cell.detailTextLabel?.text = example.subtitle

        // Apply consistent styling using service
        CellStyleProvider.applyStyle(cellStyle, to: cell)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Delegate navigation logic to ViewModel
        viewModel.selectItem(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellStyle.rowHeight
    }
}
