//
//  CurrentTasksCell.swift
//  OneLabTodo
//
//  Created by Alikhan Abutalipov on 1/10/21.
//

import SnapKit

protocol CurrentTasksCellDelegate: class     {
    func buttonDidSelect(for task: Task)
    func buttonDidDeselect(for task: Task)
}

class CurrentTasksCell: UITableViewCell {

    private var task: Task?
    private var buttonDidSelectClosure: (() -> Void)?
    private weak var delegate: CurrentTasksCellDelegate?

    private let uncompletedTaskSymbol: UIImage? = {
        let bigConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "square", withConfiguration: bigConfiguration)
        return image
    }()

    private let completedTaskSymbol: UIImage? = {
        let bigConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: "checkmark.square", withConfiguration: bigConfiguration)
        return image
    }()

    private let completionButton = UIButton()
    private let completionImageView = UIImageView()

    private let notesImageView: UIImageView = {
        let image = UIImage(systemName: "note.text")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        let imageView = UIImageView(image: image)
        return imageView
    }()

    private let taskTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layoutUI()
        configureUserInteraction()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func layoutUI() {
        configureCompletionButton()
//        configureCompletionImageView()
        configureTaskTitleLable()
        configureNotesImageView()
    }

    private func configureCompletionButton() {
        contentView.addSubview(completionButton)
        completionButton.translatesAutoresizingMaskIntoConstraints = false
        completionButton.setImage(uncompletedTaskSymbol, for: .normal)
        completionButton.setImage(completedTaskSymbol, for: .selected)
        completionButton.isSelected = false
        completionButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        completionButton.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func configureCompletionImageView() {
        contentView.addSubview(completionImageView)
        completionImageView.translatesAutoresizingMaskIntoConstraints = false
        completionImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
        }
        completionImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func configureTaskTitleLable() {
        contentView.addSubview(taskTitleLabel)
        taskTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        taskTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
//            $0.leading.equalTo(completionImageView.snp.trailing).offset(5)
            $0.leading.equalTo(completionButton.snp.trailing).offset(5)
            $0.bottom.equalToSuperview().offset(-10)
        }
        taskTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    private func configureNotesImageView() {
        contentView.addSubview(notesImageView)
        notesImageView.translatesAutoresizingMaskIntoConstraints = false
        notesImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(taskTitleLabel.snp.trailing).offset(5)
//            $0.leading.equalTo(taskTitleLabel.snp.trailing).offset(5)
            $0.trailing.equalToSuperview().offset(-10)
        }
        completionImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    private func configureUserInteraction() {
        completionButton.addTarget(self, action: #selector(completionButtonDidPress), for: .touchUpInside)
    }

    func configureCellWith(task: Task, delegate: CurrentTasksCellDelegate, buttonDidSelectClosure: (() -> Void)? = nil) {
        self.task = task
        self.delegate = delegate
        self.buttonDidSelectClosure = buttonDidSelectClosure
        if task.isCompleted {
            completionImageView.image = completedTaskSymbol
        } else {
            completionImageView.image = uncompletedTaskSymbol
        }
        completionButton.isSelected = task.isCompleted
        notesImageView.isHidden = task.note == nil
        taskTitleLabel.text = task.title
    }

    @objc private func completionButtonDidPress() {
        if completionButton.isSelected {
            completionButton.isSelected = false
            guard let task = task else { return }
            delegate?.buttonDidDeselect(for: task)
        } else {
            completionButton.isSelected = true
            guard let task = task else { return }
            delegate?.buttonDidSelect(for: task)
        }
    }
}
