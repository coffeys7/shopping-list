//
//  ListsViewController.swift
//  ShoppingList
//
//  Created by Sam Coffey on 1/12/17.
//  Copyright © 2017 coffey. All rights reserved.
//

import Foundation
import UIKit
import Material
import ChameleonFramework
import Spring
import SwiftyUserDefaults
import Graph
import SCLAlertView

class ListsViewController: UIViewController {
    
    let tableViewHeight: CGFloat = 80.0
    fileprivate var tableView: UITableView!
    fileprivate var toolbar: Toolbar!
    fileprivate var dataSourceItems: Array<ListItem>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        prepareToolbar()
        prepareCells()
        prepareTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func prepareView() {
        view.backgroundColor = FlatMintDark()
    }
    
    fileprivate func prepareToolbar() {
        
        // setup toolbar
        toolbar = Toolbar()
        toolbar.backgroundColor = UIColor.clear
        toolbar.depth = DepthPresetToValue(preset: .depth5)
        toolbar.backgroundColor = FlatBlack().withAlphaComponent(0.2)
        view.layout(toolbar).top(20).left(0).right(0)
        
        // title label
        toolbar.title = "Grocery Lists"
        toolbar.titleLabel.textColor = FlatWhite()
        
        // right menu button
        let rightButton = IconButton()
        rightButton.image = Icon.addCircle?.tint(with: FlatWhite())
        rightButton.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        
        // left menu button
        let leftButton = IconButton()
        leftButton.image = Icon.menu?.tint(with: FlatWhite())
        
        // layout
        toolbar.leftViews = [leftButton]
        toolbar.rightViews = [rightButton]
    }
    
    @objc
    fileprivate func handleAddButton() {
        let alert = AddItemAlertView()
        let txt = alert.addTextField("List title")
        txt.autocapitalizationType = .none
        let btn = alert.addButton("Add List") {
            let lbl = txt.text!
            self.addNewList(label: lbl)
            
        }
        btn.backgroundColor = FlatGreen()
        alert.showEdit("Add a new list", subTitle: "Enter a title below for the new list", colorStyle: 0x22B573, animationStyle: .leftToRight)
    }
    
    fileprivate func addNewList(label: String) {
        let dateNow = Date()
        let newList = SCGraph.addList(title: label, date: dateNow)
        self.updateData(title: label, date: dateNow, entity: newList)
    }
    
    fileprivate func updateData(title: String, date: Date, entity: Entity) {
        let newItem = ListItem(title: title, date: date)
        newItem.listEntity = entity
        self.dataSourceItems.append(newItem)
        self.tableView.reloadData()
        self.tableView.reloadInputViews()
    }
    
}

/*
 Extension: Table View Prep
 */
extension ListsViewController {
    
    fileprivate func prepareCells() {
        dataSourceItems = Array<ListItem>()
        let graph = Graph()
        let search = Search<Entity>(graph: graph).for(types: "ListItem")
        let lists = search.sync()
        for list in lists {
            if let title = list["title"] as? String {
                if let date = list["date"] as? Date {
                    let newItem = ListItem(title: title, date: date)
                    newItem.listEntity = list
                    dataSourceItems.append(newItem)
                }
            }
        }
    }
    
    fileprivate func prepareTableView() {
        
        // initialize and customize the table view
        tableView = UITableView()
        tableView.register(ListItemTableViewCell.self, forCellReuseIdentifier: "ListItemTableViewCell")
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = FlatMintDark()
        tableView.tableFooterView = UIView()
        
        // layout the table view
        view.layout(tableView).edges(top: 90, left: 10, bottom: 10, right: 10)
        
    }
    
}

extension ListsViewController: UITableViewDelegate {
    
    /*
     delegate: didSelectRowAtIndexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // currently selected nav item
        let item: ListItem = dataSourceItems[(indexPath as NSIndexPath).row]
        print("Item: \(item.title!), Date: \(item.dateString())")
        self.present(ShoppingListViewController(list: item.listEntity), animated: true, completion: nil)
    }
    
    /*
     delegate: heightForRowAtIndexPath
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewHeight
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, index) in
            let item = self.dataSourceItems[index.row]
            SCGraph.removeList(list: item.listEntity)
            self.dataSourceItems.remove(at: index.row)
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
        }
        delete.backgroundColor = FlatRed()
        return [delete]
    }
    
}

extension ListsViewController: UITableViewDataSource {
    
    /*
     dataSource: numberOfSectionsInTableView
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     dataSource: numberOfRowsInSection
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceItems.count;
    }
    
    /*
     dataSource: cellForRowAtIndexPath
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // initialize the current cell and its nav item data source
        let item = dataSourceItems[indexPath.row]
        let cell = ListItemTableViewCell(style: .default, reuseIdentifier: "ListItemTableViewCell", item: item, index: indexPath.row)
        return cell
    }
    
}
