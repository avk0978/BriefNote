//
//  MainTableViewController.swift
//  Snote
//
//  Created by Andrey Kolpakov on 04.12.2017.
//  Copyright © 2017 Andrey Kolpakov. All rights reserved.
//

import UIKit
import CoreData

class MainTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var notesArray: [Notes] = []
    var fetchResultsController: NSFetchedResultsController<Notes>!
    var searchNotes: [Notes] = []
    var searchController: UISearchController!
    
    func filterContentFor(searchText text: String) {
        searchNotes = notesArray.filter { (notes) -> Bool in
            return (notes.name?.lowercased().contains(text.lowercased()))! }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Notes", comment: "Notes")
        navigationController?.navigationBar.prefersLargeTitles = true //Большой заголовок в Navigation Bar
        
        // Инициализируем поисковый контроллер (Search Controller)
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar

        // Загрузка данных в главную форму из CoreData
        //Создаем дескриптор запроса данных
        let fetchRequest: NSFetchRequest<Notes> = Notes.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        // Получаем контекст
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultsController.delegate = self //Подписались под NSFetchedResultsControllerDelegate и можем реализовывать методы Fetched Result
            
            do {
                try fetchResultsController.performFetch()
                notesArray = fetchResultsController.fetchedObjects!
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" { return searchNotes.count }
        else { return notesArray.count }
    }

    func notesToDisplayAt(_ indexPath: IndexPath) -> Notes {
        let note: Notes
        if searchController.isActive && searchController.searchBar.text != "" { note = searchNotes[indexPath.row] }
        else { note = notesArray[indexPath.row] }
        return note
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notesToDisplayAt(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NoteTableViewCell
        // Configure the cell...
        cell.accessoryType = note.block ? .checkmark : .none
        if let nameValue = note.name { cell.nameCell.text = nameValue }
        if let textValue = note.text { cell.textCell.text = textValue }
        // Вывод отформатированной даты
        if let date = note.date {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_Ru")
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            cell.dateCell.text = dateFormatter.string(from: date)
        }
        // Вывод картинки
        if let imageValue = note.image { cell.imageCell.image = UIImage(data: imageValue) }
        
        return cell
    }
  
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let note = notesToDisplayAt(indexPath)
        
        let blockUnblock = note.block ? NSLocalizedString("Unblock", comment: "Unblock") : NSLocalizedString("Block", comment: "Block")
        let block = UITableViewRowAction(style: .default, title: blockUnblock) { (action, indexPath) in
            note.block = !note.block
            self.searchController.isActive = false
            tableView.reloadData()
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                do {
                    try context.save()
                } catch let error as NSError {
                    let ac = UIAlertController(title: nil, message: "It was not succeeded \(blockUnblock) the note \(error), \(error.userInfo)", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
                    ac.addAction(cancel)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        }
        
        let delete = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "Delete"), handler: { (action, indexPath) in
            
            self.searchController.isActive = false
            tableView.reloadData()
            
            if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                if let index = self.fetchResultsController.indexPath(forObject: note) { //находим индекс объекта по БД
                    let objectToDelete = self.fetchResultsController.object(at: index)//удаляем по индексу из БД
                    context.delete(objectToDelete)}
                do {
                    try context.save()
                } catch let error as NSError {
                    let ac = UIAlertController(title: nil, message: "It was not succeeded to delete the data \(error), \(error.userInfo)", preferredStyle: .alert)
                    let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
                    ac.addAction(cancel)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        })
        
        let share = UITableViewRowAction(style: .default, title: NSLocalizedString("Send", comment: "Send"), handler: { (action, indexPath) in
            var mesage = ""
            var image: UIImage
            if let img = note.image {
                image = UIImage(data: img)!
            } else { image = UIImage(named: "Photo.png")! }
            if let name = note.name {
                let txt = NSLocalizedString("Note", comment: "Note")
                mesage = txt + ": " + name + "\n"
            } else if let text = note.text {
                mesage = text
                let activControler = UIActivityViewController(activityItems: [mesage, image], applicationActivities: nil)
                self.present(activControler, animated: true, completion: nil)
                return
            }
            if let text = note.text {
                mesage = mesage + text
            }
            
            self.searchController.isActive = false
            tableView.reloadData()
            
            let activControler = UIActivityViewController(activityItems: [mesage, image], applicationActivities: nil)
            self.present(activControler, animated: true, completion: nil)
        })
        
        block.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        share.backgroundColor = #colorLiteral(red: 0.1136773313, green: 0.870630706, blue: 0.1418963835, alpha: 1)
        delete.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        if note.block == true { return [block,share] }
        else { return [block,share,delete] }
    }

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert: guard let indexPath = newIndexPath else { break }
        tableView.insertRows(at: [indexPath], with: .fade)
        case .delete: guard let indexPath = indexPath else { break }
        tableView.deleteRows(at: [indexPath], with: .fade)
        case .update: guard let indexPath = indexPath else { break }
        tableView.reloadRows(at: [indexPath], with: .fade)
        default:
            tableView.reloadData()
        }
        notesArray = controller.fetchedObjects as! [Notes]
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue"  {
            if let indexPath = tableView.indexPathForSelectedRow {
                let detailViewControler = segue.destination as! DetailViewController
                detailViewControler.note = notesToDisplayAt(indexPath)
                detailViewControler.indexSegue = indexPath.row
                detailViewControler.delegate = self
            }
        }
    }


}

extension MainTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentFor(searchText: searchController.searchBar.text!)
        tableView.reloadData()
    }
}

extension MainTableViewController: SaveEditingDataToNotesListDelegate {
    func  saveNote(_ note: Notes, _ index: Int) {
        notesArray[index] = note
        searchController.isActive = false
        tableView.reloadData()
        
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                try context.save()
            } catch let error as NSError {
                let ac = UIAlertController(title: nil, message: "It was not succeeded to save the notice \(error), \(error.userInfo)", preferredStyle: .alert)
                let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .cancel, handler: nil)
                ac.addAction(cancel)
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
}


