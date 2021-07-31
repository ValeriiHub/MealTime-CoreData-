//
//  ViewController.swift
//  MealTime
//
//  Created by Ivan Akulov on 10/02/2020.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//


import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var contex: NSManagedObjectContext!
    var user: User!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // создаем объект meal и присваиваем его свойству date текущую дату
        let meal = Meal(context: contex)
        meal.date = Date()
        
        // создаем копию meals у user И добавляем туда meal
        let meals = user.meals?.mutableCopy() as? NSMutableOrderedSet
        meals?.add(meal)
        user.meals = meals
        
        do {
            try contex.save()
            tableView.reloadData()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let userName = "Max"
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", userName)
        
        do {
            let results = try contex.fetch(fetchRequest)
            if results.isEmpty {
                user = User(context: contex)
                user.name = userName
                try contex.save()
            } else {
                user = results.first
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My happy meal time"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user.meals?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let meal = user.meals?[indexPath.row] as? Meal,
              let mealDate = meal.date else { return cell }
        
        cell.textLabel!.text = dateFormatter.string(from: mealDate)
        return cell
    }
}

