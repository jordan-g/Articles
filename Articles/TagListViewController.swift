//
//  TagListViewController.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-02-23.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class TagListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSImageDelegate {
    @IBOutlet weak var table : NSTableView!
    
    weak var mainController: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.table.setDraggingSourceOperationMask(NSDragOperation.link, forLocal: false)
        self.table.setDraggingSourceOperationMask(NSDragOperation.move, forLocal: true)
        self.table.register(forDraggedTypes: [NSStringPboardType])
    }
    
    func refreshTable() {
        table.reloadData()
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // Which rows were selected?
        let indexes = table.selectedRowIndexes
        
        mainController.tagsSelected(indexes: indexes)
    }
    
    func numberOfRows(in: NSTableView) -> Int {
        // how many rows are needed to display the data?
        return mainController.tagData.count + 1
    }
    
    func tableView(_ tableView: NSTableView, viewFor: NSTableColumn?, row: Int) -> NSView? {
        // get an NSTableCellView with an identifier that is the same as the identifier for the column
        // NOTE: you need to set the identifier of both the Column and the Table Cell View
        // in this case the columns are "name" and "value"
        let tableColumn = viewFor
        
        let result = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        // get the "Item" for the row
        if row == 0 {
            if tableColumn!.identifier == "name" {
                result.textField?.stringValue = "All"
                
                let numArticles = mainController.articleData.count
                
                let countLabel = result.viewWithTag(1) as! NSTextField
                countLabel.stringValue = String(numArticles)
            }
            result.textField?.isEditable = false
        } else {
            let tag = mainController.tagData[row-1]
            
            if tableColumn!.identifier == "name" {
                if let val = tag.value(forKey: tableColumn!.identifier) as? String {
                    result.textField?.stringValue = val
                } else {
                    // if the attribute's value is missing enter a blank string
                    result.textField?.stringValue = ""
                }
                
                if let numArticles = tag.article?.count {
                    let countLabel = result.viewWithTag(1) as! NSTextField
                    countLabel.stringValue = String(numArticles)
//                    result.textField?.stringValue = String(numArticles)
                } else {
                    let countLabel = result.viewWithTag(1) as! NSTextField
                    countLabel.stringValue = String("0")
//                    result.textField?.stringValue = "0"
                }
            }
        }
        if row == tableView.selectedRow {
            let countLabel = result.viewWithTag(1) as! NSTextField
            countLabel.textColor = NSColor.white
        }
        return result
    }
    
    @IBAction func addTag(sender: AnyObject) {
        mainController.addTag()
        
        let lastCell = table.view(atColumn: 0, row: mainController.tagData.count, makeIfNecessary: true) as! NSTableCellView
        
        lastCell.textField?.becomeFirstResponder()
    }
    
    @IBAction func deleteSelectedTag(sender: AnyObject) {
        let indexes = table.selectedRowIndexes
        mainController.deleteSelectedTags(indexes: indexes)
    }
    
    @IBAction func tagNameEdited(sender: NSTextField) {
        Swift.print("hello")
        let index = table.selectedRow - 1
        Swift.print(index)
        if index != -1 {
            mainController.editTagName(index: index, name: sender.stringValue)
        }
    }
    
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        let data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
        pboard.declareTypes([NSStringPboardType], owner: self)
        pboard.setData(data, forType: NSStringPboardType)
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        return NSDragOperation.every
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let data = info.draggingPasteboard().data(forType: NSStringPboardType)
        let indexes = NSKeyedUnarchiver.unarchiveObject(with: data!) as! NSIndexSet
        
        if info.draggingSource() as! NSTableView != tableView {
            let tag = mainController.tagData[row-1]
            
            for index in indexes {
                let article = mainController.filteredArticleData[index]
                tag.addToArticle(article)
            }
        }
        
        refreshTable()
        
        return true
    }

}
