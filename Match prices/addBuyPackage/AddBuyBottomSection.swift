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
        NotificationCenter.default.addObserver(self, selector: #selector(showBottomAddButton), name: NSNotification.Name(rawValue: "showBuyBottomButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideBottomAddButton), name: NSNotification.Name(rawValue: "hideBuyBottomButton"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableBuyBottomButton), name: NSNotification.Name(rawValue: "enableBuyBottomButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableBuyBottomButton), name: NSNotification.Name(rawValue: "disableBuyBottomButton"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
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
    
    @objc func enableBuyBottomButton() {
        AddBuyBottomButtonOutlet.isEnabled = true
    }
    
    @objc func disableBuyBottomButton() {
        AddBuyBottomButtonOutlet.isEnabled = false
    }
    
    /// показать нижнюю кнопку добавления
    @objc func showBottomAddButton() {
        AddBuyBottomButtonOutlet.isHidden = false
    }
    
    
    /// скрыть нижнюю кнопку добавления
    @objc func hideBottomAddButton() {
        AddBuyBottomButtonOutlet.isHidden = true
    }

}
