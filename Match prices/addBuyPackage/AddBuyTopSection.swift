//
//  TableViewCellButton.swift
//  Match prices
//
//  Created by Евгений Конев on 08.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit

class AddBuyTopSection: UITableViewCell {
    
    
    //MARK:- кнопка "добавить покупку"
    @IBAction func Button1(_ sender: Any) {
        if !title.isHidden {
            title.isHidden = true
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyBottomButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyTextField"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyKeyboardFirst"), object: nil)
            //нижняя секция – магазины
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceList"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTitle"), object: nil)
            addBuyTopButtonOutlet.isEnabled = false
            
            if (placesList.count == 0) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableTextFieldPlaceBottom"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableTextFieldPlaceBottom"), object: nil)
            }
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addToBuyList"), object: nil)
        }
        
    }
    @IBOutlet weak var addBuyTopButtonOutlet: UIButton! //кнопка "добавить покупку" – внешний вид
    @IBOutlet weak var title: UILabel! //текст "Добавьте товары", пропадает при заполнении списка покупок
    
    // MARK:- инициализация
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        addBuyTopButtonOutlet.isEnabled = false
        
        //Назначение отслеживающих для вызова из другого класса
        NotificationCenter.default.addObserver(self, selector: #selector(enableButton), name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableButton), name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTitle), name: NSNotification.Name(rawValue: "showBuyTopTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTitle), name: NSNotification.Name(rawValue: "hideBuyTopTitle"), object: nil)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc private func enableButton(notification: NSNotification){
        addBuyTopButtonOutlet.isEnabled = true
    }
    
    @objc private func disableButton(){
        addBuyTopButtonOutlet.isEnabled = false
    }
    
    /// Показывает заголовок
    @objc private func hideTitle(){
        title.isHidden = true
    }
    
    /// Скрывает заголовок
    @objc private func showTitle(){
        title.isHidden = false
    }
    
}
