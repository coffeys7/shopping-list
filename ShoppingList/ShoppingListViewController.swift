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

class ShoppingListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let tableViewHeight: CGFloat = 80.0
    fileprivate var tableView: UITableView!
    fileprivate var dataSourceItems: Array<Entity>!
    fileprivate var toolbar: Toolbar!
    
    var longPressGesture: UILongPressGestureRecognizer!
    var selectedRow = 0
    
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
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
        dataSourceItems = SCGraph.loadItemsInList(list: self.list)
        filterListByDone(animate: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        
        prepareView()
        prepareToolbar()
        prepareTableView()
        prepareLongPressGesture()
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
        toolbar.title = list["title"] as? String
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
    
    fileprivate func prepareLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.4
        longPressGesture.allowableMovement = 15
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    @objc
    fileprivate func handleLongPress() {
        if longPressGesture.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                // provide feedback that we are entering update mode
                feedbackGenerator?.notificationOccurred(.success)
                
                // currently selected nav item
                let itemEntity: Entity = dataSourceItems[indexPath.row]
                let itemInfo = SCGraph.getListItemInfo(listItem: itemEntity)
                
                print("Label: \(itemInfo.label), SubLabel: \(itemInfo.subLabel), Annotation: \(itemInfo.annotation), done: \(itemInfo.done)")
                
                // create new alert from AddItemAlertView template
                let alert = AddItemAlertView()
                
                // add field for label
                let labelField = alert.addTextField("Item label")
                labelField.autocapitalizationType = .none
                labelField.autocorrectionType = .no
                labelField.text = itemInfo.label
                
                // add field for sub label
                let subLabelField = alert.addTextField("Sub label")
                subLabelField.autocapitalizationType = .none
                subLabelField.autocorrectionType = .no
                subLabelField.text = itemInfo.subLabel
                
                // add field for annotation
                let annotationField = alert.addTextField("Annotation")
                annotationField.autocapitalizationType = .none
                annotationField.autocorrectionType = .no
                annotationField.text = itemInfo.annotation
                
                // add button with callback
                let btn = alert.addButton("Update") {
                    itemEntity["label"] = labelField.text!
                    itemEntity["subLabel"] = subLabelField.text!
                    itemEntity["annotation"] = annotationField.text!
                    SCGraph.update()
                    self.animateUpdates()
                }
                btn.backgroundColor = FlatGreen()
                
                // add (cancel) button with callback
                _ = alert.addButton("Cancel", backgroundColor: FlatGray()) {
                    alert.hideView()
                }
                alert.showEdit("Update Item", subTitle: "Update attributes below for this item", colorStyle: 0x22B573, animationStyle: .leftToRight)
            }
        }
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
        
        // add (add) button with callback
        let btn = alert.addButton("Add Item") {
            let newItem = Entity(type: "ListItem")
            newItem["label"] = labelField.text!
            newItem["subLabel"] = subLabelField.text!
            newItem["annotation"] = annotationField.text!
            newItem["done"] = false
            SCGraph.addItemToList(list: self.list, item: newItem)
            self.dataSourceItems.append(newItem)
            self.filterListByDone(animate: true)
        }
        btn.backgroundColor = FlatGreen()
        
        // add (cancel) button with callback
        _ = alert.addButton("Cancel", backgroundColor: FlatGray()) {
            alert.hideView()
        }
        
        alert.showEdit("Add new item", subTitle: "Enter a label and quantity for the new item", colorStyle: 0x22B573, animationStyle: .leftToRight)
    }
    
    @objc
    fileprivate func handleMenuButton() {
        self.present(ListsViewController(), animated: true, completion: nil)
    }
    
    fileprivate func animateUpdates() {
        UIView.transition(with: tableView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
        }, completion: nil)

    }
    
    fileprivate func filterListByDone(animate: Bool) {
        dataSourceItems.sort { (e1, e2) -> Bool in
            (e2["done"] as! Bool) && !(e1["done"] as! Bool)
        }
        if animate {
            animateUpdates()
        }
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
        selectedRow = indexPath.row
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
            self.dataSourceItems.remove(at: index.row)
            SCGraph.removeItem(item: item)
            self.animateUpdates()
        }
        delete.backgroundColor = FlatRed()
        
        // done action
        let doneAction = UITableViewRowAction(style: .normal, title: "Done") { (action, index) in
            let item = self.dataSourceItems[index.row]
            //let cell = tableView.cellForRow(at: indexPath)
            if item["done"] as! Bool {
                item["done"] = false
                SCGraph.update()
                self.filterListByDone(animate: true)
            } else {
                item["done"] = true
                SCGraph.update()
                self.filterListByDone(animate: true)
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

