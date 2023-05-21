//
//  ViewController.swift
//  Do Me
//
//  Created by Balaji Srinivas on 12/04/23.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var doMeItems: Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let colorHex = selectedCategory?.color {
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigation Controller does not exist.")
            }
            searchBar.barTintColor = UIColor(hexString: colorHex)
            searchBar.tintColor = ContrastColorOf(UIColor(hexString: colorHex)!, returnFlat: true)

            title = selectedCategory!.name
            
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(hexString: colorHex)
            appearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(appearance.backgroundColor!, returnFlat: true)] 
            navBar.standardAppearance = appearance;
            navBar.scrollEdgeAppearance = navBar.standardAppearance
            navBar.tintColor = ContrastColorOf(UIColor(hexString: colorHex)!, returnFlat: true)
            
        

            
        }
    }
    
    //MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return doMeItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = doMeItems?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            if let color = UIColor(hexString: selectedCategory!.color)?.darken(byPercentage:CGFloat(indexPath.row) / CGFloat(doMeItems!.count)) {
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
                
            }
            
            
            
            cell.accessoryType = item.done ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = doMeItems?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                    
                }
            } catch {
                print("Error saving done status, \(error)")
            }
            
        }
        
        tableView.reloadData()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert  = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { action in
            
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        
        present(alert, animated: true)
    }
    
    //MARK: - Model Manupulation Methods
    
    
    
    func loadItems() {
        
        doMeItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated",ascending: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let itemForDeletion = self.doMeItems?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(itemForDeletion)
                }
            } catch {
                print("Error deleting the category, \(error)")
            }
            
        }
        
    }
}


//MARK: - UISearchBarDelegate

extension TodoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        doMeItems = doMeItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title",ascending: true)
        tableView.reloadData()
        
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

