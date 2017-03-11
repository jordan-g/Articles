//
//  ArticleListViewController.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-02-22.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class ArticleListViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSImageDelegate {
    @IBOutlet weak var table : NSTableView!
    @IBOutlet weak var titleLabel : NSTextField!
    @IBOutlet weak var authorsLabel : NSTextField!
    @IBOutlet weak var pdfPreview : PDFPreviewImageView!
    @IBOutlet weak var propertiesScrollView : NSScrollView!
    @IBOutlet weak var propertiesOverlayView : NSVisualEffectView!

    weak var mainController: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.

        // Allow dragging from the article list table
        self.table.setDraggingSourceOperationMask(NSDragOperation.link, forLocal: false)
        self.table.setDraggingSourceOperationMask(NSDragOperation.move, forLocal: true)
        self.table.register(forDraggedTypes: [NSStringPboardType])

        // become pdfPreview's delegate
        pdfPreview.delegate = self
        
        // Set background color of PDF Preview image well
        pdfPreview.layer?.backgroundColor = CGColor.white
    }

    func updatePDFPreview(article : Article) {
        // Update PDF Preview image
        pdfPreview.layer?.backgroundColor = CGColor.white
        
        if let pdfLocation = article.value(forKey: "pdfLocation") as? String {
            pdfPreview.image = NSImage(byReferencingFile: NSString(string: pdfLocation).expandingTildeInPath as String)
        } else {
            pdfPreview.image = nil
        }
    }

    func updatePDFLocation(pdfLocation : String) {
        mainController.updatePDFLocation(pdfLocation: pdfLocation)
    }

    func refreshTable() {
    	table.reloadData()
    }
    
    func clearViews() {
        titleLabel.stringValue   = ""
        authorsLabel.stringValue = ""
        pdfPreview.image         = nil

        ArticlePropertiesViewController?.clearViews()
    }

    func updateViews(article : Article) {
        if let title = article.value(forKey: "title") as? String {
            titleLabel.stringValue = title
        } else {
            titleLabel.stringValue = ""
        }
        
        if let authors = article.value(forKey: "authors") as? String {
            authorsLabel.stringValue = authors
        } else {
            authorsLabel.stringValue = ""
        }

    	updatePDFPreview(article: article)
        ArticlePropertiesViewController?.updateViews(article: article)
    }

    func updateArticleFromViews(article : Article) {
    	ArticlePropertiesViewController?.updateArticleFromViews(article: article)
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        // Get selected rows
        let indexes = table.selectedRowIndexes

        mainController.articlesSelected(indexes: indexes)
    }
    
    func numberOfRows(in: NSTableView) -> Int {
        return mainController.filteredArticleData.count
    }
    
    func selectArticles(indexes: IndexSet) {
        table.selectRowIndexes(indexes, byExtendingSelection: false)
    }
    
    func tableView(_ tableView: NSTableView, viewFor: NSTableColumn?, row: Int) -> NSView? {
        let tableColumn = viewFor
        
        let result = tableView.make(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        // Get the corresponding article for this row
        let article = mainController.filteredArticleData[row]
    
        if let val = article.value(forKey: tableColumn!.identifier) as? String {
            result.textField?.stringValue = val
        } else {
            result.textField?.stringValue = ""
        }
        return result
    }

    @IBAction func importArticle(sender: AnyObject) {
        let dialog = NSOpenPanel()
        
        dialog.allowedFileTypes = ["ris", "nbib"]
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                let path = result!.path

                mainController.importArticles(path: path)
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }

    func updateSelectedArticle(sender: AnyObject) {
    	mainController.updateSelectedArticle()
    }

    func deleteSelectedArticles(sender: Any?) {
        let indexes = table.selectedRowIndexes
    	mainController.deleteSelectedArticles(indexes: indexes)
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
        return false
    }

    var ArticlePropertiesViewController: ArticlePropertiesViewController?

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // Get references to child view controllers
        if segue.identifier == "ArticlePropertiesView" {
            ArticlePropertiesViewController = segue.destinationController as? ArticlePropertiesViewController
            ArticlePropertiesViewController?.mainController = self.mainController
            ArticlePropertiesViewController?.articleListViewController = self
            ArticlePropertiesViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        }
    }
}
