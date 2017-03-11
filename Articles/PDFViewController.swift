//
//  PDFViewController.swift
//  Papers
//
//  Created by Jordan Guerguiev on 2017-02-22.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa
import Quartz

class PDFViewController: NSViewController {
    @IBOutlet weak var pdfView : PDFView!

    weak var mainController: ViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    func clearPDFView() {
        pdfView.document = nil
    }

    func updatePDFView(paper: Paper) {
        if let location = paper.value(forKey: "pdfLocation") as? String {
            if (location == "") {
                pdfView.document = nil
            } else {
                let pathExtension = (location as NSString).pathExtension
                if (pathExtension.lowercased() == "pdf") {
                    pdfView.document = PDFDocument(url: NSURL(fileURLWithPath: NSString(string: location).expandingTildeInPath as String) as URL)
                }
            }
        } else {
            pdfView.document = nil
        }
    }
}
