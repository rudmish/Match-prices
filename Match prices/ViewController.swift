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
    
    var timerBuyTitle : Timer?
    var timerPlaceTitle : Timer?
    var currentBuyTitle : String = "Добавьте товары"
    var currentPlacesTitle : String = "Добавьте магазины"
    let list = ["товары2", "наименования", "услуги", "материалы", "лекарства", "продукты", "ингредиенты", "товары"]
    let placesListTitles = ["магазины", "аптеки", "исполнители", "продавцы", "мастерские", "магазины"]
    
    var cell = UITableViewCell() //ячейка главной таблицы
    
    @IBAction func donatButton(_ sender: Any) {
//        reloadDataCollection()
        
    }
    
    
    //MARK:- Основной метод инициализации
    /// Основной метод – инициализация. Здесь указывается все, что должно создаться или прикрепиться при открытии этого "экрана"
    override func viewDidLoad() {
        super.viewDidLoad()

        firstStartApp()
        
        loadStartTestData() 
        //Методы, для доступа к текущим данным из дургих классов. Например, обновить списки
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "updateLists"), object: nil) //обновить списки
        NotificationCenter.default.addObserver(self, selector: #selector(reloadDataCollection), name: NSNotification.Name(rawValue: "reloadDataCollection"), object: nil) //обновить таблицу цен
        
        
        // NEW
        NotificationCenter.default.addObserver(self, selector: #selector(addBuyTop), name: NSNotification.Name(rawValue: "addBuyTop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addBuyBottom), name: NSNotification.Name(rawValue: "addBuyBottom"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addPlaceTop), name: NSNotification.Name(rawValue: "addPlaceTop"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addPlaceBottom), name: NSNotification.Name(rawValue: "addPlaceBottom"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(scheduledTimerWithTimeIntervalV2), name: NSNotification.Name(rawValue: "scheduledTimerWithTimeIntervalV2"), object: nil)
        
        if (isFirstStart) {
            scheduledTimerWithTimeInterval()
        }
        
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
        
//        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
//        longPressGesture.minimumPressDuration = 0.5
//        self.tableView.addGestureRecognizer(longPressGesture)
        
        
    }
    
//    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
//        let p = longPressGesture.location(in: self.tableView)
//        let indexPath = self.tableView.indexPathForRow(at: p)
//        if indexPath == nil {
//            print("Long press on table view, not row.")
//        } else if longPressGesture.state == UIGestureRecognizer.State.began {
//            print("Long press on row, at \(indexPath!.row)")
//        }
//    }
    
    @objc func navBarSavedListsButtonAction() {
        let VC1 = self.storyboard!.instantiateViewController(withIdentifier: "SavedListsTableView") as! SavedListsTableView
        VC1.delegate = self
        let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
        self.present(navController, animated:true, completion: nil)
    }
    
    @objc func navBarOptionsButtonAction() {
        createAlertItem()
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell2 = cell as? AddBuyListSection {
            if (cell2.title.text == "") {
                cell2.title.becomeFirstResponder()
            }
        }
        if let cell2 = cell as? AddPlaceListSection {
            if (cell2.title.text == "") {
                cell2.title.becomeFirstResponder()
            }
        }
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
            for i in 0..<testListCount() {
                let first = pricesArray[i][fromIndexPath.row]
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
        if (indexPath.section == 2 && (testList[0] == "" || testList[indexPath.row] == "")) {
            return false
        }
        if (indexPath.section == 6 && (placesList[0] == "" || placesList[indexPath.row] == "")) {
            return false
        }
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
            let mCell = tableView.dequeueReusableCell(withIdentifier: "AddBuyTitleSection", for: indexPath) as! AddBuyTitleSection
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none; //убирает выделение секции
            mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0); //убирает разделительные линии
            mCell.title.text = currentBuyTitle
            cell = mCell
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
            // mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            mCell.selectionStyle = UITableViewCell.SelectionStyle.none;
            mCell.title.text = testList[indexPath.row]
            mCell.title.item = PosTextField(row: indexPath.row)
//            mCell.title.delegate = self
//            mCell.title.becomeFirstResponder()
            //mCell.title.addGestureRecognizer(gesture!)
            
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
                mCell.title.isEnabled = true
            }
            mCell.title.text = currentPlacesTitle
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
            // mCell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.size.width, bottom: 0, right: 0);
            mCell.title.text = placesList[indexPath.row]
            mCell.title.item = PosTextField(row: indexPath.row)
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
            if (testListCount() != 0 && placesListCount() != 0) {
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
        return placesListCount()+1 // +1, так как размер списка + фиксированный столбец слева
    }
    
    // сколько по высоте
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return testListCount()+2 // +2, так как размер списка + строка сверху на колонки + строка снизу на итоговую сумму
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
        if (indexPath.row == 0 && indexPath.section >= 1 && indexPath.section <= testListCount()) {
            mCell.label.text = getTestList()[indexPath.section-1]
            mCell.label.isHidden = false
            mCell.label.textAlignment = .left
            mCell.textFieldCell.isHidden = true
        }
        //1я строка
        if (indexPath.section == 0 && indexPath.row >= 1) {
            
            mCell.label.text = getPlacesList()[indexPath.row-1]
            mCell.label.isHidden = false
            mCell.label.textAlignment = .center
            mCell.textFieldCell.isHidden = true
        }
        // сумма, последняя строка
        if (indexPath.section == testListCount()+1 && indexPath.row > 0) {
            mCell.label.isHidden = false
            mCell.textFieldCell.isHidden = true
            mCell.label.textAlignment = .center
            
            let isInteger = floor(sumArray[indexPath.row-1] ?? 0.00) == sumArray[indexPath.row-1]
            if isInteger {
                mCell.label.text = String(format:"%.f", sumArray[indexPath.row-1] ?? 0.00)
            } else {
                mCell.label.text = String(format:"%.2f", sumArray[indexPath.row-1] ?? 0.00)
            }
        }
        
        //верхняя левая ячейка пустая
        if (indexPath.row == 0 && indexPath.section == 0) {
            mCell.label.text = ""
            mCell.textFieldCell.isHidden = true
        }
        // ячейка "сумма", последняя строка, первый столбец
        if (indexPath.row == 0 && indexPath.section == testListCount()+1) {
            mCell.label.isHidden = false
            mCell.textFieldCell.isHidden = true
            mCell.label.textAlignment = .left
            mCell.label.text = "Итог"
        }
        
        // ячейки с числами
        if (indexPath.row != 0 && indexPath.section != 0 && indexPath.section <= testListCount() && indexPath.row <= placesListCount()) {
//            mCell.textFieldCell.text = "\(indexPath)"
            let a = pricesArray[indexPath.section-1][indexPath.row-1]
            if (a == nil || a == 0.00) {
                mCell.textFieldCell.text = ""
                mCell.textFieldCell.placeholder = "-"
            } else {
                let isInteger = floor(a ?? 0.00) == a
                if isInteger {
                    mCell.textFieldCell.text = String(format:"%.f", a ?? 0.00)
                } else {
                    mCell.textFieldCell.text = String(format:"%.2f", a ?? 0.00)
                }
                
            }
            mCell.textFieldCell.isHidden = false
            mCell.label.isHidden = true
            mCell.textFieldCell.item = MiniCell(row: indexPath.section-1, column: indexPath.row-1)
            
            //let item = a
            //mCell.textField.item = item
        }
        
        return mCell
    }
    
    //    MARK:- сохранение значения в списках
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let textField = textField as? BuyListTextField  {
            let row = textField.item!.row
            let res = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if (!res.isEmpty) {
                
                testList[row] = res
                tableView.reloadData()
                sumPrices()
                reloadDataCollection()
                
            }
        }
        
        if let textField = textField as? DictionaryTextField  {
            let row = textField.item!.row
            let column = textField.item!.column
            let res = Double(textField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
            
            if (textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                reloadDataCollection()
            } else
                
                //Если введены некорректные данные
                if res == nil {
                    
                    if (pricesArray[row][column] == nil || pricesArray[row][column] == 0.00) {
                        textField.text = ""
                        textField.placeholder = "-"
                    } else {
                        textField.text =  String(format:"%.2f", pricesArray[row][column] ?? 0.00)
                    }
                } else {
                    pricesArray[row][column] = res
                    sumPrices()
                    reloadDataCollection()
            }
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
//            showHidePlaces()
            showHidePriceSheet()
            reloadDataCollection()
//            showHidePlacesTitle()
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
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
            //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceList"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
            
            
            
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceBottom"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceList"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTitle"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTitle"), object: nil)
        }
    }
    
    func showHidePlacesTitle() {
        if (testList.count == 0) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showPlaceTitle"), object: nil)
        }
    }
    
    //MARK:- нажатие по элементам (click)
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if (indexPath.section == 2 || indexPath.section == 6) {
//            showItemAlert(at: indexPath.row, section: indexPath.section, indexPath: indexPath)
//        }
    }
    
    func showItemAlert(at index : Int, section : Int, indexPath : IndexPath) {
        let optionMenu = UIAlertController(title: nil, message: "Выберите действие", preferredStyle: .actionSheet)
        
        let changeTitleAction = UIAlertAction(title: "Изменить название", style: .default, handler: {action in
            
            let alertSaveList = UIAlertController(title: "Новое название", message: nil, preferredStyle: .alert)
            alertSaveList.addTextField { (textField) in
                
                if (section == 2) {
                    textField.placeholder = testList[index] + "..."
                }
                if (section == 6) {
                    textField.placeholder = placesList[index] + "..."
                }
                
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
                
                if (section == 2) {
                    testList[index] = title!
                }
                if (section == 6) {
                    placesList[index] = title!
                }
                
                if (currentListTitle != nil) {
                    guard saveList(title: currentListTitle!) else {
                        return
                    }
                }
                
                self.tableView.reloadData()
                collectionViewPrices?.reloadData()
            })
            alertSaveList.addAction(okAction)
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
            
            alertSaveList.addAction(cancelAction)
            self.present(alertSaveList, animated: true, completion: nil)
            
            
        })
        let actionRemove = UIAlertAction(title: "Удалить", style: .default, handler: {action in
            if section == 2 {
                testList.remove(at: index)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                removeRow(at: index)
                self.showHideBuyTopTitle()
                self.showHideBuyBottom()
//                self.showHidePlaces()
                self.showHidePriceSheet()
                self.reloadDataCollection()
//                self.showHidePlacesTitle()
            }
            //Удаление из списка магазинов
            if section == 6 {
                placesList.remove(at: index)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.showHidePriceSheet()
                self.reloadDataCollection()
                //showHidePlaces()
            }
        })
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        optionMenu.addAction(changeTitleAction)
        optionMenu.addAction(actionRemove)
        optionMenu.addAction(cancelAction)
        present(optionMenu, animated: true, completion: nil)
    }
    
    // MARK: - Alert
    func createAlertItem() {
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
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTopButton"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
            
            
            
            
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
    
    
    
    //MARK: - новые методы
    @objc func addBuyTop() {
        testList.insert("", at: 0)
        tableView.reloadData()
        sumPrices()
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showBuyBottomButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyBottomButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
    }
    
    
    @objc func addBuyBottom() {
        testList.insert("", at: testListCount())
        self.tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyBottomButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBuyTopButton"), object: nil)
  
    }
    
    @objc func addPlaceTop() {
        placesList.insert("", at: 0)
        self.tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceBottomButton"), object: nil)
    }
    
    @objc func addPlaceBottom() {
        placesList.insert("", at: placesListCount())
        self.tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceTopButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disablePlaceBottomButton"), object: nil)
    }
    
    //MARK: - таймеры
    var i = 0
    var j = 0
    func scheduledTimerWithTimeInterval() {
        timerBuyTitle = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(updateBuyTitle), userInfo: nil, repeats: true)
    }
    func stopTimerBuyList() {
        timerBuyTitle?.invalidate()
        timerBuyTitle = nil
    }
    
    @objc func updateBuyTitle() {
        
        if (i != list.count-1) {
            i += 1
            currentBuyTitle = "Добавьте \(list[i])"
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.reloadRows(at: [indexPath], with: .fade)
        } else {
            stopTimerBuyList()
        }
    }
    
    @objc func scheduledTimerWithTimeIntervalV2() {
        if (timerPlaceTitle == nil) {
            timerPlaceTitle = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(updateBuyTitleV2), userInfo: nil, repeats: true)
        }
    }
    func stopTimerBuyListV2() {
        timerPlaceTitle?.invalidate()
        timerPlaceTitle = nil
    }
    
    @objc func updateBuyTitleV2() {
        
        if (j != placesListTitles.count-1) {
            j += 1
            currentPlacesTitle = "Добавьте \(placesListTitles[j])"
            
            let indexPath = IndexPath(item: 0, section: 4)
            tableView.reloadRows(at: [indexPath], with: .fade)
        } else {
            stopTimerBuyListV2()
        }
    }
    
    //MARK: - Alert remove
