//
//  PriceSheetCell.swift
//  Match prices
//
//  Created by Евгений Конев on 09.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit


// Класс – ячейка таблицы. Сюда выносится содержимое ячейки

class PriceSheetCell: UICollectionViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textFieldCell: DictionaryTextField!
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldCell.isHidden = true
        label.isHidden = true
        textFieldCell.keyboardType = UIKeyboardType.decimalPad
        textFieldCell.delegate = self
    }
    
    
}


class DictionaryTextField: UITextField {
    var item: MiniCell?
}

struct MiniCell {
    var row : Int
    var column : Int
}
