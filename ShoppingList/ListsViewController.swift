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

class ListsViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let tableViewHeight: CGFloat = 80.0
    fileprivate var tableView: UITableView!
    fileprivate var toolbar: Toolbar!
    fileprivate var dataSourceItems: Array<Entity>!
    
    var selectedRow = 0
    var longPressGesture: UILongPressGestureRecognizer!
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        
        prepareView()
        prepareToolbar()
        prepareCells()
        prepareTableView()
        prepareLongPressGesture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func prepareView() {
        view.backgroundColor = FlatMintDark()
    }
    
    fileprivate func prepareLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.6
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
                let listEntity: Entity = dataSourceItems[indexPath.row]
                let listInfo = SCGraph.getListInfo(list: listEntity)
                
                // create new alert from AddItemAlertView template
                let alert = AddItemAlertView()
                
                // add field for title
                let titleField = alert.addTextField("Title")
                titleField.autocapitalizationType = .none
                titleField.autocorrectionType = .no
                titleField.text = listInfo.title
                
                // add button with callback
                let btn = alert.addButton("Update") {
                    listEntity["title"] = titleField.text!
                    SCGraph.update()
                    self.animateUpdates()
                }
                btn.backgroundColor = FlatGreen()
                
                // add (cancel) button with callback
                _ = alert.addButton("Cancel", backgroundColor: FlatGray()) {
                    alert.hideView()
                }
                alert.showEdit("Update List", subTitle: "Update the title for this list or press cancel to cancel", colorStyle: 0x22B573, animationStyle: .leftToRight)
                
                
            }
        }
    }
    
    fileprivate func prepareToolbar() {
        
        // setup toolbar
        toolbar = Toolbar()
        toolbar.backgroundColor = UIColor.clear
        toolbar.depth = DepthPresetToValue(preset: .depth5)
        toolbar.backgroundColor = FlatBlack().withAlphaComponent(0.2)
        view.layout(toolbar).top(20).left(0).right(0)
        
        // title label
        toolbar.title = "My Lists"
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
        
        // add (cancel) button with callback
        _ = alert.addButton("Cancel", backgroundColor: FlatGray()) {
            alert.hideView()
        }
        alert.showEdit("Add a new list", subTitle: "Enter a title below for the new list", colorStyle: 0x22B573, animationStyle: .leftToRight)
    }
    
    fileprivate func addNewList(label: String) {
        let dateNow = Date()
        let newList = SCGraph.addList(title: label, date: dateNow)
        self.updateData(entity: newList)
    }
    
    fileprivate func updateData(entity: Entity) {
        self.dataSourceItems.append(entity)
        self.filterListByDate(animate: true)
    }
    
    fileprivate func filterListByDate(animate: Bool) {
        dataSourceItems.sort { (e1, e2) -> Bool in
            (e1["date"] as! Date) > (e2["date"] as! Date)
        }
        if animate {
            animateUpdates()
        }
    }
    
}

/*
 Extension: Table View Prep
 */
extension ListsViewController {
    
    fileprivate func prepareCells() {
        dataSourceItems = SCGraph.loadLists()
        filterListByDate(animate: false)
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
    
    fileprivate func animateUpdates() {
        UIView.transition(with: tableView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
        }, completion: nil)
        
    }
    
}

extension ListsViewController: UITableViewDelegate {
    
    /*
     delegate: didSelectRowAtIndexPath
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // present the selected list
        let list = dataSourceItems[indexPath.row]
        let listInfo = SCGraph.getListInfo(list: list)
        print("Item: \(listInfo.title), Date: \(listInfo.date))")
        self.present(ShoppingListViewController(list: list), animated: true, completion: nil)
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
            let list = self.dataSourceItems[index.row]
            self.dataSourceItems.remove(at: index.row)
            SCGraph.removeList(list: list)
            self.filterListByDate(animate: true)
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
        let list = dataSourceItems[indexPath.row]
        let cell = ListItemTableViewCell(style: .default, reuseIdentifier: "ListItemTableViewCell", item: list, index: indexPath.row)
        return cell
    }
    
}
