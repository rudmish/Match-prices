//
//  TableViewCellMedium.swift
//  Match prices
//
//  Created by Евгений Конев on 08.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit

var isAlertRemoveBuyOpen : Bool = false

class AddBuyListSection: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var title: BuyListTextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title.placeholder = "Введите название товара"
        
        title.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showBuyTopKeyboard), name: NSNotification.Name(rawValue: "showBuyTopKeyboard"), object: nil)
        title.addTarget(self, action: #selector(textFieldShouldReturn), for: UIControl.Event.editingDidEndOnExit)
        title.delegate = self
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        title.addGestureRecognizer(longPressGesture)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
        
        
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
            if (!isAlertRemoveBuyOpen) {
                isAlertRemoveBuyOpen = true
                let optionMenu = UIAlertController(title: nil, message: "Выберите действие", preferredStyle: .actionSheet)
               
                let actionRemove = UIAlertAction(title: "Удалить", style: .default, handler: {action in
    //                if section == 2 {
    //                    testList.remove(at: index)
    //                    self.tableView.deleteRows(at: [indexPath], with: .fade)
    //                    removeRow(at: index)
    //                    self.showHideBuyTopTitle()
    //                    self.showHideBuyBottom()
    //                    //                self.showHidePlaces()
    //                    self.showHidePriceSheet()
    //                    self.reloadDataCollection()
    //                    //                self.showHidePlacesTitle()
    //                }
                    //Удаление из списка магазинов
    //                if section == 6 {
                    testList.remove(at: self.title.item!.row)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                    isAlertRemoveBuyOpen = false
                })
                let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: {action in
                    isAlertRemoveBuyOpen = false
                })
                optionMenu.addAction(actionRemove)
                optionMenu.addAction(cancelAction)
                let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
                keyWindow?.rootViewController?.present(optionMenu, animated: true, completion: nil)
            }
        }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyBottomButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTitle"), object: nil)
            
            
        } else {
            
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyBottomButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTitle"), object: nil)
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? BuyListTextField  {
            let row = textField.item?.row
            let res = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            if (!res.isEmpty && row != nil) {
                
                // Если добавляем в конец
                if (row == testList.count-1) {
                    testList[row!] = res
                    addRowToEnd()
                } else if (row == 0) {
                    testList[row!] = res
                    addRowToStart()
                } else {
                    testList[row!] = res
                }
                
                sumPrices()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
                if (isFirstStart) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scheduledTimerWithTimeIntervalV2"), object: nil)
                }
                
            } else {
                if (testList.count > 0) {
                    if (testList[0] == "") {
                        testList.remove(at: 0)
                        removeRow(at: 0)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                    } else {
                        if (testList[testList.count-1] == "") {
                            testList.remove(at: testList.count-1)
                            removeRow(at: testList.count-1)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                        } else
                            if (textField.text == "") {
                                testList.remove(at: textField.item!.row)
                                removeRow(at: textField.item!.row)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func showBuyTopKeyboard() {
        title.becomeFirstResponder()
    }
    
    /// Обработка нажатия кнопки "return"
    /// - Parameter textField: поле ввода названия продукта
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let textField = textField as? BuyListTextField  {
            let row = textField.item?.row
            let res = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            //let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if (!res.isEmpty && row != nil) {
                if (row == testList.count-1) {
                    testList[row!] = res
                    addRowToEnd()
                } else if (row == 0) {
                    testList[row!] = res
                    addRowToStart()
                }
                sumPrices()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
                textField.endEditing(true)
                
            } else {
                if (testListCount() == 0) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                textField.endEditing(true)
            }
        }
        
        return false
    }
}

/// текстовое поле для ячейки с расширением
/// для отслеживания номера ячейки
class BuyListTextField: UITextField {
    var item: PosTextField?
}

struct PosTextField {
    var row : Int
}

