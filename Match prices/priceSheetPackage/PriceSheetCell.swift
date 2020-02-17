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
    
    // название в ячейке – сумма или названия продуктов / магазинов
    @IBOutlet weak var label: UILabel!
    // ячейки для ввода цифр
    @IBOutlet weak var textFieldCell: DictionaryTextField!
    

    // инициализация ячейки таблицы цен
    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldCell.isHidden = true
        label.isHidden = true
        // клавиатура из цифр
        textFieldCell.keyboardType = UIKeyboardType.decimalPad
        textFieldCell.delegate = self
        textFieldCell.attributedPlaceholder = NSAttributedString(string: "-",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    
}


/// текстовое поле для ячейки с расширением
/// для отслеживания номера ячейки
class DictionaryTextField: UITextField {
    var item: MiniCell?
}

/// параметры расположения
struct MiniCell {
    var row : Int
    var column : Int
}
