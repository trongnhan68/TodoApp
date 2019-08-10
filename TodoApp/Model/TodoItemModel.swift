//
//  TaskModel.swift
//  TodoApp
//
//  Created by Nguyen Le Trong Nhan on 8/8/19.
//  Copyright © 2019 Nguyen Le Trong Nhan. All rights reserved.
//

import Foundation
import RxDataSources

enum TodoStatus: Int {
    case active = 1
    case done = 2
    case all = 0
    
    var description: String {
        switch self {
        case .active:
            return "Active"
        case .done:
            return "Done"
        default:
            return ""
        }
    }
}

struct TodoItemModel {
    let id: String
    let name: String
    var status: TodoStatus
    
    init(id: String, name: String, status: TodoStatus) {
        self.id = id
        self.name = name
        self.status = status
    }
}

class TodoItemViewModel: Equatable, IdentifiableType {
    
    static func == (lhs: TodoItemViewModel, rhs: TodoItemViewModel) -> Bool {
        return lhs.model.id == rhs.model.id
            && lhs.model.name == rhs.model.name
            && lhs.model.status == rhs.model.status
            && lhs.isChecked == rhs.isChecked
    }
    
    var identity: String {
        return model.id
    }
    
    var model: TodoItemModel
    var name: String = ""
    var isChecked: Bool = false
    var textColor: UIColor = .black
    
    init(model: TodoItemModel) {
        self.model = model
        name = model.name
        if model.status == .active {
            isChecked = false
            textColor = .black
        } else {
            isChecked = true
            textColor = .gray
        }
    }
    
    func updateStatus() {
        if model.status == .active {
            isChecked = false
        } else {
            isChecked = true
        }
    }
}
