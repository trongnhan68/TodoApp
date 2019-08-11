//
//  TodoListProtocol.swift
//  TodoApp
//
//  Created by Nguyen Le Trong Nhan on 8/9/19.
//  Copyright © 2019 Nguyen Le Trong Nhan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol TodoListProtocol {
    
    func addTodo(text: String)
    func deleteTodo(todoItemModel: TodoItemModel)
    func didTapChangeStatusItem(_ item: TodoItemModel)
    
    func toggleAllButtonTrigged()
    func showAllButtonTrigged()
    func showActiveButtonTrigged()
    func showDoneButtonTrigged()
    
    var reloadTableTrigger: PublishRelay<()> { get }
    var todoListFiltered: BehaviorRelay<[TaskSectionType]> { get }
    
    var filterStatus: BehaviorRelay<TodoStatus> { get }
    
    var toggleAll: BehaviorRelay<Bool> { get }
    var showAll: BehaviorRelay<Bool> { get }
    var showActive: BehaviorRelay<Bool> { get }
    var showDone: BehaviorRelay<Bool> { get }
    
    var viewDidLoadTrigger: PublishRelay<Void> { get }
}
