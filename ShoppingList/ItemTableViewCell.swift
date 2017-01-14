/**
 *
 * @file    QuestionTableViewCell.swift
 *
 * @author  Sam B. Coffey
 *
 * @desc    Base class for a table view cell with question component
 *
 */

import UIKit
import Material
import Spring
import FontAwesome_swift
import ChameleonFramework
import Graph

class ItemTableViewCell: TableViewCell {
    
    var itemLabel: UILabel!
    var quantLabel: UILabel!
    var subLabel: UILabel!
    var item: Entity!
    var index: Int!
    
    /*
     name: init
     */
    init(style: UITableViewCellStyle, reuseIdentifier: String!, item: Entity, index: Int) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.item = item
        self.index = index
        self.contentView.clipsToBounds = true
        if item["done"] as! Bool {
            self.backgroundColor = FlatGray().withAlphaComponent(0.75)
        } else {
            self.backgroundColor = UIColor.clear
        }
        self.pulseAnimation = .none
        self.prepareItemLabel()
        self.prepareSubLabel()
        self.prepareAnnotationLabel()
    }
    
    /*
     required: init
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     name: prepareTextField
     */
    fileprivate func prepareItemLabel() {
        
        // normal text properties
        itemLabel = UILabel()
        itemLabel.textColor = FlatWhite()
        itemLabel.textAlignment = .left
        itemLabel.font = RobotoFont.medium(with: 14)
        itemLabel.text = self.item["label"] as? String
        
        // layout
        layout(itemLabel).left(30).top(21)
    }
    
    /*
        name: prepareSubLabel
    */
    fileprivate func prepareSubLabel() {
        
        // normal text properties
        subLabel = UILabel()
        subLabel.textColor = FlatWhite()
        subLabel.textAlignment = .left
        subLabel.font = RobotoFont.light(with: 12)
        subLabel.text = self.item["subLabel"] as? String
        
        // layout
        layout(subLabel).left(30).bottom(22)
    }
    
    /*
     name: prepareAnnotationLabel
     */
    fileprivate func prepareAnnotationLabel() {
        
        // normal text properties
        quantLabel = UILabel()
        quantLabel.textColor = FlatWhite().withAlphaComponent(0.7)
        quantLabel.textAlignment = .right
        quantLabel.font = RobotoFont.thin(with: 12)
        quantLabel.text = self.item["annotation"] as? String
        
        // layout
        layout(quantLabel).right(30).centerVertically()
    }
    
}
