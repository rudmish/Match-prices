//
//  AddPlaceTitleSection.swift
//  Match prices
//
//  Created by Евгений Конев on 09.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit

class AddPlaceTitleSection: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if (currentListTitle == nil) {
            hideTitle()
        }
        title.isEnabled = false
        
//        if (buyListCount() != 0) {
//            enableTitle()
//        } else {
//            hideTitle()
//            disableTitle()
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(showTitle), name: NSNotification.Name(rawValue: "showPlaceTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideTitle), name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enableTitle), name: NSNotification.Name(rawValue: "enablePlaceTitle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disableTitle), name: NSNotification.Name(rawValue: "disablePlaceTitle"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @objc private func showTitle() {
        title.isHidden = false
    }
    
    @objc private func hideTitle() {
        title.isHidden = true
    }
    
    @objc private func enableTitle() {
        title.isEnabled = true
    }
    
    @objc private func disableTitle() {
        title.isEnabled = false
    }
}
