//
//  TableViewCellButton.swift
//  Match prices
//
//  Created by Евгений Конев on 08.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit


/// Класс секция с кнопкой добавления покупку в начало списка
class AddBuyTopSection: UITableViewCell {
    
    
    // MARK:- кнопка "добавить покупку"
    @IBAction func Button1(_ sender: Any) {
        // первый раз, когда в списке покупок нет элементов
        if !title.isHidden {
            title.isHidden = true
            //добавить элемент в список
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addBuyTop"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTitle"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceList"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTitle"), object: nil)
            addBuyTopButtonOutlet.isEnabled = false
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addBuyTop"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
        }
    }
    @IBOutlet weak var addBuyTopButtonOutlet: UIButton! //кнопка "добавить покупку" – внешний вид
    @IBOutlet weak var title: UILabel! //текст "Добавьте товары", пропадает при заполнении списка покупок
    
    // MARK:- инициализация
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //Назначение отслеживающих для вызова из другого класса
        NotificationCenter.default.addObserver(self, selector: #selector(enableButton), name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableButton), name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showTitle), name: NSNotification.Name(rawValue: "showBuyTopTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTitle), name: NSNotification.Name(rawValue: "hideBuyTopTitle"), object: nil)
        
        
    }
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// разрешить нажатие на кнопку
    @objc private func enableButton(notification: NSNotification){
        addBuyTopButtonOutlet.isEnabled = true
    }
    
    /// запретить нажатие на кнопку
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
