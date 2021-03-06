//
//  PriceSheet.swift
//  Match prices
//
//  Created by Евгений Конев on 09.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit


// Класс для таблицы (секция с таблицей)
class PriceSheet: UITableViewCell {

    @IBOutlet weak var imageArrow: UIImageView!
    

    override func prepareForReuse() {
      NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil)
    }
    
    @IBOutlet weak var priceSheetColl: UICollectionView!
    @IBOutlet weak var gridLayout: StickyGridCollectionViewLayout! {
        didSet {
            gridLayout.stickyRowsCount = 1
            gridLayout.stickyColumnsCount = 1
        }
    }
    
    
    
    // инициализация секции с таблицей
    override func awakeFromNib() {
        super.awakeFromNib()
        imageArrow.isHidden = true
        // Инициализация методов
        NotificationCenter.default.addObserver(self, selector: #selector(showPriceSheet), name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidePriceSheet), name: NSNotification.Name(rawValue: "hidePriceSheet"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showArrow), name: NSNotification.Name(rawValue: "showArrow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideArrow), name: NSNotification.Name(rawValue: "hideArrow"), object: nil)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// скрыть показать таблицу
    @objc func hidePriceSheet() {
        priceSheetColl.isHidden = true
    }
    
    @objc func showPriceSheet() {
        priceSheetColl.isHidden = false
    }
    
    @objc func showArrow() {
        UIView.transition(with: imageArrow, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageArrow.isHidden = false
        })
    }
    
    @objc func hideArrow() {
        UIView.transition(with: imageArrow, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.imageArrow.isHidden = true
        })
    }

}

// Устанавливает размеры ячеек таблицы
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: priceSheetCellWidth, height: priceSheetCellHeight)
    }
    
}
