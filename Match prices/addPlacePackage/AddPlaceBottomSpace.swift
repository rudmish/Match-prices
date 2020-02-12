import UIKit

class AddPlaceBottomSection: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var addPlaceBottomButtonOutlet: UIButton!
    @IBAction func AddPlaceBottomButton(_ sender: Any) {
        addItemToBottom()
    }
    @IBOutlet weak var textField: UITextField!
    
    
    //инициализация секции
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(addNewItemOnTop), name: NSNotification.Name(rawValue: "addToPlaceList"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showItems), name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideItems), name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enableTextField), name: NSNotification.Name(rawValue: "enableTextFieldPlaceBottom"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableTextField), name: NSNotification.Name(rawValue: "disableTextFieldPlaceBottom"), object: nil)
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        textField.addTarget(self, action: #selector(textFieldShouldReturn), for: UIControl.Event.editingDidEndOnExit)
        addPlaceBottomButtonOutlet.isEnabled = false
        if (testList.count == 0) {
            addPlaceBottomButtonOutlet.isHidden = true
            textField.isHidden = true
        } else {
            addPlaceBottomButtonOutlet.isHidden = false
            textField.isHidden = false
        }
        if (testList.count == 0) {
            textField.isEnabled = false
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @objc func addNewItemOnTop(notification: NSNotification){
        //load data here
        let item = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if (!item.isEmpty) {
            placesList.insert("\(item) \(placesList.count)", at: 0)
            addColumnToStart()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
            addPlaceBottomButtonOutlet.isEnabled = false
            textField.text = ""
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if (textField.text!.isEmpty) {
            addPlaceBottomButtonOutlet.isEnabled = false
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
        } else {
            addPlaceBottomButtonOutlet.isEnabled = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
        }
    }
    
    /// Обработка нажатия кнопки "return"
    /// - Parameter textField: поле ввода названия продукта
    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (text.isEmpty && placesList.count == 0) {
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
            textField.isEnabled = false
            addPlaceBottomButtonOutlet.isEnabled = false
        } else if text.isEmpty {
            textField.text = ""
        } else {
            addItemToBottom()
        }
        
        return false
    }
    
    //MARK:- add to bottom
    private func addItemToBottom() {
        guard textField.text != nil else {
            return
        }
        
        let item = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if (!item.isEmpty) {
            placesList.append("\(item) \(placesList.count)")
            addColumnToEnd()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateLists"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableTextFieldPlaceBottom"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
            
            addPlaceBottomButtonOutlet.isEnabled = false
            textField.text = ""
        }
    }
    
    
    @objc private func hideItems() {
        addPlaceBottomButtonOutlet.isHidden = true
        textField.isHidden = true
    }
    
    @objc private func showItems() {
        addPlaceBottomButtonOutlet.isHidden = false
        textField.isHidden = false
    }
    
    @objc private func enableTextField() {
        textField.isEnabled = true
    }
    
    @objc private func disableTextField() {
        textField.isEnabled = false
    }
    
    
}
