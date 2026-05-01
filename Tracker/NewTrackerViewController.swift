//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 28.04.26.
//

import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class NewTrackerViewController: UIViewController {
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    private let nameTrackerTextField = UITextField()
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    
    private var selectedSchedule: [Weekday] = []
    private let rows = ["Категория", "Расписание"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
        updateCreateButtonState()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Новая привычка"
        navigationController?.navigationBar.tintColor = UIColor(hex: "#1A1B22")
    }
    
    private func setupSubViews() {
        nameTrackerTextField.placeholder = "Введите название трекера"
        nameTrackerTextField.backgroundColor = UIColor(hex: "#E6E8EB", alpha: 0.3)
        nameTrackerTextField.layer.cornerRadius = 16
        nameTrackerTextField.font = .systemFont(ofSize: 17, weight: .regular)
        nameTrackerTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        nameTrackerTextField.leftViewMode = .always
        nameTrackerTextField.textColor = UIColor(hex: "#1A1B22")
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.addTarget(self, action: #selector(nameTrackerTextFieldChanged), for: .editingChanged)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(UIColor(hex: "#F56B6C"), for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor(hex: "#F56B6C")?.cgColor
        cancelButton.layer.cornerRadius = 16
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            nameTrackerTextField,
            tableView,
            cancelButton,
            createButton
        ].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            nameTrackerTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor)
        ])
    }
    
    private func updateCreateButtonState() {
        let hasName = !(nameTrackerTextField.text ?? "").isEmpty
        let hasSchedule = !selectedSchedule.isEmpty
        
        createButton.isEnabled = hasName && hasSchedule
        createButton.backgroundColor = createButton.isEnabled
        ? UIColor(hex: "#1A1B22")
        : UIColor(hex: "#AEAFB4")
    }
    
    @objc private func nameTrackerTextFieldChanged() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let title = nameTrackerTextField.text, !title.isEmpty else { return }
        guard !selectedSchedule.isEmpty else { return }
        
        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: .systemBlue,
            emoji: "🙂",
            schedule: selectedSchedule
        )
        
        delegate?.didCreateTracker(tracker)
        dismiss(animated: true)
    }
}

extension NewTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        cell.textLabel?.text = rows[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = UIColor(hex: "#E6E8EB", alpha: 0.3)
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension NewTrackerViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 1 {
            let viewController = ScheduleViewController()
            viewController.delegate = self
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    
    func scheduleSelected(_ schedule: [Weekday]) {
        selectedSchedule = schedule
        updateCreateButtonState()
    }
}
