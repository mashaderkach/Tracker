//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 13.06.26.
//

import UIKit

final class NewCategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var onCategoryCreated: ((String) -> Void)?
    
    // MARK: - Private UI
    
    private let textField = UITextField()
    private let doneButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviews()
        setupConstraints()
        updateButtonState()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        view.backgroundColor = .white
        title = "Новая категория"
        
        navigationItem.hidesBackButton = true
        
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor(hex: "#1A1B22") ?? .black
        ]
    }
    
    private func setupSubviews() {
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = UIColor(hex: "#E6E8EB", alpha: 0.3)
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.textColor = UIColor(hex: "#1A1B22")
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        doneButton.setTitle("Готово", for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.layer.cornerRadius = 16
        doneButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        
        view.addSubview(textField)
        view.addSubview(doneButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - State
    
    private func updateButtonState() {
        let hasText = !(textField.text ?? "").isEmpty
        doneButton.isEnabled = hasText
        doneButton.backgroundColor = hasText
        ? UIColor(hex: "#1A1B22")
        : UIColor(hex: "#AEAFB4")
    }
    
    // MARK: - Actions
    
    @objc private func textFieldChanged() {
        updateButtonState()
    }
    
    @objc private func doneButtonTapped() {
        guard let title = textField.text, !title.isEmpty else { return }
        onCategoryCreated?(title)
        navigationController?.popViewController(animated: true)
    }
}
