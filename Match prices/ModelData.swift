//
//  ModelData.swift
//  Match prices

import Foundation


//Data
var priceSheetCellWidth = 100
var priceSheetCellHeight = 50
var isFirstStart = false


var buyList = [String]()
var placesList = [String]()

var pricesArray = [[Double?]]()
var currentListTitle : String? = nil //название текущего списка

var sumArray = [Double?]()
var titlesList = [String]()

let savedListsKey = "savedListsKey"
var currentBuyTitle : String = "Добавьте товары"
var currentPlacesTitle : String = "Добавьте магазины"
let list = ["товары2", "наименования", "услуги", "материалы", "лекарства", "продукты", "ингредиенты", "товары"]
let placesListTitles = ["магазины", "аптеки", "исполнители", "продавцы", "мастерские", "магазины"]

var arrowCounter = 0
/*
 Размер двумерного массива должен быть размеры обычных массивов
 */


func loadStartTestData() {
    //Подгрузить данные (для тестирование)
//    buyList.append("Hello")
//    placesList.append("World")
//    placesList.append("World1")
//    placesList.append("World2")
    var savedList : SavedList?
    currentListTitle = getCurrentListTitle()
    if (currentListTitle != nil) {
        
        savedList = getSavedList(title: currentListTitle!)
        if (savedList != nil) {
            buyList = savedList!.testArray ?? [String]()
            placesList = savedList!.placesArray ?? [String]()
            pricesArray = savedList!.pricesArray ?? [[Double?]](repeating: [Double?](repeating: 0.0, count: placesListCount()), count: buyListCount())
            print(buyList, placesList, pricesArray)
        }
    } else {
        pricesArray = [[Double?]](repeating: [Double?](repeating: 0.0, count: placesListCount()), count: buyListCount())
    }
    sumPrices()
}

