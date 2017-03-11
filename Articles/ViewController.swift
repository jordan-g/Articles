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

    func importArticles(path : String) {
        let fileExtension = (path as NSString).pathExtension
        
        referenceReader = ReferenceReader()
        var title, authors, journal, abstract, issn, volume, issue, startPage, endPage, type, url, relatedRecords, date : String
        var articlePropertyDicts: [Dictionary<String, String>] = []
        
        if (fileExtension == "ris") {
            articlePropertyDicts = referenceReader.readRISFile(path: path)
            
        } else if (fileExtension == "nbib") {
            (title, authors, journal, abstract, issn, volume,
                issue, startPage, endPage, type, url, relatedRecords, date) = referenceReader.readNBIBFile(path: path)
        } else {
            return
        }

        let pdfLocation = ""
        
        for articlePropertyDict in articlePropertyDicts {
            let id = ProcessInfo.processInfo.globallyUniqueString
            
            let filename = id + "." + fileExtension
            
            let newLocation = documentsURL.appendingPathComponent(filename).path
            
            if fileManager.fileExists(atPath: newLocation) {
                try! fileManager.removeItem(atPath: newLocation)
            }
            
            try! fileManager.copyItem(atPath: path, toPath: newLocation)
            
            title          = articlePropertyDict["title"]!
            authors        = articlePropertyDict["authors"]!
            journal        = articlePropertyDict["journal"]!
            abstract       = articlePropertyDict["abstract"]!
            issn           = articlePropertyDict["issn"]!
            volume         = articlePropertyDict["volume"]!
            issue          = articlePropertyDict["issue"]!
            startPage      = articlePropertyDict["startPage"]!
            endPage        = articlePropertyDict["endPage"]!
            type           = articlePropertyDict["type"]!
            url            = articlePropertyDict["url"]!
            relatedRecords = articlePropertyDict["relatedRecords"]!
            date           = articlePropertyDict["date"]!

            let fetch = NSFetchRequest<Article>(entityName: "Article")
            let predicate = NSPredicate(format: "title == %@", title)
            fetch.predicate = predicate
            
            let result : Array? = try! managedContext.fetch(fetch)
            
            if (result?.isEmpty)! {
                addArticle(title: title, authors: authors, journal: journal, pdfLocation: pdfLocation, abstract: abstract, id: id,
                         issn: issn, volume: volume, issue: issue, startPage: startPage, endPage: endPage, type: type, url: url,
                         relatedRecords: relatedRecords, date: date)
            }
        }
    }

    func addArticle(title: String?, authors: String?, journal: String?, pdfLocation: String?, abstract: String?, id: String?,
                  issn: String?, volume: String?, issue: String?, startPage: String?, endPage: String?, type: String?,
                  url: String?, relatedRecords: String?, date: String?) {
        // get the entity from the Core Data model called "Item"
        let entity = NSEntityDescription.entity(forEntityName:"Article", in: managedContext)
        // insert a new "Item"
        let article = Article(entity: entity!, insertInto: managedContext)
        
        // set the values of the "name" and "value" attribute
        article.setValue(title, forKey: "title")
        article.setValue(authors, forKey: "authors")
        article.setValue(journal, forKey: "journal")
        article.setValue(pdfLocation, forKey: "pdfLocation")
        article.setValue(abstract, forKey: "abstract")
        article.setValue(issn, forKey: "issn")
        article.setValue(volume, forKey: "volume")
        article.setValue(issue, forKey: "issue")
        article.setValue(startPage, forKey: "startPage")
        article.setValue(endPage, forKey: "endPage")
        article.setValue(type, forKey: "type")
        article.setValue(url, forKey: "url")
        article.setValue(relatedRecords, forKey: "relatedRecords")
        article.setValue(date, forKey: "date")
        article.setValue(id, forKey: "id")
        
        do {
            // save the data
            try managedContext.save()
            //refresh the table with the updated data
            fetchDataAndRefreshTable()

            articleListViewController?.updateViews(article: article)
            tagListViewController?.refreshTable()
        } catch {
            Swift.print(error)
        }
    }

    func updateSelectedArticle() {
        if selectedArticles.count == 1 {
            articleListViewController?.updateArticleFromViews(article: selectedArticles[0])
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

    func updateSelectedArticle(properties: Dictionary<String, String>) {
        if selectedArticles.count == 1 {
            let article = selectedArticles[0]

            do {
                article.setValue(properties["title"], forKey: "title")
                article.setValue(properties["authors"], forKey: "authors")
                article.setValue(properties["journal"], forKey: "journal")
                article.setValue(properties["pdfLocation"], forKey: "pdfLocation")
                article.setValue(properties["abstract"], forKey: "abstract")
                article.setValue(properties["issn"], forKey: "issn")
                article.setValue(properties["volume"], forKey: "volume")
                article.setValue(properties["issue"], forKey: "issue")
                article.setValue(properties["startPage"], forKey: "startPage")
                article.setValue(properties["endPage"], forKey: "endPage")
                article.setValue(properties["type"], forKey: "type")
                article.setValue(properties["url"], forKey: "url")
                article.setValue(properties["relatedRecords"], forKey: "relatedRecords")
                article.setValue(properties["date"], forKey: "date")
                article.setValue(properties["id"], forKey: "id")
                
                do {
                    // save the data
                    try managedContext.save()
                    //refresh the table with the updated data
                    fetchDataAndRefreshTable()
                    
                    articleListViewController?.updateViews(article: article)
                    tagListViewController?.refreshTable()
                } catch {
                    Swift.print(error)
                }
            }
        }
    }

    func deleteSelectedArticles(indexes: IndexSet) {
        for index in indexes.sorted().reversed() {
            print("Deleting article at index", index)
            let article = articleData[index]
            managedContext.delete(article)
        }
        do {
            // save the data
            try managedContext.save()
            
            // refresh the table with the updated data
            selectedArticles = []
            fetchDataAndRefreshTable()
            fetchTagData()
            
            articleListViewController?.clearViews()
            pdfViewController?.clearPDFView()
        } catch {
            Swift.print(error)
        }
    }
    
    // an array to hold the data
    var articleData = [Article]()
    var filteredArticleData = [Article]()
    var tagData = [Tag]()
    
    // a selected item
    var selectedArticles : [Article] = []
    var selectedTags : [Tag] = []
    
    lazy var managedContext: NSManagedObjectContext = {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        return appDelegate.managedObjectContext
    }()

    func fetchDataAndRefreshTable() {
        // create a fetch request that retrieves all items from the "Item" entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        let filteredFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        if selectedTags.count != 0 {
            var predicates : [NSPredicate] = []
            for tag in selectedTags {
                let predicate = NSPredicate(format: "ANY tag == %@", tag)
                predicates.append(predicate)
            }
            filteredFetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
        }
        do {
            articleData = try managedContext.fetch(fetchRequest) as! [Article]
            // retrieve the data
            filteredArticleData = try managedContext.fetch(filteredFetchRequest) as! [Article]
            // reload the table
            articleListViewController?.refreshTable()
        } catch {
            Swift.print(error)
        }
    }
    
    func searchFor(text: String) {
        // create a fetch request that retrieves all items from the "Item" entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
        let filteredFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Article")
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
            articleData = try managedContext.fetch(fetchRequest) as! [Article]
            // retrieve the data
            filteredArticleData = try managedContext.fetch(filteredFetchRequest) as! [Article]
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
        if selectedArticles.count == 1 {
            var filename : String
            
            if let id = selectedArticles[0].value(forKey: "id") as? String {
                filename = id + ".pdf"
            } else {
                let id = ProcessInfo.processInfo.globallyUniqueString
                selectedArticles[0].setValue(id, forKey: "id")
                filename = id + ".pdf"
            }
            
            let newPDFLocation = documentsURL.appendingPathComponent(filename).path
            
            if fileManager.fileExists(atPath: newPDFLocation) {
                try! fileManager.removeItem(atPath: newPDFLocation)
            }
            try! fileManager.copyItem(atPath: pdfLocation, toPath: newPDFLocation)
            
            selectedArticles[0].setValue(newPDFLocation, forKey: "pdfLocation")
            
            articleListViewController?.updatePDFPreview(article: selectedArticles[0])
            pdfViewController?.updatePDFView(article: selectedArticles[0])
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
        
        selectArticles(indexes: [0])
    }

    func noArticleSelected() {
        articleListViewController?.clearViews()
        pdfViewController?.clearPDFView()
    }

    func articlesSelected(indexes: IndexSet) {
        selectedArticles = []
        for index in indexes.sorted().reversed() {
            print("User selected article at index", index)
            let article = articleData[index]
            selectedArticles.append(article)
        }
        if selectedArticles.count == 1 {
            articleListViewController?.updateViews(article: selectedArticles[0])
            pdfViewController?.updatePDFView(article: selectedArticles[0])
            windowController?.enableEditing(bool: true)
        } else {
            articleListViewController?.clearViews()
            windowController?.enableEditing(bool: false)
        }
    }
    
    func selectArticles(indexes: IndexSet) {
        articleListViewController?.selectArticles(indexes: indexes)
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

