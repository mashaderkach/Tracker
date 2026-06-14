//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Maryia Dziarkach on 13.06.26.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Private UI
    
    private let pageControl = UIPageControl()
    private let startButton = UIButton(type: .system)
    
    // MARK: - Private Properties
    
    private var pages: [UIViewController] = [
        OnboardingPageViewController(
            imageName: "onboarding1",
            titleText: "Отслеживайте только то, что хотите"
        ),
        OnboardingPageViewController(
            imageName: "onboarding2",
            titleText: "Даже если это не литры воды и йога"
        )
    ]
    
    // MARK: - Initialization
    
    override init(
        transitionStyle style: UIPageViewController.TransitionStyle,
        navigationOrientation: UIPageViewController.NavigationOrientation,
        options: [UIPageViewController.OptionsKey : Any]? = nil
    ) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: options
        )
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageViewController()
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupPageViewController() {
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers(
                [first],
                direction: .forward,
                animated: true
            )
        }
    }
    
    private func setupSubviews() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = UIColor(hex: "#1A1B22")
        pageControl.pageIndicatorTintColor = UIColor(hex: "#1A1B22", alpha: 0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        
        startButton.setTitle("Вот это технологии!", for: .normal)
        startButton.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        startButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        startButton.backgroundColor = UIColor(hex: "#1A1B22")
        startButton.layer.cornerRadius = 16
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
        
        [
            pageControl,
            startButton
        ].forEach { view.addSubview($0) }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: startButton.topAnchor, constant: -24),
            
            startButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func startButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard let window = view.window else { return }
        
        window.rootViewController = TabBarController()
        window.makeKeyAndVisible()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = index - 1
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = index + 1
        guard nextIndex < pages.count else { return nil }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentViewController = pageViewController.viewControllers?.first,
              let currentIndex = pages.firstIndex(of: currentViewController)
        else { return }
        
        pageControl.currentPage = currentIndex
    }
}
