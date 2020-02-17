//
//  TableViewCellButton2.swift
//  Match prices
//
//  Created by Евгений Конев on 08.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit


/// класс секция с кнопкой и текстом для добавления ячейки
class AddBuyBottomSection: UITableViewCell, UITextFieldDelegate {

    // кнопка добавления покупки вниз списка (внешка)
    @IBOutlet weak var AddBuyBottomButtonOutlet: UIButton!
    
    // кнопка добавления покупки вниз списка (действие)
    @IBAction func AddBuyBottomButtonAction(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addBuyBottom"), object: nil)
        
//        addItemToBottom()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Инициализация
//        NotificationCenter.default.addObserver(self, selector: #selector(addNewItemOnTop), name: NSNotification.Name(rawValue: "addToBuyList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showBottomAddButton), name: NSNotification.Name(rawValue: "showBuyBottomButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideBottomAddButton), name: NSNotification.Name(rawValue: "hideBuyBottomButton"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: NSNotification.Name(rawValue: "showBuyKeyboardFirst"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableBuyBottomButton), name: NSNotification.Name(rawValue: "enableBuyBottomButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableBuyBottomButton), name: NSNotification.Name(rawValue: "disableBuyBottomButton"), object: nil)
        
        
        
        // назначение свойств текстовому полю
//        textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
//        textField.addTarget(self, action: #selector(textFieldShouldReturn), for: UIControl.Event.editingDidEndOnExit)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    /// Добавление нового элемента в начало списка покупок
//    @objc func addNewItemOnTop() {
//        // проверка, что введено не пустое значение, также удаляются пробелы в начале
//        // и конце строки
//        let item = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
//        if (!item.isEmpty) {
//            // Добавление элемента в начало списка покупок (данные)
//            testList.insert("\(item)", at: 0)
//            // Добавление элемента в начало списка покупок (внешка)
//            addRowToStart()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
//            AddBuyBottomButtonOutlet.isEnabled = false
//            textField.text = ""
//        }
//
//    }
    
    
    /// Назначение текстовому полю отслеживателя при вводе текста
    ///  Если в поле есть символы – кнопки добавления становятся активны
    /// - Parameter textField: текстовое поле
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text!.isEmpty) {
            AddBuyBottomButtonOutlet.isEnabled = false
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
        } else {
            AddBuyBottomButtonOutlet.isEnabled = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
        }
    }
    
    /// Добавление элемента в конец списка покупок
//    private func addItemToBottom() {
//        guard textField.text != nil else {
//            return
//        }
//
//        // проверка, что введенное значение не пустое
//        let item = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
//        if (!item.isEmpty) {
//            testList.append("\(item)")
//            addRowToEnd()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableTextFieldPlaceBottom"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
//            AddBuyBottomButtonOutlet.isEnabled = false
//            textField.text = ""
//        }
//    }
    
    
    /// Обработка нажатия кнопки "return"
    /// - Parameter textField: поле ввода названия продукта
//    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
//        if (text.isEmpty && testListCount() == 0) {
//            textField.isHidden = true
//            AddBuyBottomButtonOutlet.isHidden = true
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyTopTitle"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceList"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
//
//
//        }  else if text.isEmpty {
//            textField.text = ""
//        } else {
//            addItemToBottom()
//            //addRow()
//        }
//
//        return false
//    }
    
    @objc func enableBuyBottomButton() {
        AddBuyBottomButtonOutlet.isEnabled = true
    }
    
    @objc func disableBuyBottomButton() {
        AddBuyBottomButtonOutlet.isEnabled = false
    }
    
    
//    /// показать текстовое поле
//    @objc func showTextField() {
//        textField.isHidden = false
//    }
//
//    /// скрыть текстовое поле
//    @objc func hideTextField() {
//        textField.isHidden = true
//    }
    
    /// показать нижнюю кнопку добавления
    @objc func showBottomAddButton() {
        AddBuyBottomButtonOutlet.isHidden = false
    }
    
    
    /// скрыть нижнюю кнопку добавления
    @objc func hideBottomAddButton() {
        AddBuyBottomButtonOutlet.isHidden = true
    }
   
    /// показать клавиаутуру
    /// вызывается в первый раз, когда происходит самое первое заполнение списков
//    @objc func showKeyboard() {
//        textField.becomeFirstResponder()
//    }
    

}
