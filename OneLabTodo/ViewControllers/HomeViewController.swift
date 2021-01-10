//
//  ViewController.swift
//  OneLabTodo
//
//  Created by Alikhan Abutalipov on 1/7/21.
//

import SnapKit

class HomeViewController: UIViewController {

    private let tasksButton: UIButton = {
        let button = UIButton()
        button.setTitle("Tasks", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 40)
        return button
    }()

    private let historyButton: UIButton = {
        let button = UIButton()
        button.setTitle("History", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 30)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        configureUserIteration()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    private func layoutUI() {
        view.backgroundColor = .white
        title = "OneLabTodo"
        navigationController?.navigationBar.prefersLargeTitles = true
        configureButtonUI()
    }

    private func configureButtonUI() {
        view.addSubview(tasksButton)
        view.addSubview(historyButton)
        tasksButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.centerX.equalToSuperview()
        }
        historyButton.snp.makeConstraints {
            $0.top.equalTo(tasksButton.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
    }

    private func configureUserIteration() {
        tasksButton.addTarget(self, action: #selector(tasksButtonDidPress), for: .touchUpInside)
        historyButton.addTarget(self, action: #selector(historyButtonDidPress), for: .touchUpInside)
    }

    @objc private func tasksButtonDidPress() {
        let tasksViewController = TasksViewController()
        show(tasksViewController, sender: self)
    }

    @objc private func historyButtonDidPress() {
        let historyViewController = HistoryViewController()
        show(historyViewController, sender: self)
    }
}
