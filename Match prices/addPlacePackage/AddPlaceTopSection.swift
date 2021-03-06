//
//  AddPlaceTopSection.swift
//  Match prices
//
//  Created by Евгений Конев on 09.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//


import UIKit

class AddPlaceTopSection: UITableViewCell {
    
    
    
    @IBOutlet weak var addPlaceTopButtonOutlet: UIButton!
    @IBAction func AddPlaceToTop(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addPlaceTop"), object: nil)
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "addToPlaceList"), object: nil)
    }
    @IBOutlet weak var title: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        title.isHidden = true
        if (buyList.count == 0) {
            addPlaceTopButtonOutlet.isEnabled = false
        } else {
            addPlaceTopButtonOutlet.isEnabled = true
        }
        if (buyList.count == 0 && placesList.count == 0) {
            addPlaceTopButtonOutlet.isHidden = true
        } else {
            addPlaceTopButtonOutlet.isHidden = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(enableButton), name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableButton), name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideAddButton), name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAddButton), name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc private func enableButton(notification: NSNotification){
        //load data here
        addPlaceTopButtonOutlet.isEnabled = true
    }
    
    @objc private func disableButton(notification: NSNotification){
        //load data here
        addPlaceTopButtonOutlet.isEnabled = false
    }
    
    @objc private func showAddButton(notification: NSNotification){
        //load data here
        addPlaceTopButtonOutlet.isHidden = false
    }
    
    @objc private func hideAddButton(notification: NSNotification){
        //load data here
        addPlaceTopButtonOutlet.isHidden = true
    }
}
