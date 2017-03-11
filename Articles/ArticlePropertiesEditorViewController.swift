//
//  ArticlePropertiesEditorViewController.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-03-08.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class ArticlePropertiesEditorViewController: NSViewController {
    @IBOutlet weak var titleTextField : NSTextView!
    @IBOutlet weak var authorsTextField : NSTextView!
    @IBOutlet weak var journalTextField : NSTextField!
    @IBOutlet weak var issnTextField : NSTextField!
    @IBOutlet weak var volumeTextField : NSTextField!
    @IBOutlet weak var issueTextField : NSTextField!
    @IBOutlet weak var startPageTextField : NSTextField!
    @IBOutlet weak var endPageTextField : NSTextField!
    @IBOutlet weak var typeTextField : NSTextField!
    @IBOutlet weak var urlTextField : NSTextField!
    @IBOutlet weak var relatedRecordsTextField : NSTextField!
    @IBOutlet weak var abstractTextField : NSTextView!
    @IBOutlet weak var dateTextField : NSTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    
    var windowController : WindowController!
    var article: Article!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        authorsTextField.textContainer?.widthTracksTextView = false
        authorsTextField.textContainer?.containerSize = NSMakeSize(100000, 20)
        
        if let title = article.value(forKey: "title") as? String {
            titleTextField.string = title
        } else {
            titleTextField.string = ""
        }
        if let authors = article.value(forKey: "authors") as? String {
            authorsTextField.string = authors
        } else {
            authorsTextField.string = ""
        }
        if let journal = article.value(forKey: "journal") as? String {
            journalTextField.stringValue = journal
        } else {
            journalTextField.stringValue = ""
        }
        if let issn = article.value(forKey: "issn") as? String {
            issnTextField.stringValue = issn
        } else {
            issnTextField.stringValue = ""
        }
        if let volume = article.value(forKey: "volume") as? String {
            volumeTextField.stringValue = volume
        } else {
            volumeTextField.stringValue = ""
        }
        if let issue = article.value(forKey: "issue") as? String {
            issueTextField.stringValue = issue
        } else {
            issueTextField.stringValue = ""
        }
        if let startPage = article.value(forKey: "startPage") as? String {
            startPageTextField.stringValue = startPage
        } else {
            startPageTextField.stringValue = ""
        }
        if let endPage = article.value(forKey: "endPage") as? String {
            endPageTextField.stringValue = endPage
        } else {
            endPageTextField.stringValue = ""
        }
        if let type = article.value(forKey: "type") as? String {
            typeTextField.stringValue = type
        } else {
            typeTextField.stringValue = ""
        }
        if let url = article.value(forKey: "url") as? String {
            urlTextField.stringValue = url
        } else {
            urlTextField.stringValue = ""
        }
        if let relatedRecords = article.value(forKey: "relatedRecords") as? String {
            relatedRecordsTextField.stringValue = relatedRecords
        } else {
            relatedRecordsTextField.stringValue = ""
        }
        if let abstract = article.value(forKey: "abstract") as? String {
            abstractTextField.string = abstract
        } else {
            abstractTextField.string = ""
        }
        if let date = article.value(forKey: "date") as? String {
            dateTextField.stringValue = date
        } else {
            dateTextField.stringValue = ""
        }
    }
    
    func getPropertiesFromViews() -> Dictionary<String, String> {
        var properties: Dictionary<String, String>! = [:]
        
        properties["title"]          = titleTextField.string
        properties["authors"]        = authorsTextField.string
        properties["journal"]        = journalTextField.stringValue
        properties["issn"]           = issnTextField.stringValue
        properties["volume"]         = volumeTextField.stringValue
        properties["issue"]          = issueTextField.stringValue
        properties["startPage"]      = startPageTextField.stringValue
        properties["endPage"]        = endPageTextField.stringValue
        properties["type"]           = typeTextField.stringValue
        properties["url"]            = urlTextField.stringValue
        properties["relatedRecords"] = relatedRecordsTextField.stringValue
        properties["abstract"]       = abstractTextField.string
        properties["date"]           = dateTextField.stringValue

        return properties
    }
    
    @IBAction func accept(sender: NSButton) {
        let properties = getPropertiesFromViews()
        windowController.updateSelectedArticle(properties: properties)
        dismiss(sender)
    }
}
