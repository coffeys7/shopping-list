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

/**
 * ViewController: ShoppingListViewController
 *
 * Contains a table view with list items for the list
 * selected in the ListsViewController
 *
 * @param list: Entity - list which contains the items to display
*/
class ShoppingListViewController: UIViewController, UIGestureRecognizerDelegate {
    
    /// Height of table view cells
    let tableViewHeight: CGFloat = 80.0
    
    /// Spacing to use between rows (sections)
    fileprivate var cellSpacingHeight: CGFloat = 15.0
    
    /// List items table view
    fileprivate var tableView: UITableView!
    
    /// Graph entities for the table view to display
    fileprivate var dataSourceItems: Array<Entity>!
    
    /// The view's toolbar
    fileprivate var toolbar: Toolbar!
    
    /// Long press gesture recognizer for list editing
    var longPressGesture: UILongPressGestureRecognizer!
    
    /// Currently selected table view row
    var selectedRow = 0
    
    /// Feedback generator for haptic feedback
    var feedbackGenerator: UINotificationFeedbackGenerator?
    
    /// The list item which holds all the items
    var list: Entity!
    
    
    /**
     * name: init
     *
     * @param list Entity - list which contains the items to display
    */
    init(list: Entity) {
        self.list = list
        super.init(nibName: nil, bundle: nil)
        prepareDataSourceItemsWith(list: list)
    }
    
    /**
     * required: init
     * 
     * @param coder NSCoder - NSCoder object to decode in user defaults
    */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


/**
    Extension: Override Methods
*/
extension ShoppingListViewController {
    
    /**
     * override: viewDidLoad
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        feedbackGenerator = UINotificationFeedbackGenerator()
        
        prepareView()
        prepareToolbar()
        prepareTableView()
        prepareLongPressGesture()
    }
    
    /**
     * override: didReceiveMemoryWarning
    */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


/**
    Extension: Preparation
*/
extension ShoppingListViewController {
    
    /**
     * name: prepareDataSourceItemsWith(list:)
     *
     * @param list Entity - list which contains the data source items
    */
    fileprivate func prepareDataSourceItemsWith(list: Entity) {
        dataSourceItems = SCGraph.loadItemsInList(list: self.list)
        filterListByDone(animate: false)
    }
    
    /**
     * name: prepareView
    */
    fileprivate func prepareView() {
        view.backgroundColor = FlatBlackDark()
    }
    
    /**
     * name: prepareToolbar
    */
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
    
    /**
     * name: prepareLongPressGesture
    */
    fileprivate func prepareLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.4
        longPressGesture.allowableMovement = 15
        longPressGesture.delegate = self
        self.tableView.addGestureRecognizer(longPressGesture)
    }
    
    /**
     * name: prepareTableView
    */
    fileprivate func prepareTableView() {
        
        // positioning values
        let marginH: CGFloat = (0.025) * view.width
        
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
        view.layout(tableView).edges(top: 70, left: marginH, bottom: 10, right: marginH)
    }
    
}


/**
    Extension: Auxilliary Methods
*/
extension ShoppingListViewController {
    
    /**
     * name: animateUpdates
    */
    fileprivate func animateUpdates() {
        UIView.transition(with: tableView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
            self.tableView.reloadInputViews()
        }, completion: nil)
        
    }
    
    /**
     * name: filterListByDone
     *
     * @param animate Bool - whether or not to animate the list filtering
    */
    fileprivate func filterListByDone(animate: Bool) {
        dataSourceItems.sort { (e1, e2) -> Bool in
            (e2["done"] as! Bool) && !(e1["done"] as! Bool)
        }
        if animate {
            animateUpdates()
        }
    }
    
}


/**
    Extension: Handler Methods
*/
extension ShoppingListViewController {
    
    /**
     * name: handleMenuButton
    */
    @objc
    fileprivate func handleMenuButton() {
        self.present(ListsViewController(), animated: true, completion: nil)
    }
    
    /**
     * name: handleAddButton
    */
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
    
    /**
     * name: handleLongPress
    */
    @objc
    fileprivate func handleLongPress() {
        if longPressGesture.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGesture.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                
                // provide feedback that we are entering update mode
                feedbackGenerator?.notificationOccurred(.success)
                
                // currently selected nav item
                let itemEntity: Entity = dataSourceItems[indexPath.section]
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
    
}


/**
    Extension: TableView Delegate
*/
extension ShoppingListViewController: UITableViewDelegate {
    
    /**
     * delegate: didSelectRowAtIndexPath
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     * @param indexPath IndexPath - the index at which the row was selected
    */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.section
    }
    
    /**
     * delegate: heightForRowAtIndexPath
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     * @param indexPath IndexPath - the index at which to create the height
     *
     * @returns CGFloat - the table view height
    */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableViewHeight
    }
    
    /**
     * delegate: canEditRowAtIndexPath
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     * @param indexPath IndexPath - the index at which to edit\
     *
     * @returns Bool - whether or not this row can be edited
    */
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    /**
     * delegate: heightForHeader
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     * @param section Int - the section for which to set the header height
     *
     * @returns CGFloat - the header height for this section
    */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    /**
     * delegate: viewForHeaderInSection
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     * @param section Int - the section for which to set the view
     *
     * @returns UIView? - the view for this section
    */
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spacerView = UIView()
        spacerView.backgroundColor = UIColor.clear
        return spacerView
    }
    
    /**
     * name: editActionsForRowAt
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     * @param indexPath IndexPath - the index path for which to edit
     *
     * @returns [UITableViewRowAction]? - array of edit actions for this row
    */
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        // delete action
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (action, index) in
            let item = self.dataSourceItems[index.section]
            self.dataSourceItems.remove(at: index.section)
            SCGraph.removeItem(item: item)
            self.animateUpdates()
        }
        delete.backgroundColor = FlatRed()
        
        // done action
        let doneAction = UITableViewRowAction(style: .normal, title: "Done") { (action, index) in
            let item = self.dataSourceItems[index.section]
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

/**
    Extension: TableView DataSource
*/
extension ShoppingListViewController: UITableViewDataSource {
    
    /**
     * dataSource: numberOfSectionsInTableView
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     *
     * @returns Int - the number of sections for the table view
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSourceItems.count;
    }
    
    /**
     * dataSource: numberOfRowsInSection
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     * @param section Int - the section for which to specify the # of rows
     *
     * @returns Int - number of rows for this section
    */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    /**
     * dataSource: cellForRowAtIndexPath
     *
     * @param tableView UITableView - the table view this VC is a delegate of
     * @param indexPath IndexPath - the index for which to create the cell
     *
     * @returns UITableViewCell - created cell for the row at the specified index path
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // initialize the current cell and its nav item data source
        let item = dataSourceItems[indexPath.section]
        let cell = ItemTableViewCell(style: .default, reuseIdentifier: "ItemTableViewCell", item: item, index: indexPath.row)
        return cell
    }
    
}

