// TrackersViewController.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 3.04.26.

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private UI
    
    private let trackerLabel = UILabel()
    private var addTrackerButton = UIBarButtonItem()
    private let searchTextField = UISearchTextField()
    private let datePicker = UIDatePicker()
    private let textLabel = UILabel()
    private let stubImageView = UIImageView()
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    // MARK: - Private Properties
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    private let cellIdentifier = "cell"
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubViews()
        setupConstraints()
        
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        
        loadData()
        applyFilters()
        updateEmptyState()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupSubViews() {
        navigationController?.navigationBar.tintColor = UIColor(hex: "#1A1B22")
        
        addTrackerButton = UIBarButtonItem(image: UIImage(resource: .addTracker), style: .plain, target: self, action: #selector(addTrackerTapped))
        navigationItem.leftBarButtonItem = addTrackerButton
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.backgroundColor = UIColor(hex: "#F0F0F0")
        datePicker.tintColor = UIColor(hex: "#1A1B22")
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.overrideUserInterfaceStyle = .light
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        trackerLabel.text = "Трекеры"
        trackerLabel.font = .systemFont(ofSize: 34, weight: .bold)
        trackerLabel.textColor = UIColor(hex: "#1A1B22")
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        searchTextField.placeholder = "Поиск"
        searchTextField.text = ""
        searchTextField.backgroundColor = UIColor(hex: "#767680", alpha: 0.12)
        searchTextField.textColor = UIColor(hex: "#AEAFB4")
        searchTextField.font = .systemFont(ofSize: 17, weight: .regular)
        searchTextField.layer.cornerRadius = 10
        searchTextField.clipsToBounds = true
        searchTextField.leftViewMode = .always
        searchTextField.translatesAutoresizingMaskIntoConstraints = false
        searchTextField.addTarget(self, action: #selector(searchChanged), for: .editingChanged)
        
        stubImageView.image = UIImage(named: "stub")
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel.text = "Что будем отслеживать?"
        textLabel.font = .systemFont(ofSize: 12, weight: .medium)
        textLabel.textColor = UIColor(hex: "#1A1B22")
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(TrackerViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        [
            trackerLabel,
            searchTextField,
            stubImageView,
            textLabel,
            collectionView
        ].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerLabel.widthAnchor.constraint(equalToConstant: 254),
            trackerLabel.heightAnchor.constraint(equalToConstant: 41),
            
            searchTextField.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: trackerLabel.leadingAnchor),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            stubImageView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 220),
            stubImageView.centerXAnchor.constraint(equalTo: searchTextField.centerXAnchor),
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            
            textLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor, constant: 8),
            textLabel.centerXAnchor.constraint(equalTo: searchTextField.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 24),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    // MARK: - Data Loading
    
    private func loadData() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            completedTrackers = try trackerRecordStore.fetchRecords()
        } catch {
            print("Ошибка загрузки данных: \(error)")
        }
    }
    
    // MARK: - State
    
    private func applyFilters() {
        let weekday = Weekday.from(date: currentDate)
        let searchText = searchTextField.text?.lowercased() ?? ""
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesDay = tracker.schedule.contains(weekday)
                let matchesText = searchText.isEmpty || tracker.title.lowercased().contains(searchText)
                return matchesDay && matchesText
            }
            return trackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: trackers)
        }
    }
    
    // MARK: - Helpers
    
    private func isCompleted(_ id: UUID) -> Bool {
        completedTrackers.contains {
            $0.trackerId == id &&
            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
    }
    
    private func count(_ id: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == id }.count
    }
    
    private func updateEmptyState() {
        let isEmpty = visibleCategories.isEmpty
        collectionView.isHidden = isEmpty
        stubImageView.isHidden = !isEmpty
        textLabel.isHidden = !isEmpty
    }
    
    // MARK: - Private Methods
    
    private func addNewTracker(_ tracker: Tracker, categoryTitle: String) {
        do {
            try trackerCategoryStore.addTracker(tracker, toCategoryWithTitle: categoryTitle)
        } catch {
            print("Ошибка сохранения трекера: \(error)")
        }
    }
    
    // MARK: - Actions
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
        applyFilters()
        collectionView.reloadData()
        updateEmptyState()
    }
    
    @objc private func searchChanged() {
        applyFilters()
        collectionView.reloadData()
        updateEmptyState()
    }
    
    @objc private func addTrackerTapped() {
        let viewController = NewTrackerViewController()
        viewController.delegate = self
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellIdentifier,
            for: indexPath
        ) as? TrackerViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.configure(
            with: tracker,
            isCompleted: isCompleted(tracker.id),
            count: count(tracker.id)
        )
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,  minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
}

// MARK: - TrackerViewCellDelegate

extension TrackersViewController: TrackerViewCellDelegate {
    
    func didTapButton(in cell: TrackerViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let selectedDay = Calendar.current.startOfDay(for: currentDate)
        let today = Calendar.current.startOfDay(for: Date())
        
        guard selectedDay <= today else { return }
        let record = TrackerRecord(
            trackerId: tracker.id,
            date: currentDate
        )
        
        do {
            if isCompleted(tracker.id) {
                try trackerRecordStore.deleteRecord(record)
            } else {
                try trackerRecordStore.addRecord(record)
            }
        } catch {
            print("Ошибка обновления записи трекера: \(error)")
        }
    }
}

// MARK: - NewTrackerViewControllerDelegate

extension TrackersViewController: NewTrackerViewControllerDelegate {
    
    func didCreateTracker(_ tracker: Tracker, categoryTitle: String) {
        addNewTracker(tracker, categoryTitle: categoryTitle)
    }
}

// MARK: - TrackerCategoryStoreDelegate

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidUpdate(_ store: TrackerCategoryStore) {
        loadData()
        applyFilters()
        collectionView.reloadData()
        updateEmptyState()
    }
}

// MARK: - TrackerRecordStoreDelegate

extension TrackersViewController: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidUpdate(_ store: TrackerRecordStore) {
        loadData()
        applyFilters()
        collectionView.reloadData()
        updateEmptyState()
    }
}
