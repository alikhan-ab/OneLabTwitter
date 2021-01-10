//
//  TasksViewModel.swift
//  OneLabTodo
//
//  Created by Alikhan Abutalipov on 1/10/21.
//

import Foundation
import CoreData

final class TasksViewModel: NSObject  {

    var didUpdateModel: () -> Void = { }
    var undoTimerElapsed: () -> Void = { }
    var didGetError: () -> Void = { }
    var didInsert: (_ indexPath: IndexPath) -> Void = { _ in }
    var didDelete: (_ indexPath: IndexPath) -> Void = { _ in }
    var didUpdate: (_ indexPath: IndexPath) -> Void = { _ in }

    private var container: NSPersistentContainer!
    private var fetchedResultsController: NSFetchedResultsController<Task>!

//    private var deletedTask: TaskStruct?
    private var completeTaskDispatchWorkerItems = [Task: DispatchWorkItem]()
//    private var undoStack = 0
//    private var undoTaskDispatchWorkerItems = [DispatchWorkItem]()

    var numberOfTasks: Int {
        guard let section = fetchedResultsController.sections?[0] else { return 0}
        return section.numberOfObjects
    }

    init(container: NSPersistentContainer) {
        super.init()
        self.container = container
        loadSavedData()
    }
    
    func loadSavedData() {
        if fetchedResultsController == nil {
            let request = Task.createFetchRequest()
            let sort = NSSortDescriptor(key: "creationDate", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20

            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }

        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "isCompleted = %d", false)

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

    func save(title: String, note: String, isCompleted: Bool = false, completionDate: Date? = nil, creationDate: Date = Date()) {
        let task = Task(context: container.viewContext)
        task.title = title
        task.note = note.isEmpty ? nil : note
        task.isCompleted = isCompleted
        task.completionDate = completionDate
        task.creationDate = creationDate
        saveContext()
    }

    func undoLastDeletetion() {
        /*
        guard let task = deletedTask else { return }
        save(title: task.title,
             note: task.note ?? "",
             isCompleted: task.isCompleted,
             completionDate: task.completionDate,
             creationDate: task.creationDate)
        undoStack = 0
        deletedTask = nil
        */
    }

    func edit(task: Task, newTitle: String, newNote: String) {
        task.title = newTitle
        task.note = newNote.isEmpty ? nil : newNote
        saveContext()
    }

    func delete(task: Task) {
        /*
        deletedTask = TaskStruct(title: task.title,
                                 note: task.note,
                                 creationDate: task.creationDate,
                                 completionDate: task.completionDate,
                                 isCompleted: task.isCompleted)

        */
        task.managedObjectContext?.delete(task)
        saveContext()
        /*
        undoStack += 1

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.undoStack -= 1
            if self.undoStack == 0 {
                self.undoTimerElapsed()
                self.deletedTask = nil
            }
        }

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: workItem)
         */
    }

    func markCompleted(task: Task, completionDate: Date) {
        task.isCompleted = true
        task.completionDate = completionDate
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

    private func performAllCompleteTaskDispatchWorkerItems() {
        for (task, workItem) in completeTaskDispatchWorkerItems {
            workItem.cancel()
            markCompleted(task: task, completionDate: Date())
        }
    }

    deinit {
        performAllCompleteTaskDispatchWorkerItems()
    }
}

extension TasksViewModel: CurrentTasksCellDelegate {
    func buttonDidSelect(for task: Task) {
        let completionDate = Date()
        let workItem = DispatchWorkItem { [weak task, weak self] in
            guard let task = task, let self = self else { return }
            self.completeTaskDispatchWorkerItems.removeValue(forKey: task)
            self.markCompleted(task: task, completionDate: completionDate)
        }

        completeTaskDispatchWorkerItems.updateValue(workItem, forKey: task)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: workItem)
    }

    func buttonDidDeselect(for task: Task) {
        guard let workItem = completeTaskDispatchWorkerItems[task] else { return }
        workItem.cancel()
        completeTaskDispatchWorkerItems.removeValue(forKey: task)
    }
}

extension TasksViewModel: NSFetchedResultsControllerDelegate {
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
////        didUpdateModel()
//    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                didInsert(indexPath)
            }
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
