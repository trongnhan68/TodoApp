//
//  TodoListViewModel.swift
//  TodoApp
//
//  Created by Nguyen Le Trong Nhan on 8/9/19.
//  Copyright © 2019 Nguyen Le Trong Nhan. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Firebase

class TodoListViewModel: NSObject, TodoListProtocol {
    
    private var todoList = BehaviorRelay<[TaskSectionType]>(value: [TaskSectionType(header: "", items: [])])
    var todoListFiltered = BehaviorRelay<[TaskSectionType]>(value: [TaskSectionType(header: "", items: [])])
    var reloadTableTrigger = PublishRelay<()>()
    var filterStatus = BehaviorRelay<TodoStatus>(value: .all)
    
    var toggleAll = BehaviorRelay<Bool>(value: false)
    var showAll = BehaviorRelay<Bool>(value: false)
    var showActive = BehaviorRelay<Bool>(value: false)
    var showDone = BehaviorRelay<Bool>(value: false)
    
    var viewDidLoadTrigger = PublishRelay<Void>()
    
    let disposeBag = DisposeBag()
    
    func addTodo(text: String) {
        let uuid = UUID().uuidString
        let newTodo = TodoItemModel(id: uuid, name: text, status: .active)
        var items = self.todoList.value[0].items
        items.append(TodoItemViewModel(model: newTodo))
        self.todoList.accept([TaskSectionType(header: "", items: items)])
        
        let filters = self.todoList.value[0].items.filter { $0.model.status == filterStatus.value || filterStatus.value == .all }
        
        self.todoListFiltered.accept([TaskSectionType(header: "", items: filters)])
        
        DatabaseService.saveToDB(item: newTodo)
    }
    
    func deleteTodo(todoItemModel: TodoItemModel) {
        let items = self.todoList.value[0].items.filter { $0.model.id != todoItemModel.id }
        self.todoList.accept([TaskSectionType(header: "", items: items)])
        
        let filters = self.todoList.value[0].items.filter { $0.model.status == filterStatus.value || filterStatus.value == .all }
        
        self.todoListFiltered.accept([TaskSectionType(header: "", items: filters)])
        
        DatabaseService.deleteFromDB(item: todoItemModel)
    }
    
    func didTapChangeStatusItem(_ item: TodoItemModel) {
        let newStatus: TodoStatus = (item.status == .active) ? .done : .active
        let viewModel = self.todoList.value[0].items.first(where: { $0.model.id == item.id })
        viewModel?.model.status = newStatus
        viewModel?.updateStatus()
        
        self.reloadTableTrigger.accept(())
        
        if let model = viewModel?.model {
            DatabaseService.updateItemToDB(item: model)
        }
    }
    
    func toggleAllButtonTrigged() {
        
        let itemsFilter = self.todoListFiltered.value[0].items.map { (item)  -> TodoItemViewModel in
            let newStatus: TodoStatus = ((item as TodoItemViewModel).model.status == .active) ? .done : .active
            let viewModel = TodoItemViewModel(model: TodoItemModel(id: item.model.id, name: item.model.name, status: newStatus))
            return viewModel
        }
        
        let items = self.todoList.value[0].items.map { (item)  -> TodoItemViewModel in
            if item.model.status == filterStatus.value || filterStatus.value == .all {
                let newStatus: TodoStatus = ((item as TodoItemViewModel).model.status == .active) ? .done : .active
                let viewModel = TodoItemViewModel(model: TodoItemModel(id: item.model.id, name: item.model.name, status: newStatus))
                return viewModel
            }
            return item
        }
        
        self.toggleAll.accept(!toggleAll.value)
        self.todoList.accept([TaskSectionType(header: "", items: items)])
        self.todoListFiltered.accept([TaskSectionType(header: "", items: itemsFilter)])
        let todoItems = itemsFilter.map { $0.model }
        DatabaseService.updateItemsToDB(items: todoItems)
    }
    
    func showAllButtonTrigged() {
        
        self.todoListFiltered.accept(self.todoList.value)
        self.filterStatus.accept(.all)
    }
    
    func showActiveButtonTrigged() {
        
        let items = self.todoList.value[0].items.filter { $0.model.status != .done }
        self.todoListFiltered.accept([TaskSectionType(header: "", items: items)])
        self.filterStatus.accept(.active)
    }
    
    func showDoneButtonTrigged() {
        
        let items = self.todoList.value[0].items.filter { $0.model.status != .active }
        self.todoListFiltered.accept([TaskSectionType(header: "", items: items)])
        
        self.filterStatus.accept(.done)
    }
    
    override init() {
        super.init()
        
        getListToto()
        configureObserable()
        configureStartupStatus()
    }
    
    func configureObserable() {
        
        filterStatus.asDriver()
            .drive(onNext: { [weak self] (status) in
                guard let self = self else { return  }
                switch status {
                case .all:
                    self.showAll.accept(true)
                    self.showActive.accept(false)
                    self.showDone.accept(false)
                case .active:
                    self.showAll.accept(false)
                    self.showActive.accept(true)
                    self.showDone.accept(false)
                case .done:
                    self.showAll.accept(false)
                    self.showActive.accept(false)
                    self.showDone.accept(true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func getListToto() {
        
        DatabaseService.getAllTodo { [weak self] (items) in
            guard let self = self else { return }
            self.todoList.accept([TaskSectionType(header: "", items: items)])
            self.todoListFiltered.accept([TaskSectionType(header: "", items: items)])
        }
    }
    
    func configureStartupStatus() {
        
        viewDidLoadTrigger
            .subscribe(onNext: { [weak self] (_) in
                self?.showAll.accept(true)
        })
        .disposed(by: disposeBag)
    }
}
