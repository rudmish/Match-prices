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
    
    //обработка длительного нажатия на элемент списка
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        // Если меню не открыто
            if (!isAlertRemoveBuyOpen) {
                //открываем меню
                isAlertRemoveBuyOpen = true
                let optionMenu = UIAlertController(title: nil, message: "Выберите действие", preferredStyle: .actionSheet)
               
                // кнопки удаления и отмены
                let actionRemove = UIAlertAction(title: "Удалить", style: .default, handler: {action in
                    buyList.remove(at: self.title.item!.row)
                    removeRow(at: self.title.item!.row)
                    if (currentListTitle != nil) {
                        guard saveList(title: currentListTitle!) else {
                            return
                        }
                    }
                    if (buyList.count == 0) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTitle"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceBottomButton"), object: nil)
                        
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
                    
                    isAlertRemoveBuyOpen = false
                })
                let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: {action in
                    isAlertRemoveBuyOpen = false
                })
                optionMenu.addAction(actionRemove)
                optionMenu.addAction(cancelAction)
                
                // показать меню (не обыным present так как находимся в ячейке таблицы, а не  на главном экране
                
                if #available(iOS 13.0, *) {
                    let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                    keyWindow?.rootViewController?.present(optionMenu, animated: true, completion: nil)
                } else {
                    UIApplication.shared.keyWindow?.rootViewController?.present(optionMenu, animated: true, completion: nil)
                }
                
                
            }
        }
    
    
    // отслеживание изменения ввода текста в реальном времени
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyBottomButton"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTitle"), object: nil)
            
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceBottomButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyBottomButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTitle"), object: nil)
            
        }
    }
    
    
    // Проверка окончания ввода текста
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveRes(textField: textField)
        
    }
    
    //функция для отображения клавиатуры
    @objc func showBuyTopKeyboard() {
        title.becomeFirstResponder()
    }
    
    /// Обработка нажатия кнопки "return"
    /// - Parameter textField: поле ввода названия продукта
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return false
    }
}

private func saveRes(textField : UITextField) {
    if let textField = textField as? BuyListTextField  {
        let row = textField.item?.row // индекс элемента (текстового поля)
        let res = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!res.isEmpty && row != nil) {
            // Если введено не пустое значение
            // Если добавляем в конец
            if (row == buyList.count-1) {
                buyList[row!] = res
                addRowToEnd()
            } else if (row == 0) {
                buyList[row!] = res
                addRowToStart()
            } else {
                buyList[row!] = res
            }
            
            sumPrices()
            if (currentListTitle != nil) {
                guard saveList(title: currentListTitle!) else {
                    return
                }
            }
            print(sumArray, "simmArray")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
            if (isFirstStart) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "scheduledTimerWithTimeIntervalV2"), object: nil)
            }
            
        } else {
            
            //Если пустое – удаляем соотвествующий элемент списка
            if (buyList.count > 0) {
                if (buyList[0] == "") {
                    
                    buyList.remove(at: 0)
                    
                    //removeRow(at: 0)
                    if (buyListCount() == 0 && placesListCount() == 0) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                    }
                    if (placesListCount() != 0) {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
                        
                    }
                    sumPrices()
                    if (currentListTitle != nil) {
                        guard saveList(title: currentListTitle!) else {
                            return
                        }
                    }
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                } else {
                    if (buyList[buyList.count-1] == "") {
                        buyList.remove(at: buyList.count-1)
                        //removeRow(at: buyList.count-1)
                        if (buyListCount() == 0 && placesListCount() == 0) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                        }
                        if (placesListCount() != 0) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
                            
                        }
                        sumPrices()
                        if (currentListTitle != nil) {
                            guard saveList(title: currentListTitle!) else {
                                return
                            }
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                    } else
                        if (textField.text == "") {
                            buyList.remove(at: textField.item!.row)
                            removeRow(at: textField.item!.row)
                            if (buyListCount() == 0 && placesListCount() == 0) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                            }
                            if (placesListCount() != 0) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
                                
                            }
                            sumPrices()
                            if (currentListTitle != nil) {
                                guard saveList(title: currentListTitle!) else {
                                    return
                                }
                            }
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
                    }
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyBottomButton"), object: nil)
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

