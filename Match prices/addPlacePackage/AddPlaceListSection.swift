import UIKit

var isAlertRemovePlaceOpen : Bool = false

class AddPlaceListSection: UITableViewCell, UITextFieldDelegate {
    
    
    @IBOutlet weak var title: PlaceListTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(hideList), name: NSNotification.Name(rawValue: "hidePlaceList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showList), name: NSNotification.Name(rawValue: "showPlaceList"), object: nil)
        
        title.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        title.addTarget(self, action: #selector(textFieldShouldReturn), for: UIControl.Event.editingDidEndOnExit)
        title.delegate = self
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        title.addGestureRecognizer(longPressGesture)
        
        
    }
    
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        if (!isAlertRemovePlaceOpen) {
            isAlertRemovePlaceOpen = true
            let optionMenu = UIAlertController(title: nil, message: "Выберите действие", preferredStyle: .actionSheet)
           
            let actionRemove = UIAlertAction(title: "Удалить", style: .default, handler: {action in
                placesList.remove(at: self.title.item!.row)
                removeColumn(at: self.title.item!.row)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
                if (placesListCount() == 0) {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                }
                isAlertRemovePlaceOpen = false
            })
            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: {action in
                isAlertRemovePlaceOpen = false
            })
            optionMenu.addAction(actionRemove)
            optionMenu.addAction(cancelAction)
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc private func hideList() {
        title.isHidden = true
    }
    
    @objc private func showList() {
        title.isHidden = false
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveRes(textField: textField)
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceBottomButton"), object: nil)
        } else {
            if (buyListCount() != 0) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceBottomButton"), object: nil)
            }
        }
    }
    
    
    
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.endEditing(true)
        
        return false
    }
    
    private func saveRes(textField : UITextField) {
        if let textField = textField as? PlaceListTextField  {
            let row = textField.item?.row
            let res = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if (!res.isEmpty && row != nil) {
                if (row == placesList.count-1) {
                    placesList[row!] = res
                    addColumnToEnd()
                } else if (row == 0) {
                    placesList[row!] = res
                    addColumnToStart()
                } else {
                    placesList[row!] = res
                }
                sumPrices()
                if (currentListTitle != nil) {
                    guard saveList(title: currentListTitle!) else {
                        return
                    }
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
                
                
            } else {
                
                if (placesList.count > 0) {
                    
                    if (placesList[0] == "") {
                        placesList.remove(at: 0)
                        if (placesListCount() == 0) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTitle"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
                            
                        }
                        else {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTitle"), object: nil)
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
                        }
                        sumPrices()
                        if (currentListTitle != nil) {
                            guard saveList(title: currentListTitle!) else {
                                return
                            }
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                    } else {
                        if (placesList[placesList.count-1] == "") {
                            placesList.remove(at: placesList.count-1)
                            //removeColumn(at: placesList.count-1)
                            if (placesListCount() == 0) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTitle"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
                                
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
                                placesList.remove(at: textField.item!.row)
                                removeColumn(at: textField.item!.row)
                                sumPrices()
                                if (currentListTitle != nil) {
                                    guard saveList(title: currentListTitle!) else {
                                        return
                                    }
                                }
                                //removeColumn(at: textField.item!.row)
                                if (placesListCount() == 0) {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTitle"), object: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
                                } else {
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceBottomButton"), object: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
                                }
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
                        }
                    }
                }
                
                
            }
        }
    }
    
}

class PlaceListTextField: UITextField {
    var item: PosTextField?
}

