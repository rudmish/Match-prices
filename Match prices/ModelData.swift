//
//  ModelData.swift
//  Match prices
//
//  Created by Евгений Конев on 08.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import Foundation


//Data
var priceSheetCellWidth = 100
var priceSheetCellHeight = 50
var isFirstStart = false


var testList = [String]()
var placesList = [String]()

var pricesArray = [[Double?]]()
var currentListTitle : String? = nil //название текущего списка

var sumArray = [Double?]()
var titlesList = [String]()

let savedListsKey = "savedListsKey"

/*
 Размер двумерного массива должен быть размеры обычных массивов
 */

//func createPricesArray() {
//    pricesArray[1][1] = 3.3
//}

func loadStartTestData() {
    //Подгрузить данные
//    testList.append("Hello")
//    placesList.append("World")
//    placesList.append("World1")
//    placesList.append("World2")
    var savedList : SavedList?
    //currentListTitle = nil
    currentListTitle = getCurrentListTitle()
    if (currentListTitle != nil) {
        
        savedList = getSavedList(title: currentListTitle!)
        if (savedList != nil) {
            testList = savedList!.testArray ?? [String]()
            placesList = savedList!.placesArray ?? [String]()
            pricesArray = savedList!.pricesArray ?? [[Double?]](repeating: [Double?](repeating: 0.0, count: placesListCount()), count: testListCount())
        }
    } else {
        pricesArray = [[Double?]](repeating: [Double?](repeating: 0.0, count: placesListCount()), count: testListCount())
    }
//    pricesArray = [[Double?]](repeating: [Double?](repeating: 0.0, count: placesList.count), count: testListCount())
//    pricesArray = [[Double?]](repeating: [Double?](repeating: 0.0, count: placesList.count), count: testListCount())
    
//    sumPrices()
    
    //setSavedLists(title: currentListTitle!)
//    print(getSavedLists()?.count, "llll")
//    testList.append("Hello")
//    testList.append("Hello1")
//    testList.append("Hello2")
//    testList.append("Hello3")
//    testList.append("Hello4")
//    placesList.append("World")
//    placesList.append("World1")
//    placesList.append("World2")
//    placesList.append("World3")
//    placesList.append("World4")
//    placesList.append("World5")
    
//    pricesArray[0][1] = 5.00
//    pricesArray[0][2] = 2.00
//    pricesArray[1][1] = 3.00
    sumPrices()
    //    print("t", sumPrices())
}

//добавление последней строки товара
func addRowToEnd() {
//    if (pricesArray[0].count == 0) {
//        pricesArray.append([Double?](repeating: 0.00, count: placesListCount()))
//    }
    pricesArray.append([Double?](repeating: 0.00, count: placesListCount()))
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

//добавление первой строки товара
func addRowToStart() {
//    if (pricesArray[0].count == 0) {
//        pricesArray.append([Double?](repeating: 0.00, count: placesListCount()))
//    }
    pricesArray.insert([Double?](repeating: 0.00, count: placesListCount()), at: 0)
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

func removeRow(at index : Int) {
    pricesArray.remove(at: index)
    sumArray.remove(at: index)
    sumPrices()
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
    for i in 0..<testListCount() {
        pricesArray[i].append(0.00)
    }
    sumArray.append(0.00)
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

//добавление первого столбца магазина
func addColumnToStart() {
    if (pricesArray.count == 0) {
        pricesArray.append([Double?](repeating: 0.00, count: placesListCount()))
    }
    for i in 0..<testListCount() {
        pricesArray[i].insert(0.00, at: 0)
    }
    sumArray.insert(0.00, at: 0)
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

func removeColumn(at index : Int) {
    for i in 0..<testListCount() {
        pricesArray[i].remove(at: index)
    }
    sumArray.remove(at: index)
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

func sumPrices() {
    //pricesArray = [[Double?]](repeating: [Double?](repeating: 0.0, count: placesListCount()), count: testListCount())
    
    sumArray = [Double?](repeating: 0.00, count: placesListCount())
    for i in 0..<placesListCount() {
        var summ = 0.00
        
        for j in 0..<testListCount() {
            summ += pricesArray[j][i] ?? 0.00
        }
        sumArray[i]=summ
    }
    if (currentListTitle != nil) {
        guard saveList(title: currentListTitle!) else {
            return
        }
    }
}

//MARK: -Работа с сохраненными данными

func saveList(title : String) -> Bool {
    let savedList = SavedList()
    savedList.testArray = testList
    savedList.placesArray = placesList
    savedList.pricesArray = pricesArray
    
//    guard !checkIfSavedListTitleEmpty(title: title) else {
//        print("занято")
//        return false
//    }
    if let encoded = try? JSONEncoder().encode(savedList) {
        UserDefaults.standard.set(encoded, forKey: currentListTitle ?? "g")
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
        }
    }
    
    //закодировать
    let object = SavedListTitles()
    list.append(title) //добавить к списку новое название
    object.mList = list
    
    //Сохранили
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
    guard let index = titlesList.firstIndex(of: oldTitle) else {
        return false
    }
    if (checkIfSavedListTitleEmpty(title: newTitle)) {
        currentListTitle = newTitle
        setCurrentListTitle()
        removeListFromTitlesList(at: index, title: oldTitle)
        titlesList.insert(newTitle, at: index)
        updateSavedLists()
        guard saveList(title: currentListTitle!) else {
            return false
        }
        return true
    } else {
        return false
    }
    
}

func testListCount() -> Int {
    return getTestList().count
}

func getTestList() -> [String] {
    var k = [String]()
    for i in testList {
        if i != "" {
            k.append(i)
        }
        
    }
    return k
}

func placesListCount() -> Int {
    return getPlacesList().count
}

func getPlacesList() -> [String] {
    var k = [String]()
    for i in placesList {
        if i != "" {
            k.append(i)
        }
        
    }
    return k
}

class SavedList : Codable {
    var testArray: [String]?
    var placesArray : [String]?
    var pricesArray : [[Double?]]?
}

class SavedListTitles : Codable {
    var mList : [String]?
}

func showBuyTitleFirstTime() {
    //if first
    
}


func initialEmpty() {
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTitle"), object: nil)
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceTop"), object: nil)
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hidePlaceBottom"), object: nil)
}

func firstStartApp() {
    if (!UserDefaults.standard.bool(forKey: "firstStart")) {
        isFirstStart = true
        UserDefaults.standard.set(true, forKey: "firstStart")
    }
}
