//
//  Utilities.swift
//  ShoppingList
//
//  Created by Sam Coffey on 1/12/17.
//  Copyright © 2017 coffey. All rights reserved.
//

import Foundation
import Graph
import SCLAlertView
import Material

public enum SCInterval {
    case minute
    case hour
    case day
    case week
    case month
    case year
}

public func AddItemAlertView() -> SCLAlertView {
    let appearance = SCLAlertView.SCLAppearance.init(
        kWindowWidth: Screen.width - 40,
        kWindowHeight: Screen.height/4,
        kTitleFont: RobotoFont.medium,
        kTextFont: RobotoFont.regular,
        kButtonFont: RobotoFont.regular,
        showCloseButton: false,
        showCircularIcon: false
    )
    let alertView = SCLAlertView(appearance: appearance)
    return alertView
}

public func intervalFor(interval: SCInterval, times: Double) -> TimeInterval {
    let minute: Double = 60.0
    switch interval {
    case .minute:
        return TimeInterval(exactly: minute*times)!
    case .hour:
        return TimeInterval(exactly: minute*minute*times)!
    case .day:
        return TimeInterval(exactly: minute*minute*24.0*times)!
    case .week:
        return TimeInterval(exactly: minute*minute*24.0*7.0*times)!
    case .month:
        return TimeInterval(exactly: minute*minute*24.0*30.0*times)!
    case .year:
        return TimeInterval(exactly: minute*minute*24.0*365.0*times)!
    }
}

struct SCGraph {
 
    static func addList(title: String, date: Date) -> Entity {
        let graph = Graph()
        let newList = Entity(type: "ListItem")
        newList["title"] = title
        newList["date"] = date
        graph.sync()
        return newList
    }
    
    static func addItemToList(list: Entity, label: String, subLabel: String, annotation: String, done: Bool) -> Entity {
        let graph = Graph()
        let newItem = Entity(type: "ShoppingItem")
        newItem["label"] = label
        newItem["annotation"] = annotation
        newItem["subLabel"] = subLabel
        newItem["done"] = done
        newItem.is(relationship: "Item").in(object: list)
        graph.sync()
        return newItem
    }
    
    static func removeItem(item: Entity) {
        let graph = Graph()
        item.delete()
        graph.sync()
    }
    
    static func removeList(list: Entity) {
        let graph = Graph()
        let items = list.relationship(types: "Item").object(types: "ShoppingItem")
        for item in items {
            item.delete()
        }
        list.delete()
        graph.sync()
    }
}

struct SampleData {
    
    public static func createSampleData() {
        
        let graph = Graph()
        graph.clear()
        
        // create lists
        
        // list one
        let l1 = Entity(type: "ListItem")
        l1["title"] = "List One"
        l1["date"] = Date()
        
        // list two
        let l2 = Entity(type: "ListItem")
        l2["title"] = "List Two"
        l2["date"] = Date().addingTimeInterval(intervalFor(interval: .day, times: 1))
        
        // list three
        let l3 = Entity(type: "ListItem")
        l3["title"] = "List Three"
        l3["date"] = Date().addingTimeInterval(intervalFor(interval: .week, times: 1))
        
        // list four
        let l4 = Entity(type: "ListItem")
        l4["title"] = "List Four"
        l4["date"] = Date().addingTimeInterval(intervalFor(interval: .month, times: 1))
        
        let item1 = Entity(type: "ShoppingItem")
        item1["label"] = "Milk"
        item1["qty"] = 1
        
        let item2 = Entity(type: "ShoppingItem")
        item2["label"] = "Eggs"
        item2["qty"] = 12
        
        let item3 = Entity(type: "ShoppingItem")
        item3["label"] = "Coffee"
        item3["qty"] = 1
        
        let item4 = Entity(type: "ShoppingItem")
        item4["label"] = "Cheese"
        item4["qty"] = 1
        
        let item5 = Entity(type: "ShoppingItem")
        item5["label"] = "Bread"
        item5["qty"] = 1
        
        let item6 = Entity(type: "ShoppingItem")
        item6["label"] = "Cereal"
        item6["qty"] = 1
        
        let item7 = Entity(type: "ShoppingItem")
        item7["label"] = "Water"
        item7["qty"] = 24
        
        let item8 = Entity(type: "ShoppingItem")
        item8["label"] = "Beer"
        item8["qty"] = 12
        
        let item9 = Entity(type: "ShoppingItem")
        item9["label"] = "Pencils"
        item9["qty"] = 20
        
        let item10 = Entity(type: "ShoppingItem")
        item10["label"] = "Crackers"
        item10["qty"] = 1
        
        // add all items to list one
        item1.is(relationship: "Item").in(object: l1)
        item2.is(relationship: "Item").in(object: l1)
        item3.is(relationship: "Item").in(object: l1)
        item4.is(relationship: "Item").in(object: l1)
        item5.is(relationship: "Item").in(object: l1)
        item6.is(relationship: "Item").in(object: l1)
        
        // add all items to list two
        item1.is(relationship: "Item").in(object: l2)
        item2.is(relationship: "Item").in(object: l2)
        item3.is(relationship: "Item").in(object: l2)
        item4.is(relationship: "Item").in(object: l2)
        item5.is(relationship: "Item").in(object: l2)
        item6.is(relationship: "Item").in(object: l2)
        item7.is(relationship: "Item").in(object: l2)
        item8.is(relationship: "Item").in(object: l2)
        item9.is(relationship: "Item").in(object: l2)
        item10.is(relationship: "Item").in(object: l2)
        
        // add all items to list three
        item1.is(relationship: "Item").in(object: l3)
        item2.is(relationship: "Item").in(object: l3)
        
        // add all items to list four
        item1.is(relationship: "Item").in(object: l4)
        item2.is(relationship: "Item").in(object: l4)
        item3.is(relationship: "Item").in(object: l4)
        item4.is(relationship: "Item").in(object: l4)
        
        graph.sync()
    }
    
}