/// добавление в талицу цен последней строки товара
func addRowToEnd() {
    pricesArray.append([Double?](repeating: 0.00, count: placesListCount()))
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

/// добавление в талицу цен первой строки товара
func addRowToStart() {
    pricesArray.insert([Double?](repeating: 0.00, count: placesListCount()), at: 0)
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}


//добавление последнего столбца магазина
func addColumnToEnd() {
    if (pricesArray.count == 0) {
        pricesArray.append([Double?](repeating: 0.00, count: placesListCount()))
    }
    for i in 0..<buyListCount() {
        pricesArray[i].append(0.00)
    }
    sumArray.append(0.00)
    showPriceArrow()
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showScrollPriceSheet"), object: nil)
    
}

/// добавление первого столбца магазина
func addColumnToStart() {
    if (pricesArray.count == 0) {
        pricesArray.append([Double?](repeating: 0.00, count: placesListCount()))
    }
    for i in 0..<buyListCount() {
        pricesArray[i].insert(0.00, at: 0)
    }
    sumArray.insert(0.00, at: 0)
    showPriceArrow()
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showScrollPriceSheet"), object: nil)
}

/// Удаление столбца из таблицы цен
func removeColumn(at index : Int) {
    print(index, "column")
    for i in 0..<buyListCount() {
        pricesArray[i].remove(at: index)
    }
    sumArray.remove(at: index)
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

/// Удалить из таблицы цен строку
func removeRow(at index : Int) {
    print(index, "row")
    pricesArray.remove(at: index)
    if (placesListCount() != 0) {
        sumArray.remove(at: index)
    }
    sumPrices()
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

/// пересчет суммы в столбцах
func sumPrices() {
    
    if placesListCount() != 0 {
        sumArray = [Double?](repeating: 0.00, count: placesListCount())
        for i in 0..<placesListCount() {
            var summ = 0.00
            
            for j in 0..<buyListCount() {
                summ += pricesArray[j][i] ?? 0.00
            }
            sumArray[i]=summ
        }
    }
    
    
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

//MARK: -Работа с сохраненными данными

/// сохранение списка, вывод Bool необходим в будущем,
/// чтобы проверять, что сохранение прошло успешно.
/// True – сохранилось
func saveList(title : String) -> Bool {
    let savedList = SavedList()
    savedList.testArray = buyList
    savedList.placesArray = placesList
    savedList.pricesArray = pricesArray
    
    if let encoded = try? JSONEncoder().encode(savedList) {
        UserDefaults.standard.set(encoded, forKey: currentListTitle ?? "sample")
        UserDefaults.standard.synchronize()
    }
    return true
}


/// Получает сохраненный список, если списка нет – выводит null
/// - Parameter title: название приложения
func getSavedList(title : String) -> SavedList? {
    if let listData = UserDefaults.standard.data(forKey: title),
        let list = try? JSONDecoder().decode(SavedList.self, from: listData) {
        return list
    } else {
        return nil
    }
}


/// Используется для изменения названия списков или при проверке сохранения нового списка,
/// True – свободно, False – занято
/// - Parameter title: Название списка
func checkIfSavedListTitleEmpty(title : String) -> Bool {
    if (UserDefaults.standard.data(forKey: title) == nil) {
        return true
    } else {
        return false
    }
}


/// Получить список названий сохраненных списков
func getSavedLists() -> [String]? {
    
    if let listData = UserDefaults.standard.data(forKey: savedListsKey),
        let list = try? JSONDecoder().decode(SavedListTitles.self, from: listData) {
        return list.mList
    } else {
        return nil
    }
}


/// Добавляет к списку названий новое название
func setSavedLists(title : String) {
    var list = [String]()
    
    //получили текущий список названий
    if let listData = UserDefaults.standard.data(forKey: savedListsKey),
        let lists = try? JSONDecoder().decode(SavedListTitles.self, from: listData) {
        if (lists.mList != nil) {
            list = lists.mList!
            titlesList = list
        }
        UserDefaults.standard.synchronize()
    }
    
    //закодировать
    let object = SavedListTitles()
    list.append(title) //добавить к списку новое название
    object.mList = list
    
    //Сохранить
    if let encoded = try? JSONEncoder().encode(object) {
        UserDefaults.standard.set(encoded, forKey: savedListsKey)
        UserDefaults.standard.synchronize()
    }
}

/// Сохранить текущее название
func setCurrentListTitle() {
    UserDefaults.standard.set(currentListTitle, forKey: "currentListTitle")
    UserDefaults.standard.synchronize()
}

/// Получить сохраненное название текущего списка
func getCurrentListTitle() -> String? {
    let res = UserDefaults.standard.string(forKey: "currentListTitle")
    return res
}


// Обновить список названий списков
func updateSavedLists() {
    let object = SavedListTitles()
    object.mList = titlesList
    if let encoded = try? JSONEncoder().encode(object) {
        UserDefaults.standard.set(encoded, forKey: savedListsKey)
        UserDefaults.standard.synchronize()
    }
}

/// Удалить элемент из массива названий списков
/// - Parameters:
///   - index: позиция в массиве
///   - title: название списка (элемента)
func removeListFromTitlesList(at index : Int, title : String) {
    UserDefaults.standard.set(nil, forKey: title)
    UserDefaults.standard.synchronize()
    titlesList.remove(at: index)
    updateSavedLists()
}

/// Возвращает True, если получилось изменить название, fale – не получилось
/// - Parameter title: обновленное название списка
func changeTitleList(oldTitle : String, newTitle : String) -> Bool {
    titlesList = getSavedLists() ?? [String]()
    guard let index = titlesList.firstIndex(of: oldTitle) else {
        print(titlesList, "22")
        return false
    }
    if (checkIfSavedListTitleEmpty(title: newTitle)) {
        currentListTitle = newTitle
        setCurrentListTitle()
        removeListFromTitlesList(at: index, title: oldTitle)
        titlesList.insert(newTitle, at: index)
        updateSavedLists()
        guard saveList(title: currentListTitle!) else {
            print(titlesList, "23")
            return false
        }
        return true
    } else {
        return false
    }
    
}

// MARK: - методы подсчета чистых массивов
/*
 Выводят и считают массивы без пустого значение
 Пустое значение появляется, когда происходит добавление
 нового элемента в спсики названий но еще без самого названия
 */

/// выводит размер массива покупок без пустых значений
func buyListCount() -> Int {
    return getbuyList().count
}


/// выводит массив покупок без пустых значений
func getbuyList() -> [String] {
    var k = [String]()
    for i in buyList {
        if i != "" {
            k.append(i)
        }
        
    }
    return k
}

/// выводит размер массива магазинов без пустых значений
func placesListCount() -> Int {
    return getPlacesList().count
}

/// выводит массив магазинов без пустых значений
func getPlacesList() -> [String] {
    var k = [String]()
    for i in placesList {
        if i != "" {
            k.append(i)
        }
        
    }
    return k
}

/// Класс для сохранения структуры списка в долгую память
class SavedList : Codable {
    var testArray: [String]?
    var placesArray : [String]?
    var pricesArray : [[Double?]]?
}

/// Класс для сохранения списка названий
class SavedListTitles : Codable {
    var mList : [String]?
}

func showPriceArrow() {
    // если в списке магазинов больше 3
    if placesListCount() > 3 && arrowCounter > 0
    {
        
        arrowCounter-=1
        
//        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showArrow"), object: nil)
//
//        })
//        DispatchQueue.main.asyncAfter(deadline: .now()+1.5, execute: {
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideArrow"), object: nil)
//        })
//        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showArrow"), object: nil)
//
//        })
//        DispatchQueue.main.asyncAfter(deadline: .now()+2.5, execute: {
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideArrow"), object: nil)
//        })
        
        
    }
}



//func initialEmpty() {
//    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
//    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTop"), object: nil)
//    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
//}

/// проверяет, запущено ли приложение в первый раз
/// Если да – сохраняет значение в память
func firstStartApp() {
    if (!UserDefaults.standard.bool(forKey: "firstStart")) {
        UserDefaults.standard.set(3, forKey: "arrow_counter")
        isFirstStart = true
        UserDefaults.standard.set(true, forKey: "firstStart")
    }
    if (UserDefaults.standard.integer(forKey: "arrow_counter") > 0) {
        arrowCounter = 2
    }
}

