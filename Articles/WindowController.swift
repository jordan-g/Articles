//
//  WindowController.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-02-25.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSToolbarDelegate, NSSearchFieldDelegate {
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var searchBar: NSSearchField!
    @IBOutlet weak var editButton: NSButton!
    
    // Intialize variables to point to child view controllers
    var viewController: ViewController!
    var ArticlePropertiesEditorViewController: ArticlePropertiesEditorViewController!

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Set viewController
        viewController = self.contentViewController as! ViewController
        viewController.windowController = self
        
        // Hide title bar
        self.window!.titleVisibility = .hidden

        // Set toolbar & search bar's delegate to self
        toolbar.delegate = self
        searchBar.delegate = self

        // Search as the user types
        searchBar.sendsSearchStringImmediately = true
    }
    
    @IBAction func importArticle(sender: AnyObject) {
        let dialog = NSOpenPanel()
        
        dialog.allowedFileTypes = ["ris", "nbib"]
        
        dialog.beginSheetModal(for: self.window!, completionHandler: { num in
            if num == NSModalResponseOK {
                // Get URL of the chosen file
                if let result = dialog.url {
                    let path = result.path
                    
                    // Import articles from the selected file
                    self.viewController?.importArticles(path: path)
                }
            }
            
        })
    }
    
    @IBAction func deleteSelectedArticles(sender: Any?) {
        self.viewController?.articleListViewController?.deleteSelectedArticles(sender: sender)
    }
    
    @IBAction func search(sender: NSSearchField) {
        let text = sender.stringValue

        viewController?.searchFor(text: text)
    }
    
    func enableEditing(bool: Bool) {
        editButton.isEnabled = bool
    }

    func updateSelectedArticle(properties: Dictionary<String, String>) {
        viewController.updateSelectedArticle(properties: properties)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // Get references to child view controllers
        if segue.identifier == "ArticlePropertiesEditorView" {
            ArticlePropertiesEditorViewController = segue.destinationController as! ArticlePropertiesEditorViewController
            ArticlePropertiesEditorViewController.windowController = self
            ArticlePropertiesEditorViewController.article = (viewController?.selectedArticles[0])!
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ArticlePropertiesEditorView" && viewController?.selectedArticles.count == 1 {
            return true
        } else {
            return false
        }
    }
    
    @IBAction func editSelectedArticle(sender: Any?) {
        self.performSegue(withIdentifier: "ArticlePropertiesEditorView", sender: self)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.tag == 1 {
            if viewController.selectedArticles.count == 1 {
                var articleTitle = viewController.selectedArticles[0].value(forKey: "title") as! String
                if articleTitle.characters.count > 50 {
                    let substring = articleTitle.substring(to: articleTitle.index(articleTitle.startIndex, offsetBy: 50))
                    articleTitle = "\(substring)..."
                }
                menuItem.title = "Edit \"\(articleTitle)\""
                return true
            } else {
                return false
            }
        } else {
            return super.validateMenuItem(menuItem)
        }
    }
}
