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


class ListItemTableViewCell: TableViewCell {
    
    var listTitleLabel: UILabel!
    var listDateLabel: UILabel!
    var item: ListItem!
    var index: Int!
    
    /*
     name: init
     */
    init(style: UITableViewCellStyle, reuseIdentifier: String!, item: ListItem, index: Int) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.item = item
        self.index = index
        self.contentView.clipsToBounds = true
        self.backgroundColor = FlatBlack().withAlphaComponent(0.5)
        self.depth = DepthPresetToValue(preset: .depth5)
        self.pulseAnimation = .backing
        self.prepareItemLabel()
        self.prepareQuantLabel()
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
        listTitleLabel = UILabel()
        listTitleLabel.textColor = FlatWhite()
        listTitleLabel.textAlignment = .left
        listTitleLabel.font = RobotoFont.medium(with: 14)
        listTitleLabel.text = self.item.title
        
        // layout
        layout(listTitleLabel).left(30).centerVertically()
    }
    
    /*
     name: prepareQuantLabel
     */
    fileprivate func prepareQuantLabel() {
        
        // normal text properties
        listDateLabel = UILabel()
        listDateLabel.textColor = FlatWhite().withAlphaComponent(0.7)
        listDateLabel.textAlignment = .right
        listDateLabel.font = RobotoFont.light(with: 12)
        listDateLabel.text = self.item.dateString()
        
        // layout
        layout(listDateLabel).right(30).centerVertically()
    }
    
}
