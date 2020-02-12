//
//  SavedListsTableView.swift
//  Match prices
//
//  Created by Евгений Конев on 12.02.2020.
//  Copyright © 2020 Nolit. All rights reserved.
//

import UIKit

class SavedListsTableView: UITableViewController {

    @IBAction func doneButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var delegate : PickNewList?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setEditing(true, animated: true)
        if (getSavedLists() != nil) {
            titlesList = getSavedLists()!
            self.tableView.reloadData()
        }
        self.tableView.allowsSelectionDuringEditing = true

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.pickList(title: titlesList[indexPath.row])
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return titlesList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SavedListsTableViewCell", for: indexPath)

        cell.textLabel?.text = titlesList[indexPath.row]

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            removeListFromTitlesList(at: indexPath.row, title: titlesList[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    

    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let from = titlesList[fromIndexPath.row]
        titlesList.remove(at: fromIndexPath.row)
        titlesList.insert(from, at: to.row)
        updateSavedLists()
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol PickNewList {
    func pickList(title : String)
}

extension ViewController : PickNewList {
    func pickList(title: String) {
        self.dismiss(animated: true, completion: {
            //Указывается, что нужно подгрузить для нового выбранного списка
            
            currentListTitle = title
            setCurrentListTitle()
            
            testList.removeAll()
            placesList.removeAll()
            pricesArray.removeAll()
            
            let list = getSavedList(title: title)
            testList = list?.testArray ?? [String]()
            placesList = list?.placesArray ?? [String]()
            pricesArray = list?.pricesArray ?? [[Double?]](repeating: [Double?](repeating: 0.0, count: placesList.count), count: testList.count)
            print(placesList.count)
            self.showHidePlaces()
            guard saveList(title: title) else {
                return
            }
            
            self.tableView.reloadData()
            collectionViewPrices?.reloadData()
            self.navigationItem.title = currentListTitle
            
            
        })
    }
}
