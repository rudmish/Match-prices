//
//  SavedListsTableView.swift
//  Match prices
//
//  Created by Евгений Конев on 12.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit

class SavedListsTableView: UITableViewController {

    //Кнопка закрытия экрана
    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var delegate : PickNewList?
    
    //Основной метод
    override func viewDidLoad() {
        super.viewDidLoad()
        //устанавка "страницы" (списка) в режим редактирования
        tableView.setEditing(true, animated: true)
        //Получить массив сохраненных списков, если они есть
        if (getSavedLists() != nil) {
            titlesList = getSavedLists()!
            if (currentListTitle != nil) {
                let index = titlesList.firstIndex(of: currentListTitle!)
                if index != nil {
                    titlesList.remove(at: index!)
                }
                
            }
            
            //обновить представление таблицы
            self.tableView.reloadData()
        }
        //сделать допустимым нажатие на элементы в режиме редактирования
        self.tableView.allowsSelectionDuringEditing = true
    }

    // MARK: - Table view data source
    // Обработка нажатия на элемент
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.pickList(title: titlesList[indexPath.row])
    }
    
    // Кол-во секций
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // количество элементов в секции – размер массива сохраненных списков
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titlesList.count
    }

    // Отображение вида элемента списка
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedListsTableViewCell", for: indexPath)

        // назначение названия элементу списка из массива
        cell.textLabel?.text = titlesList[indexPath.row]

        return cell
    }
    

    
    // разрешить редактирование ячеек
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // удаление ячеек
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeListFromTitlesList(at: indexPath.row, title: titlesList[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    
    // поменять элементы в массиве местами
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let from = titlesList[fromIndexPath.row]
        titlesList.remove(at: fromIndexPath.row)
        titlesList.insert(from, at: to.row)
        updateSavedLists()
    }
    

    
    // разрешение на перемещение ячеек
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

}

/// протокол для вызова функции при возврате к осномному массиву
/// При выборе списка – подгрузка его на основном экране
protocol PickNewList {
    func pickList(title : String)
}

/// Расширение, добавляющее наследование протокола
extension ViewController : PickNewList {
    func pickList(title: String) {
        self.dismiss(animated: true, completion: {
            //Указывается, что нужно подгрузить для нового выбранного списка
            
            // установить текущее название списка
            currentListTitle = title

            setCurrentListTitle()
            
            
            // Очищаем массивы
            testList.removeAll()
            placesList.removeAll()
            pricesArray.removeAll()
            
            // задаем новые списки
            let list = getSavedList(title: title)
            testList = list?.testArray ?? [String]()
            placesList = list?.placesArray ?? [String]()
            pricesArray = list?.pricesArray ?? [[Double?]](repeating: [Double?](repeating: 0.0, count: placesList.count), count: testListCount())
            
            
            self.showHidePlaces()
            guard saveList(title: title) else {
                return
            }
            
            // обновить представление таблиц
            self.tableView.reloadData()
            collectionViewPrices?.reloadData()
            
            // установить название сверху экрана
            self.navigationItem.title = currentListTitle
            
            
        })
    }
}
