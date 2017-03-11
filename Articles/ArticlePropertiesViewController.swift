//
//  ArticlePropertiesViewController.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-02-24.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class ArticlePropertiesViewController: NSViewController {
    @IBOutlet weak var journalTextField: NSTextField!
    @IBOutlet weak var issnTextField: NSTextField!
    @IBOutlet weak var volumeTextField: NSTextField!
    @IBOutlet weak var issueTextField: NSTextField!
    @IBOutlet weak var startPageTextField: NSTextField!
    @IBOutlet weak var endPageTextField: NSTextField!
    @IBOutlet weak var typeTextField: NSTextField!
    @IBOutlet weak var urlTextField: URLTextField!
    @IBOutlet weak var relatedRecordsTextField: NSTextField!
    @IBOutlet weak var abstractTextField: NSTextField!
    @IBOutlet weak var dateTextField: NSTextField!

    weak var mainController: ViewController!
    weak var articleListViewController: ArticleListViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        urlTextField.allowsEditingTextAttributes = true
        urlTextField.isSelectable = true
    }
    
    var _needsToScrollToTop : Bool = true

    func clearViews() {
        journalTextField?.stringValue        = ""
        issnTextField?.stringValue           = ""
        volumeTextField?.stringValue         = ""
        issueTextField?.stringValue          = ""
        startPageTextField?.stringValue      = ""
        endPageTextField?.stringValue        = ""
        typeTextField?.stringValue           = ""
        urlTextField?.stringValue            = ""
        relatedRecordsTextField?.stringValue = ""
        abstractTextField?.stringValue       = ""
        dateTextField?.stringValue           = ""
    }

    func updateArticleFromViews(article : Article) {
        let journal        = journalTextField.stringValue
        let issn           = issnTextField.stringValue
        let volume         = volumeTextField.stringValue
        let issue          = issueTextField.stringValue
        let startPage      = startPageTextField.stringValue
        let endPage        = endPageTextField.stringValue
        let type           = typeTextField.stringValue
        let url            = urlTextField.stringValue
        let relatedRecords = relatedRecordsTextField.stringValue
        let abstract       = abstractTextField.stringValue
        let date           = dateTextField.stringValue

        article.setValue(journal, forKey: "journal")
        article.setValue(issn, forKey: "issn")
        article.setValue(volume, forKey: "volume")
        article.setValue(issue, forKey: "issue")
        article.setValue(startPage, forKey: "startPage")
        article.setValue(endPage, forKey: "endPage")
        article.setValue(type, forKey: "type")
        article.setValue(url, forKey: "url")
        article.setValue(relatedRecords, forKey: "relatedRecords")
        article.setValue(abstract, forKey: "abstract")
        article.setValue(date, forKey: "date")
    }

    func updateViews(article : Article) {
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
            let urlString = NSMutableAttributedString(string: url)
            urlString.addAttribute(NSLinkAttributeName, value: url, range: NSMakeRange(0, url.characters.count))
            urlString.addAttribute(NSFontAttributeName, value: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize()), range: NSMakeRange(0, url.characters.count))
            urlTextField.attributedStringValue = urlString
            
        } else {
            urlTextField.stringValue = ""
        }
        if let relatedRecords = article.value(forKey: "relatedRecords") as? String {
            relatedRecordsTextField.stringValue = relatedRecords
        } else {
            relatedRecordsTextField.stringValue = ""
        }
        if let abstract = article.value(forKey: "abstract") as? String {
    		abstractTextField.stringValue = abstract
    	} else {
    		abstractTextField.stringValue = ""
    	}
        if let date = article.value(forKey: "date") as? String {
            dateTextField.stringValue = date
        } else {
            dateTextField.stringValue = ""
        }
        
        _needsToScrollToTop = true
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        if _needsToScrollToTop {
            let pt = NSMakePoint(0.0, view.frame.size.height)
            view.enclosingScrollView?.documentView?.scroll(pt)
            _needsToScrollToTop = false
        }
    }
}
