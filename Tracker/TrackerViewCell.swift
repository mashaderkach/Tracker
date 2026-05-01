//
//  TrackerViewCell.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 19.04.26.
//

import UIKit

protocol TrackerViewCellDelegate: AnyObject {
    func didTapButton(in cell: TrackerViewCell)
}

final class TrackerViewCell: UICollectionViewCell {
    weak var delegate: TrackerViewCellDelegate?
    
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let dayLabel = UILabel()
    private let addButton = UIButton()
    private let cellContainerView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        emojiLabel.textAlignment = .center
        emojiLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emojiLabel.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor(hex: "#FFFFFF")
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        dayLabel.textColor = UIColor(hex: "#1A1B22")
        dayLabel.font = .systemFont(ofSize: 12, weight: .medium)
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cellContainerView.layer.masksToBounds = true
        cellContainerView.layer.cornerRadius = 16
        cellContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.setImage(UIImage(resource: .addTracker), for: .normal)
        addButton.tintColor = UIColor(hex: "#FFFFFF")
        addButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 17
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        
        contentView.addSubview(cellContainerView)
        contentView.addSubview(dayLabel)
        
        cellContainerView.addSubview(emojiLabel)
        cellContainerView.addSubview(titleLabel)
        contentView.addSubview(addButton)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            
            cellContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cellContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cellContainerView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cellContainerView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cellContainerView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: cellContainerView.leadingAnchor, constant: 12),
            titleLabel.bottomAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: -12),
            titleLabel.trailingAnchor.constraint(equalTo: cellContainerView.trailingAnchor, constant: -12),
            
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dayLabel.topAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: 16),
            
            addButton.topAnchor.constraint(equalTo: cellContainerView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, count: Int) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        cellContainerView.backgroundColor = tracker.color.withAlphaComponent(0.7)
        dayLabel.text = "\(count) \(daysText(count))"
        let imageName = isCompleted ? "checkmark" : "plus"
        addButton.setImage(UIImage(systemName: imageName), for: .normal)
        addButton.backgroundColor = tracker.color
        addButton.alpha = isCompleted ? 0.3 : 1
        
    }
    
    @objc private func tapButton() {
        delegate?.didTapButton(in: self)
    }
    
    private func daysText(_ count: Int) -> String {
        
        let value = abs(count) % 100
        let lastDigit = value % 10
        if value >= 11 && value <= 14 {
            return "дней"
        }
        
        switch lastDigit {
        case 1:
            return "день"
        case 2...4:
            return "дня"
        default:
            return "дней"
        }
    }
}
