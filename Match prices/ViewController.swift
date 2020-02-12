//
//  MainTableViewController.swift
//  Match prices
//
//  Created by Евгений Конев on 08.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit

var isFIrstSectionVisible = false

//секция – области главной таблицы

// таблица цен, получаем при инициализации секций
var gridLayout : StickyGridCollectionViewLayout? = nil
// коллекция ячеек – основа таблицы цен, получаем при инициализации секций
var collectionViewPrices : UICollectionView? = nil



/// Главный класс
class ViewController: UITableViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate {
    
    var cell = UITableViewCell() //ячейка главной таблицы
    
    
    //MARK:- Основной метод инициализации
    /// Основной метод – инициализация. Здесь указывается все, что должно создаться или прикрепиться при открытии этого "экрана"
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStartTestData() 
        //Методы, для доступа к текущим данным из дургих классов. Например, обновить списки
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "updateLists"), object: nil) //обновить списки
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataCollection), name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil) //обновить таблицу цен
        
        self.setupToHideKeyboardOnTapOnView() // установка слушателя: при нажатии вне текстового поля – скрыть клавиатуру
        self.navigationItem.title = currentListTitle // установка названия текущего списка
        // подгрузка начальных тестовых данных
        
        if (currentListTitle != nil) {
            self.navigationItem.title = currentListTitle
        } else {
            self.navigationItem.title = "Новый список"
        }
        
        let navBarSavedListsButton = UIBarButtonItem.init(image: UIImage(systemName: "bookmark.fill"), style: .done, target: self, action: #selector(navBarSavedListsButtonAction))
        let navBarOptionsButton = UIBarButtonItem.init(image: UIImage(systemName: "doc.fill"), style: .done, target: self, action: #selector(navBarOptionsButtonAction))
        self.navigationItem.rightBarButtonItems = [navBarSavedListsButton, navBarOptionsButton]
        tableView.setEditing(true, animated: false)
        tableView.allowsSelectionDuringEditing = true
    }
    
    @objc func navBarSavedListsButtonAction() {
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SavedListsTableView") as! SavedListsTableView
        VC1.delegate = self
        let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.present(navController, animated:true, completion: nil)
    }
    
    @objc func navBarOptionsButtonAction() {
        let optionMenu = UIAlertController(title: nil, message: "Выберите действие", preferredStyle: .actionSheet)
        
        if (currentListTitle == nil) {
            let saveListAction = UIAlertAction(title: "Сохранить список", style: .default, handler: {action in
                
                let alertSaveList = UIAlertController(title: "Сохранить список", message: nil, preferredStyle: .alert)
                alertSaveList.addTextField { (textField) in
                    textField.placeholder = "Название списка..."
                }
                
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
                    let title = alertSaveList.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !title!.isEmpty else {
                        let alertShowError = UIAlertController(title: "Ошибка", message: "Название не должно быть пустым", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default)
                        alertShowError.addAction(okAction)
                        self.present(alertShowError, animated: true, completion: nil)
                        return
                    }
                    
                    guard checkIfSavedListTitleEmpty(title: title!) else {
                        let alertShowError = UIAlertController(title: "Ошибка", message: "Список с таким названием уже существует", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default)
                        alertShowError.addAction(okAction)
                        self.present(alertShowError, animated: true, completion: nil)
                        return
                    }
                    
                    
                    currentListTitle = title
                    setCurrentListTitle()
                    setSavedLists(title: currentListTitle!)
                    
                    if !saveList(title: currentListTitle!) {
                        let alertShowError = UIAlertController(title: "Ошибка", message: "Список с таким названием уже существует", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default)
                        alertShowError.addAction(okAction)
                        self.present(alertShowError, animated: true, completion: nil)
                    } else {
                        self.navigationItem.title = currentListTitle
                    }
                })
                alertSaveList.addAction(okAction)
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
                
                alertSaveList.addAction(cancelAction)
                self.present(alertSaveList, animated: true, completion: nil)
                
                
            })
            
            optionMenu.addAction(saveListAction)
        }
        
        //MARK: - Новый список
        let createNewListAction = UIAlertAction(title: "Создать новый список", style: .default, handler: {(action) in
            currentListTitle = nil
            setCurrentListTitle()
            testList.removeAll()
            placesList.removeAll()
            pricesArray.removeAll()
            self.showHidePlaces()
            self.tableView.reloadData()
            collectionViewPrices?.reloadData()
            self.navigationItem.title = "Новый список"
            
            
            
        })
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        if (currentListTitle != nil && currentListTitle != "") {
            let editTitleAction = UIAlertAction(title: "Изменить название списка", style: .default, handler: {action in
                self.changeTitle()
            })
            optionMenu.addAction(editTitleAction)
        }
        optionMenu.addAction(createNewListAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    // MARK:- Инициализация главной таблицы (главного экрана)
    // обновление списков при изменении данных
    @objc func loadList(){
        self.tableView.reloadData()
    }
    
    // число секций в главной таблице
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 9
    }
    
    private func changeTitle() {
        let alertSaveList = UIAlertController(title: "Изменить название списка", message: nil, preferredStyle: .alert)
        alertSaveList.addTextField { (textField) in
            textField.placeholder = "Новое название списка..."
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let title = alertSaveList.textFields![0].text?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title!.isEmpty else {
                let alertShowError = UIAlertController(title: "Ошибка", message: "Название не должно быть пустым", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alertShowError.addAction(okAction)
                self.present(alertShowError, animated: true, completion: nil)
                return
            }
            
            guard checkIfSavedListTitleEmpty(title: title!) else {
                let alertShowError = UIAlertController(title: "Ошибка", message: "Список с таким названием уже существует", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alertShowError.addAction(okAction)
                self.present(alertShowError, animated: true, completion: nil)
                return
            }
            
            if (changeTitleList(oldTitle: currentListTitle!, newTitle: title!)) {
                self.navigationItem.title = currentListTitle
            } else {
                let alertShowError = UIAlertController(title: "Ошибка", message: nil, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default)
                alertShowError.addAction(okAction)
                self.present(alertShowError, animated: true, completion: nil)
            }
            
            guard saveList(title: currentListTitle!) else {
                return
            }
        })
        alertSaveList.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertSaveList.addAction(cancelAction)
        self.present(alertSaveList, animated: true, completion: nil)
    }
    
    //MARK:- Редактирование списоков
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 {
            return true // список покупок (товаров)
        }
        if indexPath.section == 6 {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        if indexPath.section == 2 && tableView.isEditing {
//            return .delete
//        }
//        if indexPath.section == 6 {
//            return .delete
//        }
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
        if (fromIndexPath.section == 2) {
            //поменять строки в списке покупок местами
            let from = testList[fromIndexPath.row]
            testList.remove(at: fromIndexPath.row)
            testList.insert(from, at: to.row)
            
            //поменять строки цен местами
            let fromPrice = pricesArray[fromIndexPath.row]
            pricesArray.remove(at: fromIndexPath.row)
            pricesArray.insert(fromPrice, at: to.row)
            
            sumPrices()
            if (currentListTitle != nil) {
                guard saveList(title: currentListTitle!) else {
                    return
                }
            }
            collectionViewPrices?.reloadData()
        }
        if (fromIndexPath.section == 6) {
            
            //меняем местами строки
            let from = placesList[fromIndexPath.row]
            placesList.remove(at: fromIndexPath.row)
            placesList.insert(from, at: to.row)
            
            
            //меняем местами столбцы суммы
            for i in 0..<placesList.count {
                let first = pricesArray[i][fromIndexPath.row] //0:0
                pricesArray[i].remove(at: fromIndexPath.row)
                pricesArray[i].insert(first, at: to.row)
            }
            
            sumPrices()
            if (currentListTitle != nil) {
                guard saveList(title: currentListTitle!) else {
                    return
                }
            }
            collectionViewPrices?.reloadData()
        }
        
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
            return sourceIndexPath
        } else {
            return proposedDestinationIndexPath
        }
    }
    
    
    // число ячеек в каждой секции. По умолчанию 1ю
    // в секциях, где списки – размер этих списков
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return testList.count // список покупок (товаров)
        }
        if section == 6 {
            return placesList.count // список магазинов
        }
        
        return 1
    }
    
    // инициализация секций главной таблицы (главного экрана)
    // Главный экран состоит из ячеек (секций), здесь определяется
    // Как будет выглядить каждая секция
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
            // ----- список покупок -----
        // Заголовок "Добавьте покупку"
        case 0: do {
            cell = tableView.dequeueReusableCell(withIdentifier: "cellAddBuyTitle", for: indexPath)
            cell.selectionStyle = UITableViewCell.SelectionStyle.none; //убирает выделение секции
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0); //убирает разделительные линии
            
            }
        // Кнопка "добавить покупку" в начало списка
        case 1: do {
            cell = tableView.dequeueReusableCell(withIdentifier: "cellAddBuyTopSection", for: indexPath) as! AddBuyTopSection
            cell.selectionStyle = UITableViewCell.SelectionStyle.none;
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            showHideBuyTopTitle() //определяет, нужно ли показывать первую секцию с заголовком
            }
            
        // Список покупок (товаров)
        case 2: do {
            let mCell = tableView.dequeueReusableCell(withIdentifier: "cellAddBuyListSection", for: indexPath) as! AddBuyListSection
            mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none;
            mCell.title.text = testList[indexPath.row]
            cell = mCell
            }
            
        // Кнопка добавить в конец списка товаров и текстовое поле
        case 3: do {
            let mCell = tableView.dequeueReusableCell(withIdentifier: "cellAddBuyBottomSection", for: indexPath) as! AddBuyBottomSection
            mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none;
            cell = mCell
            showHideBuyBottom()
            }
            
            // ----– список названий магазинов -----
        // Заголовок "Добавьте магазин"
        case 4: do {
            let mCell = tableView.dequeueReusableCell(withIdentifier: "cellAddPlaceTitle", for: indexPath) as! AddPlaceTitleSection
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none;
            mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            if (testList.count != 0) {
                mCell.title.isHidden = false
            }
            cell = mCell
            }
        // Кнопка "добавить магазин" в начало списка
        case 5: do {
            let mCell = tableView.dequeueReusableCell(withIdentifier: "cellAddPlaceTopSection", for: indexPath) as! AddPlaceTopSection
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none;
            mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            cell = mCell
            }
        // Список магазинов
        case 6: do {
            let mCell = tableView.dequeueReusableCell(withIdentifier: "cellAddPlaceListSection", for: indexPath) as! AddPlaceListSection
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none;
            mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            mCell.title.text = placesList[indexPath.row]
            cell = mCell
            }
        // Кнопка добавить в конец списка магазинов и текстовое поле
        case 7: do {
            let mCell = tableView.dequeueReusableCell(withIdentifier: "cellAddPlaceBottomSection", for: indexPath) as! AddPlaceBottomSection
            mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none;
            cell = mCell
            }
        // Таблица цен
        case 8: do {
            let mCell = tableView.dequeueReusableCell(withIdentifier: "PriceSheet", for: indexPath) as! PriceSheet
            
            // Получаем текущие объекты таблицы и коллекции для дальнейшего взаимодействия с ними
            // так как изначально они привязаны к "ячейке главной таблицы"
            if (gridLayout == nil) {
                gridLayout = mCell.gridLayout
                collectionViewPrices = mCell.priceSheetColl
                collectionViewPrices!.delegate = self
                
            }
            if (testList.count != 0 && placesList.count != 0) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPriceSheet"), object: nil)
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePriceSheet"), object: nil)
            }
            mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none;
            cell = mCell
            }
        default:
            break
        }
        return cell
    }
    
    
    //MARK:- Таблица цен
    
    // сколько по ширине
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placesList.count+1 // +1, так как размер списка + фиксированный столбец слева
    }
    
    // сколько по высоте
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return testList.count+2 // +2, так как размер списка + строка сверху на колонки + строка снизу на итоговую сумму
    }
    
    // назначение данных для отображения в конкретных строках
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let mCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PriceSheetCell", for: indexPath) as! PriceSheetCell
        if (gridLayout != nil) {
            mCell.backgroundColor = gridLayout!.isItemSticky(at: indexPath) ? UIColor(named: "table_price_sticky_cells") : UIColor(named: "table_price_cells")
        }
        mCell.textFieldCell.delegate = self
        
        
        //первая колонка
        //row - строка
        //1я колонка
        if (indexPath.row == 0 && indexPath.section >= 1 && indexPath.section <= testList.count) {
            mCell.label.text = testList[indexPath.section-1]
            mCell.label.isHidden = false
            mCell.textFieldCell.isHidden = true
        }
        //1я строка
        if (indexPath.section == 0 && indexPath.row >= 1) {
            mCell.label.text = placesList[indexPath.row-1]
            mCell.label.isHidden = false
            mCell.textFieldCell.isHidden = true
        }
        // сумма, последняя строка
        if (indexPath.section == testList.count+1 && indexPath.row > 0) {
            mCell.label.isHidden = false
            mCell.textFieldCell.isHidden = true
            mCell.label.text = String(format:"%.2f", sumArray[indexPath.row-1] ?? 0.00)
        }
        
        if (indexPath.row == 0 && indexPath.section == 0) {
            mCell.label.text = ""
            mCell.textFieldCell.isHidden = true
        }
        // ячейка "сумма", последняя строка, первый столбец
        if (indexPath.row == 0 && indexPath.section == testList.count+1) {
            mCell.label.isHidden = false
            mCell.textFieldCell.isHidden = true
            mCell.label.text = "Сумма"
        }
        
        // ячейки с числами
        if (indexPath.row != 0 && indexPath.section != 0 && indexPath.section <= testList.count && indexPath.row <= placesList.count) {
            //mCell.label.text = "\(indexPath)"
            let a = pricesArray[indexPath.section-1][indexPath.row-1]
            mCell.textFieldCell.text = String(format:"%.2f", a ?? 0.00)
            mCell.textFieldCell.isHidden = false
            mCell.label.isHidden = true
            mCell.textFieldCell.item = MiniCell(row: indexPath.section-1, column: indexPath.row-1)
            
            
            //let item = a
            //mCell.textField.item = item
            
        }
        
        return mCell
    }
    
    //    MARK:- сохранение значения в ячейке таблицы цен
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let textField = textField as? DictionaryTextField else {
            return
        }
        let row = textField.item!.row
        let column = textField.item!.column
        print(row, column, "tut")
        //        var str = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        //        str = str.replacingOccurrences(of: ",", with: ".")
        //        let res = Double(str)
        let res = Double(textField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        print("Проходит2")
        if (textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
            pricesArray[row][column] = 0.00
            sumPrices()
            reloadDataCollection()
            print("Проходит3")
        } else
            
            //Если введены некорректные данные
            if res == nil {
                textField.text =  String(format:"%.2f", pricesArray[row][column] ?? 0.00)
                print("Проходит4")
            } else {
                
                //Если все подходит
                print(row, column)
                pricesArray[row][column] = res
                sumPrices()
                reloadDataCollection()
                print("Проходит5")
        }
    }
    
    /// функция для обновления таблицы цен
    @objc func reloadDataCollection() {
        collectionViewPrices?.reloadData()
    }
    
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: PriceSheetCell) {
        if let indexPath = collectionViewPrices!.indexPath(for: cell), let text = textField.text {
            print("textField text: \(text) from cell: \(indexPath))")
            //textFieldsTexts[indexPath] = text
        }
    }
    
    
    //   func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: PriceSheetCell)  -> Bool {
    //       print("Validation action in textField from cell: \(String(describing: collectionViewPrices!.indexPath(for: cell)))")
    //       return true
    //   }
    
    //MARK:- конец таблицы цен
    
    
    // MARK:- Удаление из списков
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //Удаление из списка покупок
        if editingStyle == .delete && indexPath.section == 2 {
            testList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            removeRow(at: indexPath.row)
            showHideBuyTopTitle()
            showHideBuyBottom()
            showHidePlaces()
            showHidePriceSheet()
            reloadDataCollection()
            showHidePlacesTitle()
        }
        //Удаление из списка магазинов
        if editingStyle == .delete && indexPath.section == 6 {
            placesList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            showHidePriceSheet()
            reloadDataCollection()
            //showHidePlaces()
        }
    }
    
    
    
    func showHideBuyTopTitle() {
        if (testList.count == 0) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyTopTitle"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideBuyTopTitle"), object: nil)
        }
    }
    
    func showHidePriceSheet() {
        if (placesList.count == 0 || testList.count == 0) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePriceSheet"), object: nil)
        }
    }
    
    /// Показывать или скрывать элементы нижней секции добавления покупок
    func showHideBuyBottom() {
        if (testList.count) == 0 {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideBuyBottomButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideBuyTextField"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyBottomButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyTextField"), object: nil)
        }
    }
    
    func showHidePlaces() {
        if (testList.count == 0) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceList"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
            
            
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceList"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTitle"), object: nil)
        }
    }
    
    func showHidePlacesTitle() {
        if (testList.count == 0) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTitle"), object: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 2) {
            testList.remove(at: indexPath.row)
        }
    }
    
    
}

//клавиатура – скрыть при нажатии в пустую область
extension UIViewController
{
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

protocol CollectionViewCellDelegate {
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: PriceSheetCell)
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: PriceSheetCell)  -> Bool
}
