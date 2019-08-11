//
//  DatabaseService.swift
//  TodoApp
//
//  Created by Nguyen Le Trong Nhan on 8/10/19.
//  Copyright © 2019 Nguyen Le Trong Nhan. All rights reserved.
//

import Foundation
import Firebase

class DatabaseService {
    
    static func referenceDB() -> DatabaseReference {
        
        let ref = Database.database().reference()
        return ref
    }
    
    static func saveToDB(item: TodoItemModel) {
        DatabaseService.referenceDB()
            .child("TodoList")
            .child(item.id)
            .setValue(["todoname": item.name, "todostatus": item.status.rawValue])
    }
    
    static func deleteFromDB(item: TodoItemModel) {
        DatabaseService.referenceDB().child("TodoList").child(item.id).removeValue()
    }
    
    static func getAllTodo(completion: @escaping (([TodoItemViewModel]) -> Void)) {
        
        let query = DatabaseService.referenceDB().child("TodoList")
        query.observeSingleEvent(of: .value) { (snapshot) in
            var items: [TodoItemViewModel] = []
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                
                let todoname = child.childSnapshot(forPath: "todoname").value as! String
                let todostatus = child.childSnapshot(forPath: "todostatus").value as! Int
                items.append(TodoItemViewModel(model: TodoItemModel(id: child.key, name: todoname, status: TodoStatus(rawValue: todostatus)!)))
                
                completion(items)
            }
        }
    }
    
    static func updateItemToDB(item: TodoItemModel) {
        DatabaseService.referenceDB().child("TodoList").child(item.id).updateChildValues(["todostatus" : item.status.rawValue])
    }
}



