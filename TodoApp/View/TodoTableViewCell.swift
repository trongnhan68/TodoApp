//
//  TaskTableViewCell.swift
//  TodoApp
//
//  Created by Nguyen Le Trong Nhan on 8/8/19.
//  Copyright © 2019 Nguyen Le Trong Nhan. All rights reserved.
//

import UIKit
import Reusable
import RxSwift
import RxCocoa

class TodoTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var todoNameLabel: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectButton.setImage(UIImage(named: "icon_button_active"), for: .normal)
        selectButton.setImage(UIImage(named: "icon_button_done"), for: .selected)
    }
    
    func configureCell(viewModel: TodoItemViewModel) {
        todoNameLabel.text = viewModel.name
        selectButton.isSelected = viewModel.isChecked
        todoNameLabel.textColor = viewModel.textColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
