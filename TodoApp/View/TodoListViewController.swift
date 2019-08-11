//
//  ViewController.swift
//  TodoApp
//
//  Created by Nguyen Le Trong Nhan on 8/8/19.
//  Copyright © 2019 Nguyen Le Trong Nhan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Reusable
import SVProgressHUD

struct TaskSectionType {
    var header: String
    var items: [Item]
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
}

extension TaskSectionType: AnimatableSectionModelType {
    
    var identity: String {
        return header
    }
    
    init(original: TaskSectionType, items: [Item]) {
        self = original
        self.items = items
    }
    
    typealias Item = TodoItemViewModel

}

class TodoListViewController: UIViewController, NibOwnerLoadable {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var actionView: UIView!
    
    @IBOutlet weak var toggleAllButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var showAllButton: UIButton!
    
    @IBOutlet weak var activeButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    typealias RxDatasource = RxTableViewSectionedAnimatedDataSource<TaskSectionType>
    
    @IBOutlet weak var emptyView: UIView!
    
    @IBOutlet weak var emptyButton: UIButton!
    
    lazy var datasource = self.makeDatasource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defer {
            viewModel.viewDidLoadTrigger.accept(())
        }
        configureView()
        configureActions()
    }
    
    let disposeBag = DisposeBag()
    
    lazy var viewModel = TodoListViewModel()
    
    func configureView() {

        navigationController?.navigationBar.isHidden = false
        let nav = self.navigationController?.navigationBar
        
        nav?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        nav?.shadowImage = UIImage()
        nav?.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        emptyView.isHidden = true
        
        toggleAllButton.styleForButton()
        showAllButton.styleForButton()
        activeButton.styleForButton()
        doneButton.styleForButton()
        
        emptyButton.styleForButton()
        emptyButton.isSelected = true
        
        toggleAllButton.titleLabel?.adjustsFontSizeToFitWidth = true
        configureTableView()
        configureTextField()
    }
    
    func configureActions() {
        
        toggleAllButton
            .rx
            .tap
            .subscribe(onNext: { [unowned viewModel] (_) in
                viewModel.toggleAllButtonTrigged()
            })
            .disposed(by: disposeBag)
        
        showAllButton
            .rx
            .tap
            .subscribe(onNext: { [unowned viewModel] (_) in
                viewModel.showAllButtonTrigged()
            })
            .disposed(by: disposeBag)
        
        activeButton
            .rx
            .tap
            .subscribe(onNext: { [unowned viewModel] (_) in
                viewModel.showActiveButtonTrigged()
            })
            .disposed(by: disposeBag)
        doneButton
            .rx
            .tap
            .subscribe(onNext: { [unowned viewModel] (_) in
                viewModel.showDoneButtonTrigged()
            })
            .disposed(by: disposeBag)
        
        emptyButton
            .rx
            .tap
            .subscribe(onNext: { [unowned self] (_) in
                self.textField.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        emptyView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyViewDidTap)))
        tableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(emptyViewDidTap)))
        
    }
    
    func configureTextField() {
        textField.delegate = self
    }
    
    func configureTableView() {
        
        tableView.allowsSelection = true
        tableView.register(cellType: TodoTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.sectionHeaderHeight = 0
        tableView.separatorStyle = .none
        
        tableView
            .rx
            .itemSelected
            .asDriver()
            .drive(onNext: { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        datasource.canEditRowAtIndexPath = { dataSource, indexPath in
            return true
        }
        
        viewModel
            .todoListFiltered
            .skip(1)
            .do(onNext: { [weak self] (sections) in
                if sections[0].items.count > 0 {
                    self?.emptyView.isHidden = true
                } else {
                    self?.emptyView.isHidden = false
                }
            })
            .bind(to: tableView.rx.items(dataSource: datasource))
            .disposed(by: disposeBag)
        
        viewModel
            .reloadTableTrigger
            .subscribe (onNext: { [weak self] (_) in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .toggleAll
            .skip(1)
            .subscribe(onNext: { [weak self] (isToggleAll) in
                guard let self = self else { return }
                self.toggleAllButton.rx.isSelected.onNext(isToggleAll)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .showAll
            .skip(1)
            .subscribe(onNext: { [weak self] (isSelected) in
                guard let self = self else { return }
                self.showAllButton.rx.isSelected.onNext(isSelected)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .showActive
            .skip(1)
            .subscribe(onNext: { [weak self] (isSelected) in
                guard let self = self else { return }
                self.activeButton.rx.isSelected.onNext(isSelected)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .showDone
            .skip(1)
            .subscribe(onNext: { [weak self] (isSelected) in
                guard let self = self else { return }
                self.doneButton.rx.isSelected.onNext(isSelected)
            })
            .disposed(by: disposeBag)

    }
    
    
    func makeDatasource() -> RxDatasource {
    
            let animationConfiguration = AnimationConfiguration(insertAnimation: .automatic,
                                                                reloadAnimation: .automatic,
                                                                deleteAnimation: .automatic)
            return RxDatasource(animationConfiguration: animationConfiguration, configureCell: { (_, tableView, indexPath, viewModel) -> UITableViewCell in
                let cell: TodoTableViewCell = tableView.dequeueReusableCell(for: indexPath, cellType: TodoTableViewCell.self)
                cell.configureCell(viewModel: viewModel)
                
                cell.selectButton
                    .rx
                    .tap
                    .subscribe(onNext: { [weak self] (_) in
                        self?.viewModel.didTapChangeStatusItem(viewModel.model)
                    })
                    .disposed(by: cell.disposeBag)
                
                cell.deleteButton
                    .rx
                    .tap
                    .subscribe(onNext: { [weak self] (_) in
                        self?.viewModel.deleteTodo(todoItemModel: viewModel.model)
                    })
                    .disposed(by: cell.disposeBag)
                
                return cell
            }, titleForHeaderInSection: { datasource, index in
                return datasource.sectionModels[index].header
            }
        )
    }
    
    @objc
    func emptyViewDidTap() {
        textField.resignFirstResponder()
    }
}

extension TodoListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (action, indexPath) in
            self?.deleteTask(index: indexPath.row)
        }
        
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [.init(style: .destructive, title: "Delete", handler: { [weak self] _, _, success in
            success(true)
            self?.deleteTask(index: indexPath.row)
        })])
    }

    func deleteTask(index: Int) {
        let itemModel = datasource.sectionModels[0].items[index].model
        viewModel.deleteTodo(todoItemModel: itemModel)
    }
}

extension TodoListViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
  
        textField.resignFirstResponder()
        if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            viewModel.addTodo(text: text)
        }
        textField.text = ""
        return true
    }
}
