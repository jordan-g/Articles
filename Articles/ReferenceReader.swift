//
//  ReferenceReader.swift
//  Papers
//
//  Created by Jordan Guerguiev on 2017-02-17.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class ReferenceReader: NSObject {
    
    func readRISFile(path : String) -> [Dictionary<String, String>] {
        let RISString = try! String.init(contentsOfFile: path).replacingOccurrences(of: "\n      ", with: " ").replacingOccurrences(of: "\r", with: "")
        let titleRegexPattern          = "(?:TI|T1)  - (.*)"
        let authorsRegexPattern        = "(?:AU|A1)  - (.*)"
        let journalRegexPattern        = "(?:JA|T2|J2|JF)  - (.*)"
        let abstractRegexPattern       = "(?:AB|N2)  - (.*)"
        let issnRegexPattern           = "SN  - (.*)"
        let volumeRegexPattern         = "VL  - (.*)"
        let issueRegexPattern          = "IS  - (.*)"
        let startPageRegexPattern      = "SP  - (.*)"
        let endPageRegexPattern        = "EP  - (.*)"
        let typeRegexPattern           = "TY  - (.*)"
        let urlRegexPattern            = "UR  - (.*)"
        let relatedRecordsRegexPattern = "(?:L3|ER)  - (.*)"
        let dateRegexPattern           = "(?:Y1|Y2)  - (.*)"
        
        var titleStrings: [String]          = []
        var authorsStrings: [String]        = []
        var journalStrings: [String]        = []
        var abstractStrings: [String]       = []
        var issnStrings: [String]           = []
        var volumeStrings: [String]         = []
        var issueStrings: [String]          = []
        var startPageStrings: [String]      = []
        var endPageStrings: [String]        = []
        var typeStrings: [String]           = []
        var urlStrings: [String]            = []
        var relatedRecordsStrings: [String] = []
        var dateStrings: [String]           = []
        
        let paperStrings = RISString.components(separatedBy: "\n\n")
        
        var paperPropertyDicts: [Dictionary<String, String>] = []
        
        for paperString in paperStrings {
            if paperString.contains("http://journal.frontiersin.org/Article/10.3389/fncom.2016.00094/abstract") {
                Swift.print(paperString)
            }
            // Get title
            titleStrings               = matchStringWithRegex(string: paperString, regexPattern: titleRegexPattern)
            var title : String

            if titleStrings.count == 0 {
                title = ""
            } else {
                title = titleStrings[0]
            }
            var paperPropertyDict: [String: String] = ["title": title]

            // Get authors
            let authors        = matchStringWithRegex(string: paperString, regexPattern: authorsRegexPattern).joined(separator: "; ")
            paperPropertyDict["authors"] = authors

            // Get journal
            journalStrings             = matchStringWithRegex(string: paperString, regexPattern: journalRegexPattern)
            var journal : String = ""
            
            if journalStrings.count == 0 {
                let altJournalRegexPattern        = "PB  - (.*)"
                journalStrings        = matchStringWithRegex(string: paperString, regexPattern: altJournalRegexPattern)
                if journalStrings.count == 0 {
                    journal = ""
                } else {
                    journal = journalStrings[0]
                }
            } else {
                journal = journalStrings[0]
            }

            switch journal {
            case "Nat Neurosci":
                journal = "Nature Neuroscience"
            default: break
            }

            paperPropertyDict["journal"] = journal

            // Get abstract
            abstractStrings               = matchStringWithRegex(string: paperString, regexPattern: abstractRegexPattern)
            var abstract : String

            if abstractStrings.count == 0 {
                abstract = ""
            } else {
                abstract = abstractStrings[0]
            }
            paperPropertyDict["abstract"] = abstract

            // Get ISSN/ISBN
            issnStrings               = matchStringWithRegex(string: paperString, regexPattern: issnRegexPattern)
            var issn : String

            if issnStrings.count == 0 {
                issn = ""
            } else {
                issn = issnStrings[0]
            }
            paperPropertyDict["issn"] = issn
            
            // Get volume
            volumeStrings               = matchStringWithRegex(string: paperString, regexPattern: volumeRegexPattern)
            var volume : String

            if volumeStrings.count == 0 {
                volume = ""
            } else {
                volume = volumeStrings[0]
            }
            paperPropertyDict["volume"] = volume

            // Get issue
            issueStrings               = matchStringWithRegex(string: paperString, regexPattern: issueRegexPattern)
            var issue : String

            if issueStrings.count == 0 {
                issue = ""
            } else {
                issue = issueStrings[0]
            }
            paperPropertyDict["issue"] = issue

            // Get pages
            startPageStrings               = matchStringWithRegex(string: paperString, regexPattern: startPageRegexPattern)
            var startPage : String

            if startPageStrings.count == 0 {
                startPage = ""
            } else {
                startPage = startPageStrings[0]
            }
            paperPropertyDict["startPage"] = startPage
            
            endPageStrings               = matchStringWithRegex(string: paperString, regexPattern: endPageRegexPattern)
            var endPage : String

            if endPageStrings.count == 0 {
                endPage = ""
            } else {
                endPage = endPageStrings[0]
            }
            paperPropertyDict["endPage"] = endPage
            
            // Get type
            typeStrings               = matchStringWithRegex(string: paperString, regexPattern: typeRegexPattern)
            var type : String

            if typeStrings.count == 0 {
                type = ""
            } else {
                type = typeStrings[0]
            }
            
            switch type {
            case "JOUR":
                type = "Journal Article"
            default: break
            }

            paperPropertyDict["type"] = type
            
            // Get URL
            urlStrings               = matchStringWithRegex(string: paperString, regexPattern: urlRegexPattern)
            var url : String

            if urlStrings.count == 0 {
                url = ""
            } else {
                url = urlStrings[0]
            }
            paperPropertyDict["url"] = url
            
            // Get related records
            relatedRecordsStrings               = matchStringWithRegex(string: paperString, regexPattern: relatedRecordsRegexPattern)
            var relatedRecords : String

            if relatedRecordsStrings.count == 0 {
                relatedRecords = ""
            } else {
                relatedRecords = relatedRecordsStrings[0]
            }
            paperPropertyDict["relatedRecords"] = relatedRecords

            // Get date
            dateStrings             = matchStringWithRegex(string: paperString, regexPattern: dateRegexPattern)
            var date : String
            
            if dateStrings.count == 0 {
                do {
                    let altDateRegexPattern        = "PY  - (.*)"
                    date        = matchStringWithRegex(string: paperString, regexPattern: altDateRegexPattern).joined(separator: "; ")
                } catch {
                    date = ""
                }
            } else {
                date = dateStrings[0]
            }
            
            paperPropertyDict["date"] = date.replacingOccurrences(of: "//print", with: "")

            paperPropertyDicts.append(paperPropertyDict)
        }

        return paperPropertyDicts
    }
    
    func readNBIBFile(path : String) -> (String, String, String, String, String, String,
        String, String, String, String, String, String, String) {
            let NBIBString = try! String.init(contentsOfFile: path).replacingOccurrences(of: "\n      ", with: " ")
            
            let titleRegexPattern          = "TI  - (.*)\n"
            let title          = matchStringWithRegex(string: NBIBString, regexPattern: titleRegexPattern)[0]
            
            let authorsRegexPattern        = "AU  - (.*)\n"
            let authors        = matchStringWithRegex(string: NBIBString, regexPattern: authorsRegexPattern)[0]
            
            let journalRegexPattern        = "JT  - (.*)\n"
            let journal        = matchStringWithRegex(string: NBIBString, regexPattern: journalRegexPattern)[0]
            
            let abstractRegexPattern       = "AB  - (.*)\n"
            let abstract       = matchStringWithRegex(string: NBIBString, regexPattern: abstractRegexPattern)[0]
            
            let issnRegexPattern           = "IS  - (.*)\n"
            let issn           = matchStringWithRegex(string: NBIBString, regexPattern: issnRegexPattern)[0]
            
            let volumeRegexPattern         = "VI  - (.*)\n"
            let volume         = matchStringWithRegex(string: NBIBString, regexPattern: volumeRegexPattern)[0]
            
            let issueRegexPattern          = "IP  - (.*)\n"
            let issue          = matchStringWithRegex(string: NBIBString, regexPattern: issueRegexPattern)[0]
            
            let startPageRegexPattern      = "PG  - (.*)-(?:.*)\n"
            let startPage      = matchStringWithRegex(string: NBIBString, regexPattern: startPageRegexPattern)[0]
            
            let endPageRegexPattern        = "PG  - (?:.d*)-(.*)\n"
            let endPage        = matchStringWithRegex(string: NBIBString, regexPattern: endPageRegexPattern)[0]
            
            let typeRegexPattern           = "PT  - (.*)\n"
            let type           = matchStringWithRegex(string: NBIBString, regexPattern: typeRegexPattern)[0]

            let url            = ""
            let relatedRecords = ""
            let date           = ""
            
            return (title, authors, journal, abstract, issn, volume, issue,
                    startPage, endPage, type, url, relatedRecords, date)
    }
    
    func readBibTexFile(path : String) -> (String, String, String, String, String, String,
        String, String, String, String, String, String, String) {
            let NBIBString = try! String.init(contentsOfFile: path).replacingOccurrences(of: "\n      ", with: " ")
            
            let titleRegexPattern          = "title = \"(?:{+(.*)}+)\""
            let title          = matchStringWithRegex(string: NBIBString, regexPattern: titleRegexPattern)[0]
            
            let authorsRegexPattern        = "AU  - (.*)\n"
            let authors        = matchStringWithRegex(string: NBIBString, regexPattern: authorsRegexPattern)[0]
            
            let journalRegexPattern        = "JT  - (.*)\n"
            let journal        = matchStringWithRegex(string: NBIBString, regexPattern: journalRegexPattern)[0]
            
            let abstractRegexPattern       = "AB  - (.*)\n"
            let abstract       = matchStringWithRegex(string: NBIBString, regexPattern: abstractRegexPattern)[0]
            
            let issnRegexPattern           = "IS  - (.*)\n"
            let issn           = matchStringWithRegex(string: NBIBString, regexPattern: issnRegexPattern)[0]
            
            let volumeRegexPattern         = "VI  - (.*)\n"
            let volume         = matchStringWithRegex(string: NBIBString, regexPattern: volumeRegexPattern)[0]
            
            let issueRegexPattern          = "IP  - (.*)\n"
            let issue          = matchStringWithRegex(string: NBIBString, regexPattern: issueRegexPattern)[0]
            
            let startPageRegexPattern      = "PG  - (.*)-(?:.*)\n"
            let startPage      = matchStringWithRegex(string: NBIBString, regexPattern: startPageRegexPattern)[0]
            
            let endPageRegexPattern        = "PG  - (?:.d*)-(.*)\n"
            let endPage        = matchStringWithRegex(string: NBIBString, regexPattern: endPageRegexPattern)[0]
            
            let typeRegexPattern           = "PT  - (.*)\n"
            let type           = matchStringWithRegex(string: NBIBString, regexPattern: typeRegexPattern)[0]

            let url            = ""
            let relatedRecords = ""

            let date           = ""
            
            return (title, authors, journal, abstract, issn, volume, issue,
                    startPage, endPage, type, url, relatedRecords, date)
    }
    
    func matchStringWithRegex(string: String, regexPattern: String) -> [String] {
        let regex = try! NSRegularExpression(pattern: regexPattern, options: [])
//        Swift.print(string.characters.count)
//        Swift.print(regexPattern)
        
        let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count))
        
//        Swift.print(matches)
        
        var substrings = [String]()
        
        for match in matches {
            let range = match.rangeAt(1)
            let r = string.index(string.startIndex, offsetBy: range.location) ..<
                string.index(string.startIndex, offsetBy: range.location+range.length)
//            Swift.print(r)
            substrings.append(string.substring(with: r))
//            Swift.print(string.substring(with: r))
        }
        
        return substrings
    }
}
