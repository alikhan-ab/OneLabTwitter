//
//  TableViewCell.swift
//  OneLabTwitter
//
//  Created by Alikhan Abutalipov on 12/24/20.
//

import SnapKit

class TweetTableViewCell: UITableViewCell {
    
    let userAvatarImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30
        imageView.backgroundColor = .black
        return imageView
    }()
    
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    let userHandleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    let tweetTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutUI() {
        
        configureUserAvatarImage()
        configureUserNameLabel()
        configueUserHandle()
        configureTweetText()
    }
    
    private func configureUserAvatarImage() {
        contentView.addSubview(userAvatarImage)
        userAvatarImage.translatesAutoresizingMaskIntoConstraints = false
        userAvatarImage.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalToSuperview().offset(13)
            $0.size.equalTo(60)
            
        }
    }
    
    private func configureUserNameLabel() {
        contentView.addSubview(userNameLabel)
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.snp.makeConstraints {
            $0.top.equalTo(userAvatarImage.snp.top)
            $0.leading.equalTo(userAvatarImage.snp.trailing).offset(8)
        }
        userNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    private func configueUserHandle() {
        contentView.addSubview(userHandleLabel)
        userHandleLabel.translatesAutoresizingMaskIntoConstraints = false
        userHandleLabel.snp.makeConstraints {
            $0.leading.equalTo(userNameLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview().offset(-10)
            $0.lastBaseline.equalTo(userNameLabel.snp.lastBaseline)
        }
        userHandleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    private func configureTweetText() {
        contentView.addSubview(tweetTextLabel)
        tweetTextLabel.translatesAutoresizingMaskIntoConstraints = false
        tweetTextLabel.snp.makeConstraints {
            $0.top.equalTo(userNameLabel.snp.bottom).offset(3)
            $0.leading.equalTo(userNameLabel.snp.leading)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
}
