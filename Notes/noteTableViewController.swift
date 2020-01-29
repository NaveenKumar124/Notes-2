//
//  noteTableViewController.swift
//  Notes
//
//  Created by Naveen Kumar on 2020-01-27.
//  Copyright © 2020 Naveen Kumar. All rights reserved.
//

import UIKit
import CoreData

class noteTableViewController: UITableViewController {

    var notes = [Note]()
    
    @IBOutlet weak var searchbar: UISearchBar!
    var managedObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    var searchNotes = [String]()
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveNotes()
        
        // Styles
        self.tableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveNotes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteTableViewCell", for: indexPath) as! noteTableViewCell
//
//        if searching{
//            cell?.textLabel?.text = searchNotes[indexPath.row]
//        }
//        else{
//            cell?.textLabel?.text = notes[indexPath.row]
//        }
        
        let note: Note = notes[indexPath.row]
        cell.configureCell(note: note)
        cell.backgroundColor = UIColor.clear
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

        }
        
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "                    ") { (action, indexPath) in
            
            let note = self.notes[indexPath.row]
            context.delete(note)
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                self.notes = try context.fetch(Note.fetchRequest())
            }
                
            catch {
                print("Failed to delete note.")
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()

        }
        
        delete.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "trashIcon"))
        
        return [delete]

    }
    
    // MARK: NSCoding
    func retrieveNotes() {
        managedObjectContext?.perform {
            
            self.fetchNotesFromCoreData { (notes) in
                if let notes = notes {
                    self.notes = notes
                    self.tableView.reloadData()
                    
                }
                
            }
            
        }
        
    }
    
    func fetchNotesFromCoreData(completion: @escaping ([Note]?)->Void){
        managedObjectContext?.perform {
            var notes = [Note]()
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            
            do {
                notes = try  self.managedObjectContext!.fetch(request)
                completion(notes)
                
            }
            
            catch {
                print("Could not fetch notes from CoreData:\(error.localizedDescription)")
                
            }
            
        }
        
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                let noteDetailsViewController = segue.destination as! noteViewController
                let selectedNote: Note = notes[indexPath.row]
                
                noteDetailsViewController.indexPath = indexPath.row
                noteDetailsViewController.isExsisting = false
                noteDetailsViewController.note = selectedNote
                
            }
            
        }
            
        else if segue.identifier == "addItem" {
            print("User added a new note.")
            
        }

    }

}

extension noteTableViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
       // searchNotes = notes.filter({$0.prefix(searchText.count) == searchText})
        searching = true
        tableView.reloadData()
    }
}
