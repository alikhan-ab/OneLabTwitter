//
//  HistoryViewController.swift
//  OneLabTodo
//
//  Created by Alikhan Abutalipov on 1/10/21.
//

import SnapKit

class HistoryViewController: UIViewController {

    private var viewModel: HistoryViewModel!

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModel()
        layoutUI()
        bindViewModel()
    }

    private func createViewModel() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { fatalError("Couldn't get the app delegate")}
        viewModel = HistoryViewModel(container: appDelegate.persistentContainer)
    }

    private func layoutUI() {
        view.backgroundColor = .white
        title = "History"
        configureTableView()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CurrentTasksCell.self, forCellReuseIdentifier: String(describing: CurrentTasksCell.self))
        tableView.tableFooterView = UIView()
    }

    private func bindViewModel() {
        viewModel.didUpdateModel = { [weak self] in
            self?.tableView.reloadData()
        }
        viewModel.didDelete = { [weak self] indexPath in
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        viewModel.didUpdate = { [weak self] indexPath in
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    private func showEditAlert(task: Task) {
        let alert = UIAlertController(title: "Task", message: nil, preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.text = task.title
            textField.placeholder = "Task"
            textField.addTarget(self, action: #selector(self?.editTextFieldDidChange(field:)), for: .editingChanged)
        }
        alert.addTextField { [weak self] textField in
            textField.text = task.note
            textField.placeholder = "Note"
            textField.addTarget(self, action: #selector(self?.editTextFieldDidChange(field:)), for: .editingChanged)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            guard let selectedIndexPath = self.tableView.indexPathForSelectedRow else { return }
            self.tableView.deselectRow(at:selectedIndexPath, animated: true)
        }
        let editAction = UIAlertAction(title: "Edit", style: .default) { [weak self] action in
            let title = alert.textFields?[0].text ?? ""
            let note = alert.textFields?[1].text ?? ""
            self?.viewModel.edit(task: task, newTitle: title, newNote: note)
        }
        editAction.isEnabled = false
        alert.addAction(editAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    @objc private func editTextFieldDidChange(field: UITextField) {
        guard let alertController = presentedViewController as? UIAlertController else { return }
        guard let titleTextField = alertController.textFields?[0],
              let noteTextField = alertController.textFields?[1] else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let task = viewModel.getTask(at: indexPath)
        let editAction = alertController.actions[0]
        let didTitleChanged = !(titleTextField.text?.isEmpty ?? true) && task.title != titleTextField.text
        let didNoteChanged = task.note ?? "" != noteTextField.text ?? ""
        editAction.isEnabled = didTitleChanged || didNoteChanged
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfTasks
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: CurrentTasksCell.self)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CurrentTasksCell else { return UITableViewCell() }
        cell.configureCellWith(task: viewModel.getTask(at: indexPath), delegate: viewModel)
        return cell
    }    
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, _) in
            guard let self = self else { return }
            self.viewModel.delete(task: self.viewModel.getTask(at: indexPath))
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showEditAlert(task: viewModel.getTask(at: indexPath))
    }
}
