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

    @IBOutlet weak var priceSheetColl: UICollectionView!
    @IBOutlet weak var gridLayout: StickyGridCollectionViewLayout! {
        didSet {
            gridLayout.stickyRowsCount = 1
            gridLayout.stickyColumnsCount = 1
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        hidePriceSheet()
        NotificationCenter.default.addObserver(self, selector: #selector(showPriceSheet), name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hidePriceSheet), name: NSNotification.Name(rawValue: "hidePriceSheet"), object: nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func hidePriceSheet() {
        priceSheetColl.isHidden = true
    }
    
    @objc func showPriceSheet() {
        priceSheetColl.isHidden = false
    }

}


//extension PriceSheet {
//    func setCollectionViewDataSourceDelegate <D: UICollectionViewDelegate & UICollectionViewDataSource>
//        (_ dataSourceDelegate: D, forRow row: Int) {
//        priceSheetColl.delegate = dataSourceDelegate
//        priceSheetColl.dataSource = dataSourceDelegate
//        priceSheetColl.reloadData()
//    }
//}


// Устанавливает размеры ячеек таблицы
extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 50)
    }
    
}
