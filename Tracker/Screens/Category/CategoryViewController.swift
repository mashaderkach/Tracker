//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 13.06.26.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var onCategorySelected: ((String) -> Void)?
    var selectedCategoryTitle: String?
    
    // MARK: - Private UI
    
    private let tableView = UITableView()
    private let addButton = UIButton(type: .system)
    private let stubImageView = UIImageView()
    private let stubLabel = UILabel()
    
    // MARK: - Private Properties
    
    private let viewModel = CategoryViewModel()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        setupStub()
        setupAddButton()
        setupConstraints()
        bind()
        updateButtonTitle()
        
        viewModel.setSelectedCategory(selectedCategoryTitle)
        viewModel.loadCategories()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Категория"
        
        navigationItem.hidesBackButton = true
        
        navigationController?.navigationBar.tintColor = UIColor(hex: "#1A1B22")
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor(hex: "#1A1B22") ?? .black
        ]
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(
            CategoryCell.self,
            forCellReuseIdentifier: CategoryCell.identifier
        )
        
        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
    }
    
    private func setupStub() {
        stubImageView.image = UIImage(named: "stub")
        stubImageView.translatesAutoresizingMaskIntoConstraints = false
        
        stubLabel.text = "Привычки и события можно\nобъединить по смыслу"
        stubLabel.font = .systemFont(ofSize: 12, weight: .medium)
        stubLabel.textColor = UIColor(hex: "#1A1B22")
        stubLabel.textAlignment = .center
        stubLabel.numberOfLines = 2
        stubLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stubImageView)
        view.addSubview(stubLabel)
    }
    
    private func setupAddButton() {
        addButton.setTitle("Добавить категорию", for: .normal)
        addButton.setTitleColor(.white, for: .normal)
        addButton.backgroundColor = UIColor(hex: "#1A1B22")
        addButton.layer.cornerRadius = 16
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.addTarget(
            self,
            action: #selector(addButtonTapped),
            for: .touchUpInside
        )
        
        view.addSubview(addButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -24),
            
            stubImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stubImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            stubImageView.widthAnchor.constraint(equalToConstant: 80),
            stubImageView.heightAnchor.constraint(equalToConstant: 80),
            
            stubLabel.topAnchor.constraint(equalTo: stubImageView.bottomAnchor,constant: 8),
            stubLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Binding
    
    private func bind() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateState()
            self?.updateButtonTitle()
        }
    }
    
    // MARK: - State
    
    private func updateState() {
        let isEmpty = viewModel.numberOfCategories == 0
        
        tableView.isHidden = isEmpty
        
        stubImageView.isHidden = !isEmpty
        stubLabel.isHidden = !isEmpty
    }
    
    private func updateButtonTitle() {
        let title = viewModel.hasSelectedCategory
        ? "Готово"
        : "Добавить категорию"
        
        addButton.setTitle(title, for: .normal)
    }
    
    // MARK: - Actions
    
    @objc private func addButtonTapped() {
        
        if viewModel.hasSelectedCategory {
            if let selectedCategory = viewModel.selectedCategory() {
                onCategorySelected?(selectedCategory)
            }
            
            navigationController?.popViewController(animated: true)
            return
        }
        
        let viewController = NewCategoryViewController()
        
        viewController.onCategoryCreated = { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }
        
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
}

// MARK: - UITableViewDataSource

extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.identifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }
        
        cell.configure(
            with: viewModel.categoryTitle(at: indexPath),
            isSelected: viewModel.isSelectedCategory(at: indexPath)
        )
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
