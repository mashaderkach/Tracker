//  TabBarController.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 5.04.26.

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        
        trackersViewController.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .trackerIcon), tag: 1)
        statisticsViewController.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(resource: .statisticIcon), tag: 1)
        
        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }
}
