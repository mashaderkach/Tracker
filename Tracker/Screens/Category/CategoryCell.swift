//
//  CategoryCell.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 13.06.26.
//

import UIKit

final class CategoryCell: UITableViewCell {
    
    // MARK: - Constants
    
    static let identifier = "CategoryCell"
    
    // MARK: - Public Methods
    
    func configure(with title: String, isSelected: Bool) {
        textLabel?.text = title
        textLabel?.font = .systemFont(ofSize: 17)
        textLabel?.textColor = UIColor(hex: "#1A1B22")
        
        backgroundColor = UIColor(hex: "#E6E8EB", alpha: 0.3)
        
        accessoryType = isSelected ? .checkmark : .none
        tintColor = UIColor(hex: "#3772E7")
    }
}
