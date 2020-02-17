import UIKit

class AddPlaceBottomSection: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var addPlaceBottomButtonOutlet: UIButton!
    @IBAction func addPlaceBottomButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPlaceBottom"), object: nil)
    }
//    @IBOutlet weak var textField: UITextField!
    
    
    //инициализация секции
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if (buyList.count == 0) {
            addPlaceBottomButtonOutlet.isHidden = true
        } else {
            addPlaceBottomButtonOutlet.isHidden = false
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showItems), name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideItems), name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)

        
        NotificationCenter.default.addObserver(self, selector: #selector(enablePlaceBottomButton), name: NSNotification.Name(rawValue: "enablePlaceBottomButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disablePlaceBottomButton), name: NSNotification.Name(rawValue: "disablePlaceBottomButton"), object: nil)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @objc private func enablePlaceBottomButton() {
        addPlaceBottomButtonOutlet.isEnabled = true
    }
    
    @objc private func disablePlaceBottomButton() {
        addPlaceBottomButtonOutlet.isEnabled = false
    }
    
    
    @objc private func hideItems() {
        addPlaceBottomButtonOutlet.isHidden = true
    }
    
    @objc private func showItems() {
        addPlaceBottomButtonOutlet.isHidden = false
    }
    
    
}
