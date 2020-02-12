//
//  TableViewCellButton2.swift
//  Match prices
//
//  Created by Евгений Конев on 08.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit

class AddBuyBottomSection: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var AddBuyBottomButtonOutlet: UIButton!
    @IBAction func Button2(_ sender: Any) {
        
        addItemToBottom()
        
    }
    @IBOutlet weak var textField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(addNewItemOnTop), name: NSNotification.Name(rawValue: "addToBuyList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showBottomAddButton), name: NSNotification.Name(rawValue: "showBuyBottomButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideBottomAddButton), name: NSNotification.Name(rawValue: "hideBuyBottomButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTextField), name: NSNotification.Name(rawValue: "showBuyTextField"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTextField), name: NSNotification.Name(rawValue: "hideBuyTextField"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: NSNotification.Name(rawValue: "showBuyKeyboardFirst"), object: nil)
        
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        textField.addTarget(self, action: #selector(textFieldShouldReturn), for: UIControl.Event.editingDidEndOnExit)
        AddBuyBottomButtonOutlet.isEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @objc func addNewItemOnTop(notification: NSNotification){
        //load data here
        let item = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if (!item.isEmpty) {
            testList.insert("\(item) \(testList.count)", at: 0)
            addRowToStart()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
            AddBuyBottomButtonOutlet.isEnabled = false
            textField.text = ""
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text!.isEmpty) {
            AddBuyBottomButtonOutlet.isEnabled = false
             NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
        } else {
            AddBuyBottomButtonOutlet.isEnabled = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
        }
    }
    
    private func addItemToBottom() {
        guard textField.text != nil else {
            return
        }
        
        let item = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if (!item.isEmpty) {
            testList.append("\(item) \(testList.count)")
            addRowToEnd()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableTextFieldPlaceBottom"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
            AddBuyBottomButtonOutlet.isEnabled = false
            textField.text = ""
        }
    }
    
    
    /// Обработка нажатия кнопки "return"
    /// - Parameter textField: поле ввода названия продукта
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if (text.isEmpty && testList.count == 0) {
            textField.isHidden = true
            AddBuyBottomButtonOutlet.isHidden = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyTopTitle"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceList"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
            
            
        }  else if text.isEmpty {
            textField.text = ""
        } else {
            addItemToBottom()
            //addRow()
        }
        
        return false
    }
    
    @objc func showTextField() {
        textField.isHidden = false
    }
    
    @objc func hideTextField() {
        textField.isHidden = true
    }
    
    @objc func showBottomAddButton() {
        AddBuyBottomButtonOutlet.isHidden = false
    }
    
    @objc func hideBottomAddButton() {
        AddBuyBottomButtonOutlet.isHidden = true
    }
   
    @objc func showKeyboard() {
        textField.becomeFirstResponder()
    }
    

}
