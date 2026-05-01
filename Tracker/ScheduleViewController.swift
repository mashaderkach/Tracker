//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 1.05.26.
//

import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleSelected(_ schedule: [Weekday])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let tableView = UITableView()
    private let doneButton = UIButton()
    
    private var selectedDays: [Weekday] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
    }
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Расписание"
        
        navigationItem.hidesBackButton = true
        navigationController?.navigationBar.tintColor = UIColor(hex: "#1A1B22")
    }
    
    private func setupSubViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        doneButton.backgroundColor = UIColor(hex: "#1A1B22")
        doneButton.layer.cornerRadius = 16
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        [
            tableView,
            doneButton
        ].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func doneButtonTapped() {
        delegate?.scheduleSelected(selectedDays)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = Weekday.allCases[sender.tag]
        
        if sender.isOn {
            selectedDays.append(day)
        } else {
            selectedDays.removeAll { $0 == day }
        }
    }
}

extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Weekday.allCases.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = UITableViewCell()
        let day = Weekday.allCases[indexPath.row]
        
        cell.textLabel?.text = day.title
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = UIColor(hex: "#E6E8EB", alpha: 0.3)
        cell.selectionStyle = .none
        
        let switchView = UISwitch()
        switchView.tag = indexPath.row
        switchView.onTintColor = UIColor(hex: "#3772E7")
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        
        cell.accessoryView = switchView
        
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 75
    }
}
