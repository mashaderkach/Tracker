//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 28.04.26.
//

import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String)
}

final class NewTrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    
    weak var delegate: NewTrackerViewControllerDelegate?
    
    // MARK: - Private UI
    
    private let nameTrackerTextField = UITextField()
    private let tableView = UITableView()
    private let titleLabel = UILabel()
    private let cancelButton = UIButton()
    private let createButton = UIButton()
    private let emojiLabel = UILabel()
    private let colorLabel = UILabel()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let emojiCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    private let colorCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    // MARK: - Private Properties
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var selectedCategory: String?
    
    private var selectedSchedule: [Weekday] = []
    private let rows = ["Категория", "Расписание"]
    private let collectionCellIdentifier = "CollectionCell"
    
    private let emojis = MockData.emojis
    private let colors = MockData.colors
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupCollections()
        setupConstraints()
        updateCreateButtonState()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Новая привычка"
        navigationController?.navigationBar.tintColor = UIColor(hex: "#1A1B22")
    }
    
    private func setupSubViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        emojiLabel.text = "Emoji"
        emojiLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emojiLabel.textColor = UIColor(hex: "#1A1B22")
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        colorLabel.text = "Цвет"
        colorLabel.font = .systemFont(ofSize: 19, weight: .bold)
        colorLabel.textColor = UIColor(hex: "#1A1B22")
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            nameTrackerTextField,
            tableView,
            cancelButton,
            createButton,
            emojiLabel,
            emojiCollectionView,
            colorLabel,
            colorCollectionView
        ].forEach { contentView.addSubview($0) }
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            nameTrackerTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 24),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 204),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 19),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 204)
        ])
    }
    
    private func setupCollections() {
        [emojiCollectionView, colorCollectionView].forEach {
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = .white
            $0.isScrollEnabled = false
            $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: collectionCellIdentifier)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    // MARK: - State
    
    private func updateCreateButtonState() {
        let hasName = !(nameTrackerTextField.text ?? "").isEmpty
        let hasSchedule = !selectedSchedule.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil
        let hasCategory = selectedCategory != nil
        
        createButton.isEnabled = hasName && hasCategory && hasSchedule && hasEmoji && hasColor
        createButton.backgroundColor = createButton.isEnabled
        ? UIColor(hex: "#1A1B22")
        : UIColor(hex: "#AEAFB4")
    }
    
    // MARK: - Actions
    
    @objc private func nameTrackerTextFieldChanged() {
        updateCreateButtonState()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let title = nameTrackerTextField.text, !title.isEmpty else { return }
        guard !selectedSchedule.isEmpty else { return }
        guard let selectedColor else { return }
        guard let selectedEmoji else { return }
        guard let selectedCategory else { return }
        
        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )
        
        delegate?.didCreateTracker(tracker, categoryTitle: selectedCategory)
        dismiss(animated: true)
    }
    
    // MARK: - Private Methods
    
    private func selectedScheduleText() -> String? {
        if selectedSchedule.isEmpty {
            return nil
        }
        
        if selectedSchedule.count == Weekday.allCases.count {
            return "Каждый день"
        }
        return selectedSchedule
            .sorted { $0.rawValue < $1.rawValue }
            .map { $0.shortTitle }
            .joined(separator: ", ")
    }
}

// MARK: - UITableViewDataSource

extension NewTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = rows[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 17)
        cell.backgroundColor = UIColor(hex: "#E6E8EB", alpha: 0.3)
        cell.accessoryType = .disclosureIndicator
        
        cell.detailTextLabel?.font = .systemFont(ofSize: 17)
        cell.detailTextLabel?.textColor = UIColor(hex: "#AEAFB4")
        
        if indexPath.row == 0 {
            cell.detailTextLabel?.text = selectedCategory
        }
        
        if indexPath.row == 1 {
            cell.detailTextLabel?.text = selectedScheduleText()
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension NewTrackerViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            let viewController = CategoryViewController()
            viewController.selectedCategoryTitle = selectedCategory
            
            viewController.onCategorySelected = { [weak self] title in
                self?.selectedCategory = title
                self?.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                self?.updateCreateButtonState()
            }
            navigationController?.pushViewController(viewController, animated: true)
        }
        
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

// MARK: - UICollectionViewDataSource

extension NewTrackerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int {
        collectionView == emojiCollectionView ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: collectionCellIdentifier,
            for: indexPath
        )
        
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.layer.cornerRadius = 16
        cell.contentView.layer.borderWidth = 0
        cell.contentView.layer.borderColor = nil
        cell.contentView.backgroundColor = .clear
        
        if collectionView == emojiCollectionView {
            configureEmojiCell(cell, at: indexPath)
        } else {
            configureColorCell(cell, at: indexPath)
        }
        return cell
    }
    
    private func configureEmojiCell(_ cell: UICollectionViewCell, at indexPath: IndexPath) {
        
        let emoji = emojis[indexPath.item]
        let label = UILabel()
        label.text = emoji
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])
        
        if selectedEmoji == emoji {
            cell.contentView.backgroundColor = UIColor(hex: "#E6E8EB")
        }
    }
    
    private func configureColorCell( _ cell: UICollectionViewCell, at indexPath: IndexPath) {
        
        let color = colors[indexPath.item]
        let colorView = UIView()
        colorView.backgroundColor = color
        colorView.layer.cornerRadius = 8
        colorView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
            
        ])
        
        if selectedColor == color {
            cell.contentView.layer.borderWidth = 3
            cell.contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == emojiCollectionView {
            selectedEmoji = emojis[indexPath.item]
            emojiCollectionView.reloadData()
        } else {
            selectedColor = colors[indexPath.item]
            colorCollectionView.reloadData()
        }
        updateCreateButtonState()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
}

// MARK: - ScheduleViewControllerDelegate

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    
    func scheduleSelected(_ schedule: [Weekday]) {
        selectedSchedule = schedule
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        updateCreateButtonState()
    }
}