//    @objc func showMenuRemove(index : Int, section : Int) {
//        let optionMenu = UIAlertController(title: nil, message: "Выберите действие", preferredStyle: .actionSheet)
//
//
//        let actionRemove = UIAlertAction(title: "Удалить", style: .default, handler: {action in
//            if section == 2 {
//                testList.remove(at: index)
//                removeRow(at: index)
//                self.showHideBuyTopTitle()
//                self.showHideBuyBottom()
//                //                self.showHidePlaces()
//                self.showHidePriceSheet()
//                self.reloadDataCollection()
//                //                self.showHidePlacesTitle()
//            }
//            //Удаление из списка магазинов
//            if section == 6 {
//                placesList.remove(at: index)
//                removeColumn(at: index)
//                self.showHidePriceSheet()
//                self.reloadDataCollection()
//                //showHidePlaces()
//            }
//        })
//        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
//        optionMenu.addAction(actionRemove)
//        optionMenu.addAction(cancelAction)
//        present(optionMenu, animated: true, completion: nil)
//    }
//
    
    
}

//MARK: - нажатие в пустую область
//клавиатура – скрыть при нажатии в пустую область
extension UITableViewController
{
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(removeBuyEmpty))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    @objc func removeBuyEmpty() {
        self.dismissKeyboard()
//        if (testList.count > 0) {
//            if (testList[0] == "") {
//                testList.remove(at: 0)
//                self.tableView.reloadData()
//            } else
//            if (testList[testList.count-1] == "") {
//                testList.remove(at: testList.count-1)
//                self.tableView.reloadData()
//            }
//        }
//        if (placesList.count > 0) {
//            if (placesList[0] == "") {
//                placesList.remove(at: 0)
//                self.tableView.reloadData()
//            } else
//            if (placesList[placesList.count-1] == "") {
//                placesList.remove(at: placesList.count-1)
//                self.tableView.reloadData()
//            }
//        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyTopButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enableBuyBottomButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceTopButton"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "enablePlaceBottomButton"), object: nil)
//        becomeFirstResponder()
    }
    
    
    
    
    
}

class TouchGestureRecognizer: UIGestureRecognizer {

    var isLongPress: Bool = false
    fileprivate var startDateInterval: TimeInterval = 0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        state = .began
        self.startDateInterval = Date().timeIntervalSince1970
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
        self.isLongPress = (Date().timeIntervalSince1970 - self.startDateInterval) > 1.0
    }
}




protocol CollectionViewCellDelegate {
    func collectionViewCell(valueChangedIn textField: UITextField, delegatedFrom cell: PriceSheetCell)
    func collectionViewCell(textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String, delegatedFrom cell: PriceSheetCell)  -> Bool
}
