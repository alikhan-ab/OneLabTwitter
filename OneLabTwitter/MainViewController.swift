//
//  MainViewController.swift
//  OneLabTwitter
//
//  Created by Alikhan Abutalipov on 12/28/20.
//

import SnapKit

final class MainViewController: UIViewController {

    private var tweetTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    private func configureTableView() {
        view.addSubview(tweetTableView)
        tweetTableView.dataSource = self
        tweetTableView.delegate = self
        tweetTableView.register(TweetTableViewCell.self, forCellReuseIdentifier: String(describing: TweetTableViewCell.self))
        tweetTableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        tweetTableView.tableFooterView = UIView(frame: .zero)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: TweetTableViewCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? TweetTableViewCell else { return UITableViewCell() }
        cell.userNameLabel.text = "Alikhan Abutalipov"
        cell.userHandleLabel.text = "@alikhan.ab"
        cell.tweetTextLabel.text = "I turned back to the sun. It was going. The sun was going, and the world was wrong. The grasses were wrong; they were platinum. I turned back to the sun. It was going. The sun was going, and the world was wrong. The grasses were wrong;"
        return cell
    }
}
