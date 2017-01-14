//
//  ViewController.swift
//  ShoppingList
//
//  Created by Sam Coffey on 1/11/17.
//  Copyright © 2017 coffey. All rights reserved.
//

import UIKit
import Material
import ChameleonFramework
import Graph

class ShoppingListViewController: UIViewController {
    
    let tableViewHeight: CGFloat = 80.0
    fileprivate var tableView: UITableView!
    fileprivate var dataSourceItems: Array<ShoppingItem>!
    fileprivate var toolbar: Toolbar!
    
    var list: Entity!
    
    init(list: Entity) {
        self.list = list
        super.init(nibName: nil, bundle: nil)
        prepareDataSourceItemsWith(list: list)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func prepareDataSourceItemsWith(list: Entity) {
        dataSourceItems = Array<ShoppingItem>()
        let items = list.relationship(types: "Item").object(types: "ShoppingItem")
        for item in items {
            let label = item["label"] as! String
            let annotation = item["annotation"] as! String
            let subLabel = item["subLabel"] as! String
            let done = item["done"] as! Bool
            let newItem = ShoppingItem(label: label, subLabel: subLabel, annotation: annotation, done: done)
            newItem.itemEntity = item
            dataSourceItems.append(newItem)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareView()
        prepareToolbar()
        prepareTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func prepareView() {
        view.backgroundColor = FlatBlue()
    }
    
    fileprivate func prepareToolbar() {
        
        // setup toolbar
        toolbar = Toolbar()
        toolbar.backgroundColor = UIColor.clear
        toolbar.depth = DepthPresetToValue(preset: .depth5)
        toolbar.backgroundColor = FlatBlack().withAlphaComponent(0.2)
        view.layout(toolbar).top(20).left(0).right(0)
        
        // title label
        toolbar.title = list["title"] as! String
        toolbar.titleLabel.textColor = FlatWhite()
        
        // left (menu) button
        let menuButton = IconButton()
        menuButton.image = Icon.menu?.tint(with: FlatWhite())
        menuButton.addTarget(self, action: #selector(handleMenuButton), for: .touchUpInside)
        
        // right (add) button
        let addButton = IconButton()
        addButton.image = Icon.addCircle?.tint(with: FlatWhite())
        addButton.addTarget(self, action: #selector(handleAddButton), for: .touchUpInside)
        
        // layout
        toolbar.leftViews = [menuButton]
        toolbar.rightViews = [addButton]
    }
    
    @objc
    fileprivate func handleAddButton() {
        
        // create new alert from AddItemAlertView template
        let alert = AddItemAlertView()
        
        // add field for label
        let labelField = alert.addTextField("Item label")
        labelField.autocapitalizationType = .none
        labelField.autocorrectionType = .no
        
        // add field for sub label
        let subLabelField = alert.addTextField("Sub label")
        subLabelField.autocapitalizationType = .none
        subLabelField.autocorrectionType = .no
        
        // add field for annotation
        let annotationField = alert.addTextField("Annotation")
        annotationField.autocapitalizationType = .none
        annotationField.autocorrectionType = .no
        
        // add button with callback
        let btn = alert.addButton("Add Item") {
            let label = labelField.text!
            let subLabel = subLabelField.text!
            let annotationLabel = annotationField.text!
            self.addNewItem(label: label, subLabel: subLabel, annotation: annotationLabel)
        }
        btn.backgroundColor = FlatGreen()
        alert.showEdit("Add new item", subTitle: "Enter a label and quantity for the new item", colorStyle: 0x22B573, animationStyle: .leftToRight)
    }
    
    fileprivate func addNewItem(label: String, subLabel: String, annotation: String) {
        let newItem = SCGraph.addItemToList(list: list, label: label, subLabel: subLabel, annotation: annotation, done: false)
        updateData(label: label, subLabel: subLabel, annotation: annotation, item: newItem)
    }
    
    fileprivate func updateData(label: String, subLabel: String, annotation: String, item: Entity) {
        let newItem = ShoppingItem(label: label, subLabel: subLabel, annotation: annotation, done: false)
        newItem.itemEntity = item
        dataSourceItems.append(newItem)
        tableView.reloadData()
        tableView.reloadInputViews()
    }
    
    @objc
    fileprivate func handleMenuButton() {
        self.present(ListsViewController(), animated: true, completion: nil)
    }

}

/*
    Extension: Table View Prep
*/
extension ShoppingListViewController {
    
    fileprivate func prepareTableView() {
        
        // initialize and customize the table view
        tableView = UITableView()
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: "ItemTableViewCell")
        tableView.backgroundColor = UIColor.clear
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = FlatWhite().withAlphaComponent(0.25)
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        
        // layout the table view
        view.layout(tableView).edges(top: 70, bottom: 10)
    }
    
}

extension ShoppingListViewController: UITableViewDelegate {
    
    /*
     delegate: didSelectRowAtIndexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // currently selected nav item
        let item: ShoppingItem = dataSourceItems[(indexPath as NSIndexPath).row]
        let entity = item.itemEntity
        
        // create new alert from AddItemAlertView template
        let alert = AddItemAlertView()
        
        // add field for label
        let labelField = alert.addTextField("Item label")
        labelField.autocapitalizationType = .none
        labelField.autocorrectionType = .no
        labelField.text = item.label
        
        // add field for sub label
        let subLabelField = alert.addTextField("Sub label")
        subLabelField.autocapitalizationType = .none
        subLabelField.autocorrectionType = .no
        subLabelField.text = item.subLabel
        
        // add field for annotation
        let annotationField = alert.addTextField("Annotation")
        annotationField.autocapitalizationType = .none
        annotationField.autocorrectionType = .no
        annotationField.text = item.annotation
        
        // add button with callback
        let btn = alert.addButton("Update") {
            let label = labelField.text!
            let subLabel = subLabelField.text!
            let annotationLabel = annotationField.text!
            entity?["label"] = label
            entity?["subLabel"] = subLabel
            entity?["annotation"] = annotationLabel
            item.label = label
            item.subLabel = subLabel
            item.annotation = annotationLabel
            tableView.reloadData()
            tableView.reloadInputViews()
        }
        btn.backgroundColor = FlatGreen()
        alert.showEdit("Update Item", subTitle: "Update attributes below for this item", colorStyle: 0x22B573, animationStyle: .leftToRight)
        
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
        
        // delete action
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, index) in
            let item = self.dataSourceItems[index.row]
            SCGraph.removeItem(item: item.itemEntity)
            self.dataSourceItems.remove(at: index.row)
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
        }
        delete.backgroundColor = FlatRed()
        
        // done action
        let doneAction = UITableViewRowAction(style: .normal, title: "Done") { (action, index) in
            let item = self.dataSourceItems[index.row]
            let entity = item.itemEntity
            let done  = item.done
            //let cell = tableView.cellForRow(at: indexPath)
            if done {
                item.done = false
                entity?["done"] = false
                self.tableView.reloadData()
                self.tableView.reloadInputViews()
            } else {
                item.done = true
                entity?["done"] = true
                self.tableView.reloadData()
                self.tableView.reloadInputViews()
            }
        }
        doneAction.backgroundColor = FlatGreen()
        return [delete, doneAction]
    }
    
}

extension ShoppingListViewController: UITableViewDataSource {
    
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
        let cell = ItemTableViewCell(style: .default, reuseIdentifier: "ItemTableViewCell", item: item, index: indexPath.row)
        return cell
    }
    
}

