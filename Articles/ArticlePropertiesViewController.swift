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

    func updatePaperFromViews(paper : Paper) {
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

        paper.setValue(journal, forKey: "journal")
        paper.setValue(issn, forKey: "issn")
        paper.setValue(volume, forKey: "volume")
        paper.setValue(issue, forKey: "issue")
        paper.setValue(startPage, forKey: "startPage")
        paper.setValue(endPage, forKey: "endPage")
        paper.setValue(type, forKey: "type")
        paper.setValue(url, forKey: "url")
        paper.setValue(relatedRecords, forKey: "relatedRecords")
        paper.setValue(abstract, forKey: "abstract")
        paper.setValue(date, forKey: "date")
    }

    func updateViews(paper : Paper) {
        if let journal = paper.value(forKey: "journal") as? String {
            journalTextField.stringValue = journal
        } else {
            journalTextField.stringValue = ""
        }
        if let issn = paper.value(forKey: "issn") as? String {
            issnTextField.stringValue = issn
        } else {
            issnTextField.stringValue = ""
        }
        if let volume = paper.value(forKey: "volume") as? String {
            volumeTextField.stringValue = volume
        } else {
            volumeTextField.stringValue = ""
        }
        if let issue = paper.value(forKey: "issue") as? String {
            issueTextField.stringValue = issue
        } else {
            issueTextField.stringValue = ""
        }
        if let startPage = paper.value(forKey: "startPage") as? String {
            startPageTextField.stringValue = startPage
        } else {
            startPageTextField.stringValue = ""
        }
        if let endPage = paper.value(forKey: "endPage") as? String {
            endPageTextField.stringValue = endPage
        } else {
            endPageTextField.stringValue = ""
        }
        if let type = paper.value(forKey: "type") as? String {
            typeTextField.stringValue = type
        } else {
            typeTextField.stringValue = ""
        }
        if let url = paper.value(forKey: "url") as? String {
            let urlString = NSMutableAttributedString(string: url)
            urlString.addAttribute(NSLinkAttributeName, value: url, range: NSMakeRange(0, url.characters.count))
            urlString.addAttribute(NSFontAttributeName, value: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize()), range: NSMakeRange(0, url.characters.count))
            urlTextField.attributedStringValue = urlString
            
        } else {
            urlTextField.stringValue = ""
        }
        if let relatedRecords = paper.value(forKey: "relatedRecords") as? String {
            relatedRecordsTextField.stringValue = relatedRecords
        } else {
            relatedRecordsTextField.stringValue = ""
        }
        if let abstract = paper.value(forKey: "abstract") as? String {
    		abstractTextField.stringValue = abstract
    	} else {
    		abstractTextField.stringValue = ""
    	}
        if let date = paper.value(forKey: "date") as? String {
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
