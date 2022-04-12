//
//  ListViewController.swift
//  Offline Notes
//
//  Created by Vansh Bhatia on 4/11/22.
//

import UIKit
import CoreData


class ListViewController: UITableViewController, UISearchBarDelegate {

    
    
    var goingForward = true{
        didSet{
            print(goingForward)
            if(goingForward){
                print("reloading")
                loadData()
                tableView.reloadData()
            }
        }
    }
    
    var notesArray:[Note]=[]{
        didSet{
            filteredNotes = notesArray
        }
    }
    var filteredNotes:[Note] = []
    var note:Note?
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    var currentUser = "9000000000"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        loadData()
        self.tableView.keyboardDismissMode = .onDrag
        navigationController?.title = "Your Private Notes List"
        
    }

    // MARK: - Table view data source and delegate methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        var content = cell.defaultContentConfiguration()
        //print(notesArray[indexPath.row].title)
        content.text = filteredNotes[indexPath.row].title!
        cell.contentConfiguration = content
        

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            
            context.delete(notesArray[indexPath.row])
            notesArray.remove(at: indexPath.row)
            do{
                try context.save()
            }catch let error{
                print(error.localizedDescription)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            loadData()
            tableView.reloadData()
        }   
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        note = notesArray[indexPath.row]
        performSegue(withIdentifier: "tableToNote", sender: tableView)
    }
    
    // MARK: - viewWillAppear

    override func viewWillAppear(_ animated: Bool) {
       
        goingForward = true
        searchBar.text = ""
    }
    
    
    // MARK: - Loading data from CoreData
    
    func loadData(){
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        // filter based on the currentUser
        let predicate = NSPredicate(format: "uploadedUser == \(currentUser)")
        fetchReq.predicate = predicate
        do{
            let newArr = try context.fetch(fetchReq) as! [Note]
            print(newArr)
            notesArray=newArr.reversed()
        }catch let error{
            print(error.localizedDescription)
        }
        tableView.reloadData()
    }
    
    // MARK: - Method called when add button pressed
    @IBAction func addNewPressed(_ sender: UIBarButtonItem) {
        
        performSegue(withIdentifier: "tableToNote", sender: self)
    }
    
    
    // MARK: - Method to prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "tableToNote"){
            goingForward = false
            if let nvc = segue.destination as? NotesViewController{
                nvc.currentUser = currentUser
                if let _ = sender as? UITableView{
                   
                        nvc.img = UIImage(data: (note?.img)!)
                        nvc.descText = note?.info
                        nvc.noteTitle = note?.title
                        nvc.oldNote = note
                        
                    }
            }
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - SearchBar Delegate methods 
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredNotes = []
        if(searchText == ""){
            filteredNotes = notesArray
            
        }
        if let text = searchBar.text{
            for item in notesArray{
                if item.title!.lowercased().contains(text.lowercased()){
                    self.filteredNotes.append(item)
                }
            }
        }
        tableView.reloadData()
    }
    
}
