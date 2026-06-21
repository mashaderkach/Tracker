//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 13.06.26.
//

import UIKit

final class CategoryViewModel {
    
    // MARK: - Public Properties
    
    var onCategoriesChanged: (() -> Void)?
    
    // MARK: - Private Properties
    
    private let trackerCategoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?()
        }
    }
    
    private var selectedCategoryTitle: String?
    
    var hasSelectedCategory: Bool {
        selectedCategoryTitle != nil
    }
    
    var numberOfCategories: Int {
        categories.count
    }
    
    // MARK: - Initialization
    
    init(trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    // MARK: - Public Methods
    
    func setSelectedCategory(_ title: String?) {
        selectedCategoryTitle = title
    }
    
    func loadCategories() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
        } catch {
            print("Ошибка загрузки категорий: \(error)")
        }
    }
    
    func categoryTitle(at indexPath: IndexPath) -> String {
        categories[indexPath.row].title
    }
    
    func isSelectedCategory(at indexPath: IndexPath) -> Bool {
        categories[indexPath.row].title == selectedCategoryTitle
    }
    
    func selectCategory(at indexPath: IndexPath) {
        let title = categories[indexPath.row].title
        
        if selectedCategoryTitle == title {
            selectedCategoryTitle = nil
        } else {
            selectedCategoryTitle = title
        }
        
        onCategoriesChanged?()
    }
    
    func selectedCategory() -> String? {
        selectedCategoryTitle
    }
    
    func addCategory(title: String) {
        do {
            _ = try trackerCategoryStore.createCategoryIfNeeded(title: title)
            loadCategories()
        } catch {
            print("Ошибка создания категории: \(error)")
        }
    }
}
