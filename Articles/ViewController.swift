//
//  ViewController.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-02-12.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var tagList : NSOutlineView!
    
    var referenceReader : ReferenceReader!
    var documentsURL : URL!
    var fileManager : FileManager!
    
    weak var windowController: WindowController!

    func importPapers(path : String) {
        let fileExtension = (path as NSString).pathExtension
        
        referenceReader = ReferenceReader()
        var title, authors, journal, abstract, issn, volume, issue, startPage, endPage, type, url, relatedRecords, date : String
        var paperPropertyDicts: [Dictionary<String, String>] = []
        
        if (fileExtension == "ris") {
            paperPropertyDicts = referenceReader.readRISFile(path: path)
            
        } else if (fileExtension == "nbib") {
            (title, authors, journal, abstract, issn, volume,
                issue, startPage, endPage, type, url, relatedRecords, date) = referenceReader.readNBIBFile(path: path)
        } else {
            return
        }

        let pdfLocation = ""
        
        for paperPropertyDict in paperPropertyDicts {
            let id = ProcessInfo.processInfo.globallyUniqueString
            
            let filename = id + "." + fileExtension
            
            let newLocation = documentsURL.appendingPathComponent(filename).path
            
            if fileManager.fileExists(atPath: newLocation) {
                try! fileManager.removeItem(atPath: newLocation)
            }
            
            try! fileManager.copyItem(atPath: path, toPath: newLocation)
            
            title          = paperPropertyDict["title"]!
            authors        = paperPropertyDict["authors"]!
            journal        = paperPropertyDict["journal"]!
            abstract       = paperPropertyDict["abstract"]!
            issn           = paperPropertyDict["issn"]!
            volume         = paperPropertyDict["volume"]!
            issue          = paperPropertyDict["issue"]!
            startPage      = paperPropertyDict["startPage"]!
            endPage        = paperPropertyDict["endPage"]!
            type           = paperPropertyDict["type"]!
            url            = paperPropertyDict["url"]!
            relatedRecords = paperPropertyDict["relatedRecords"]!
            date           = paperPropertyDict["date"]!

            let fetch = NSFetchRequest<Paper>(entityName: "Paper")
            let predicate = NSPredicate(format: "title == %@", title)
            fetch.predicate = predicate
            
            let result : Array? = try! managedContext.fetch(fetch)
            
            if (result?.isEmpty)! {
                addPaper(title: title, authors: authors, journal: journal, pdfLocation: pdfLocation, abstract: abstract, id: id,
                         issn: issn, volume: volume, issue: issue, startPage: startPage, endPage: endPage, type: type, url: url,
                         relatedRecords: relatedRecords, date: date)
            }
        }
    }

    func addPaper(title: String?, authors: String?, journal: String?, pdfLocation: String?, abstract: String?, id: String?,
                  issn: String?, volume: String?, issue: String?, startPage: String?, endPage: String?, type: String?,
                  url: String?, relatedRecords: String?, date: String?) {
        // get the entity from the Core Data model called "Item"
        let entity = NSEntityDescription.entity(forEntityName:"Paper", in: managedContext)
        // insert a new "Item"
        let paper = Paper(entity: entity!, insertInto: managedContext)
        
        // set the values of the "name" and "value" attribute
        paper.setValue(title, forKey: "title")
        paper.setValue(authors, forKey: "authors")
        paper.setValue(journal, forKey: "journal")
        paper.setValue(pdfLocation, forKey: "pdfLocation")
        paper.setValue(abstract, forKey: "abstract")
        paper.setValue(issn, forKey: "issn")
        paper.setValue(volume, forKey: "volume")
        paper.setValue(issue, forKey: "issue")
        paper.setValue(startPage, forKey: "startPage")
        paper.setValue(endPage, forKey: "endPage")
        paper.setValue(type, forKey: "type")
        paper.setValue(url, forKey: "url")
        paper.setValue(relatedRecords, forKey: "relatedRecords")
        paper.setValue(date, forKey: "date")
        paper.setValue(id, forKey: "id")
        
        do {
            // save the data
            try managedContext.save()
            //refresh the table with the updated data
            fetchDataAndRefreshTable()

            articleListViewController?.updateViews(paper: paper)
            tagListViewController?.refreshTable()
        } catch {
            Swift.print(error)
        }
    }

    func updateSelectedPaper() {
        if selectedPapers.count == 1 {
            articleListViewController?.updatePaperFromViews(paper: selectedPapers[0])
            do {
                // save the data
                try managedContext.save()

                // refresh the table with the updated data
                fetchDataAndRefreshTable()
            } catch {
                Swift.print(error)
            }
        }
    }

    func updateSelectedPaper(properties: Dictionary<String, String>) {
        if selectedPapers.count == 1 {
            let paper = selectedPapers[0]

            do {
                paper.setValue(properties["title"], forKey: "title")
                paper.setValue(properties["authors"], forKey: "authors")
                paper.setValue(properties["journal"], forKey: "journal")
                paper.setValue(properties["pdfLocation"], forKey: "pdfLocation")
                paper.setValue(properties["abstract"], forKey: "abstract")
                paper.setValue(properties["issn"], forKey: "issn")
                paper.setValue(properties["volume"], forKey: "volume")
                paper.setValue(properties["issue"], forKey: "issue")
                paper.setValue(properties["startPage"], forKey: "startPage")
                paper.setValue(properties["endPage"], forKey: "endPage")
                paper.setValue(properties["type"], forKey: "type")
                paper.setValue(properties["url"], forKey: "url")
                paper.setValue(properties["relatedRecords"], forKey: "relatedRecords")
                paper.setValue(properties["date"], forKey: "date")
                paper.setValue(properties["id"], forKey: "id")
                
                do {
                    // save the data
                    try managedContext.save()
                    //refresh the table with the updated data
                    fetchDataAndRefreshTable()
                    
                    articleListViewController?.updateViews(paper: paper)
                    tagListViewController?.refreshTable()
                } catch {
                    Swift.print(error)
                }
            }
        }
    }

    func deleteSelectedPapers(indexes: IndexSet) {
        for index in indexes.sorted().reversed() {
            print("Deleting paper at index", index)
            let paper = paperData[index]
            managedContext.delete(paper)
        }
        do {
            // save the data
            try managedContext.save()
            
            // refresh the table with the updated data
            selectedPapers = []
            fetchDataAndRefreshTable()
            fetchTagData()
            
            articleListViewController?.clearViews()
            pdfViewController?.clearPDFView()
        } catch {
            Swift.print(error)
        }
    }
    
    // an array to hold the data
    var paperData = [Paper]()
    var filteredPaperData = [Paper]()
    var tagData = [Tag]()
    
    // a selected item
    var selectedPapers : [Paper] = []
    var selectedTags : [Tag] = []
    
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()

    func fetchDataAndRefreshTable() {
        // create a fetch request that retrieves all items from the "Item" entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paper")
        let filteredFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paper")
        if selectedTags.count != 0 {
            var predicates : [NSPredicate] = []
            for tag in selectedTags {
                let predicate = NSPredicate(format: "ANY tag == %@", tag)
                predicates.append(predicate)
            }
            filteredFetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
        do {
            paperData = try managedContext.fetch(fetchRequest) as! [Paper]
            // retrieve the data
            filteredPaperData = try managedContext.fetch(filteredFetchRequest) as! [Paper]
            // reload the table
            articleListViewController?.refreshTable()
        } catch {
            Swift.print(error)
        }
    }
    
    func searchFor(text: String) {
        // create a fetch request that retrieves all items from the "Item" entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paper")
        let filteredFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paper")
        if selectedTags.count != 0 {
            var predicates : [NSPredicate] = []
            for tag in selectedTags {
                let predicate = NSPredicate(format: "ANY tag == %@", tag)
                predicates.append(predicate)
            }
            filteredFetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
        
        // If we are searching for anything...
        if text.characters.count > 0 {
            // Define how we want our entities to be filtered
            let searchPredicate = NSPredicate(format: "(title CONTAINS[c] %@) OR (authors CONTAINS[c] %@) OR (journal CONTAINS[c] %@)", text, text, text)
            
            if (filteredFetchRequest.predicate != nil) {
                filteredFetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filteredFetchRequest.predicate!, searchPredicate])
            } else {
                filteredFetchRequest.predicate = searchPredicate
            }
        }
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            paperData = try managedContext.fetch(fetchRequest) as! [Paper]
            // retrieve the data
            filteredPaperData = try managedContext.fetch(filteredFetchRequest) as! [Paper]
            // reload the table
            articleListViewController?.refreshTable()
        } catch {
            Swift.print(error)
        }
    }
    
    func fetchTagData() {
        // create a fetch request that retrieves all items from the "Item" entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        do {
            // retrieve the data
            tagData = try managedContext.fetch(fetchRequest) as! [Tag]
            // reload the table
            tagListViewController?.refreshTable()
        } catch {
            Swift.print(error)
        }
    }

    func updatePDFLocation(pdfLocation : String) {
        if selectedPapers.count == 1 {
            var filename : String
            
            if let id = selectedPapers[0].value(forKey: "id") as? String {
                filename = id + ".pdf"
            } else {
                let id = ProcessInfo.processInfo.globallyUniqueString
                selectedPapers[0].setValue(id, forKey: "id")
                filename = id + ".pdf"
            }
            
            let newPDFLocation = documentsURL.appendingPathComponent(filename).path
            
            if fileManager.fileExists(atPath: newPDFLocation) {
                try! fileManager.removeItem(atPath: newPDFLocation)
            }
            try! fileManager.copyItem(atPath: pdfLocation, toPath: newPDFLocation)
            
            selectedPapers[0].setValue(newPDFLocation, forKey: "pdfLocation")
            
            articleListViewController?.updatePDFPreview(paper: selectedPapers[0])
            pdfViewController?.updatePDFView(paper: selectedPapers[0])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        windowController = NSApplication.shared().mainWindow?.windowController as! WindowController?
        windowController?.viewController = self

        fileManager = FileManager.default
        let appSupportURL = try! fileManager.url(for: .applicationSupportDirectory, in:.userDomainMask, appropriateFor:nil, create:true)
        documentsURL = appSupportURL.appendingPathComponent("Documents")
        try! fileManager.createDirectory(atPath: documentsURL.path, withIntermediateDirectories: true, attributes: nil)
        
        // refresh the table with the data
        fetchDataAndRefreshTable()
        fetchTagData()
        
        selectPapers(indexes: [0])
    }

    func noPaperSelected() {
        articleListViewController?.clearViews()
        pdfViewController?.clearPDFView()
    }

    func papersSelected(indexes: IndexSet) {
        selectedPapers = []
        for index in indexes.sorted().reversed() {
            print("User selected paper at index", index)
            let paper = paperData[index]
            selectedPapers.append(paper)
        }
        if selectedPapers.count == 1 {
            articleListViewController?.updateViews(paper: selectedPapers[0])
            pdfViewController?.updatePDFView(paper: selectedPapers[0])
            windowController?.enableEditing(bool: true)
        } else {
            articleListViewController?.clearViews()
            windowController?.enableEditing(bool: false)
        }
    }
    
    func selectPapers(indexes: IndexSet) {
        articleListViewController?.selectPapers(indexes: indexes)
    }
    
    var articleListViewController: ArticleListViewController?
    var pdfViewController: PDFViewController?
    var tagListViewController: TagListViewController?

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        // Get references to child view controllers
        if segue.identifier == "articleListView" {
            articleListViewController = segue.destinationController as! ArticleListViewController
            articleListViewController?.mainController = self
        }
        else if segue.identifier == "PDFView" {
            pdfViewController = segue.destinationController as! PDFViewController
            pdfViewController?.mainController = self
        }
        else if segue.identifier == "tagListView" {
            tagListViewController = segue.destinationController as! TagListViewController
            tagListViewController?.mainController = self
        }
    }
    
    func addTag() {
        let entity = NSEntityDescription.entity(forEntityName:"Tag", in: managedContext)
        // insert a new "Item"
        let tag = Tag(entity: entity!, insertInto: managedContext)
        tag.setValue("New Tag", forKey: "name")
        
        do {
            try managedContext.save()
            
            selectedTags = []
            fetchDataAndRefreshTable()
            fetchTagData()
        } catch {
            Swift.print(error)
        }
    }
    
    func deleteSelectedTags(indexes: IndexSet) {
        for index in indexes.sorted().reversed() {
            if index != 0 {
                print("Deleting tag at index", index-1)
                let tag = tagData[index-1]
                managedContext.delete(tag)
            }
        }
        do {
            // save the data
            try managedContext.save()
            
            // refresh the table with the updated data
            selectedTags = []
            fetchDataAndRefreshTable()
            fetchTagData()
            
            articleListViewController?.clearViews()
            pdfViewController?.clearPDFView()
        } catch {
            Swift.print(error)
        }
    }
    
    func editTagName(index: Int, name: String) {
        if selectedTags.count == 1 {
            selectedTags[0].setValue(name, forKey: "name")
            
            do {
                // save the data
                try managedContext.save()
                
                // refresh the table with the updated data
                fetchDataAndRefreshTable()
                fetchTagData()
            } catch {
                Swift.print(error)
            }
        }
    }
    
    func noTagSelected() {
        selectedTags = []
        articleListViewController?.clearViews()
        pdfViewController?.clearPDFView()
        
        fetchDataAndRefreshTable()
    }
    
    func tagsSelected(indexes: IndexSet) {
        selectedTags = []
        for index in indexes.sorted().reversed() {
            if index != 0 {
                print("User selected tag at index", index-1)
                let tag = tagData[index-1]
                selectedTags.append(tag)
            }
        }
        fetchDataAndRefreshTable()
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

