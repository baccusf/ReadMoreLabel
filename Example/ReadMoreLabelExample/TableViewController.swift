import ReadMoreLabel
import UIKit

@available(iOS 16.0, *)
class TableViewController: UIViewController {
    // MARK: - Properties
    
    private let tableView = UITableView()
    private let viewModel = TableViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { _ in
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        })
    }

    private func setupUI() {
        title = "ReadMoreLabel Examples"
        view.backgroundColor = .systemBackground

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
        tableView.register(ExampleTableViewCell.self, forCellReuseIdentifier: "ExampleCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        tableView.separatorStyle = .singleLine
        
        // Section header height 설정
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = 63
        tableView.sectionFooterHeight = 0
    }

    private func bindViewModel() {
        // ViewModel의 변경사항을 감지하여 UI 업데이트
        // 실제 프로젝트에서는 Combine 또는 다른 reactive framework를 사용할 수 있습니다.
    }
    
    @objc private func animationSwitchChanged(_ sender: UISwitch) {
        viewModel.toggleAnimation(sender.isOn)
    }
}

// MARK: - UITableViewDataSource

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sampleData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleCell", for: indexPath) as! ExampleTableViewCell
        cell.configure(
            with: viewModel.sampleData[indexPath.row],
            isExpanded: viewModel.expandedStates[indexPath.row],
            delegate: self
        )

        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemBackground

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let animationLabel = UILabel()
        animationLabel.text = "Enable Animation:"
        animationLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        animationLabel.textColor = .label

        let animationSwitch = UISwitch()
        animationSwitch.isOn = viewModel.isAnimationEnabled
        animationSwitch.addTarget(self, action: #selector(animationSwitchChanged(_:)), for: .valueChanged)

        stackView.addArrangedSubview(animationLabel)
        stackView.addArrangedSubview(animationSwitch)
        
        headerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12)
        ])

        return headerView
    }
}

// MARK: - UITableViewDelegate

extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - ReadMoreLabelDelegate

@available(iOS 16.0, *)
extension TableViewController: ReadMoreLabelDelegate {
    func readMoreLabel(_ label: ReadMoreLabel, didChangeExpandedState isExpanded: Bool) {
        // label의 중심점을 tableView 좌표계로 변환
        let labelCenterInTableView = label.convert(label.center, to: tableView)

        // 해당 위치의 indexPath를 찾음
        guard let indexPath = tableView.indexPathForRow(at: labelCenterInTableView) else {
            return
        }

        // ViewModel을 통해 상태 업데이트
        viewModel.updateExpandedState(at: indexPath.row, isExpanded: isExpanded)

        // 테이블 뷰 업데이트 (높이 변경 반영)
        if viewModel.isAnimationEnabled {
            UIView.animate(withDuration: 0.3) {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        } else {
            UIView.performWithoutAnimation {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
        }
    }
}
