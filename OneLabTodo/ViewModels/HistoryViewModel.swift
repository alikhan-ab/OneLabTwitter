//
//  HistoryViewModel.swift
//  OneLabTodo
//
//  Created by Alikhan Abutalipov on 1/10/21.
//

import Foundation
import CoreData

final class HistoryViewModel: NSObject  {

    var didUpdateModel: () -> Void = { }
    var didDeleteTimerFired: () -> Void = { }
    var didGetError: () -> Void = { }
    var didDelete: (_ indexPath: IndexPath) -> Void = { _ in }
    var didUpdate: (_ indexPath: IndexPath) -> Void = { _ in }

    var container: NSPersistentContainer!
    var fetchedResultsController: NSFetchedResultsController<Task>!

    private var uncompleteTaskDispatchWorkerItems = [Task: DispatchWorkItem]()

    var numberOfTasks: Int {
        guard let section = fetchedResultsController.sections?[0] else { return 0}
        return section.numberOfObjects
    }

    init(container: NSPersistentContainer) {
        super.init()
        self.container = container
        loadSavedData()
    }

    private func createContainer() {
        container = NSPersistentContainer(name: "OneLabTodo")
        container.loadPersistentStores { (storeDescriptor, error) in
            if let error = error {
                // TODO: - Add error binidng
                print("Unresolved error \(error)")
            }
        }
    }

    func loadSavedData() {
        if fetchedResultsController == nil {
            let request = Task.createFetchRequest()
            let sort = NSSortDescriptor(key: "completionDate", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20

            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }

        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "isCompleted = %d", true)

        do {
            try fetchedResultsController.performFetch()
            didUpdateModel()
        } catch {
            didGetError()
        }
    }

    func getTask(at indexPath: IndexPath) -> Task {
        return fetchedResultsController.object(at: indexPath)
    }

    func edit(task: Task, newTitle: String, newNote: String) {
        task.title = newTitle
        task.note = newNote.isEmpty ? nil : newNote
        saveContext()
    }

    func delete(task: Task) {
        task.managedObjectContext?.delete(task)
        saveContext()
    }

    func markUncompleted(task: Task, completionDate: Date) {
        task.isCompleted = false
        task.completionDate = nil
        saveContext()
    }

    private func saveContext() {
        if container.viewContext.hasChanges {
            do {
                try container.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }

    private func performAllUncompleteTaskDispatchWorkerItems() {
        for (task, workItem) in uncompleteTaskDispatchWorkerItems {
            workItem.cancel()
            markUncompleted(task: task, completionDate: Date())
        }
    }

    deinit {
        performAllUncompleteTaskDispatchWorkerItems()
    }
}

extension HistoryViewModel: CurrentTasksCellDelegate {
    func buttonDidSelect(for task: Task) {
        guard let workItem = uncompleteTaskDispatchWorkerItems[task] else { return }
        workItem.cancel()
        uncompleteTaskDispatchWorkerItems.removeValue(forKey: task)
    }

    func buttonDidDeselect(for task: Task) {
        let completionDate = Date()
        let workItem = DispatchWorkItem { [weak task, weak self] in
            guard let task = task, let self = self else { return }
            self.uncompleteTaskDispatchWorkerItems.removeValue(forKey: task)
            self.markUncompleted(task: task, completionDate: completionDate)
        }
        uncompleteTaskDispatchWorkerItems.updateValue(workItem, forKey: task)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: workItem)
    }
}

extension HistoryViewModel: NSFetchedResultsControllerDelegate {

//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////        didUpdateModel()
//    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let indexPath = indexPath {
                didDelete(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                didUpdate(indexPath)
            }
        default:
            break
        }
    }
}
