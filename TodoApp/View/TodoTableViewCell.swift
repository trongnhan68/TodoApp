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
    
    @IBOutlet weak var statusLabel: UILabel!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectButton.setImage(UIImage(named: "icon_button_active"), for: .normal)
        selectButton.setImage(UIImage(named: "icon_button_done"), for: .selected)
    }
    
    func configureCell(viewModel: TodoItemViewModel) {
        
        selectButton.isSelected = viewModel.isChecked
        todoNameLabel.textColor = viewModel.textColor
        statusLabel.text = viewModel.status
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: viewModel.name)
        if viewModel.model.status == .done {
            
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            
        } else {
            todoNameLabel.text = viewModel.name
        }
        todoNameLabel.attributedText = attributeString
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
