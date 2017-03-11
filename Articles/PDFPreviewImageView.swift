//
//  PDFPreviewImageView.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-02-17.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class PDFPreviewImageView: NSImageView {
    weak var delegate : ArticleListViewController!
    
    var draggedPDFLocation : NSArray!
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        
        draggedPDFLocation = sender.draggingPasteboard().propertyList(forType: NSFilenamesPboardType) as! NSArray
        
        delegate.updatePDFLocation(pdfLocation: draggedPDFLocation[0] as! String)
        
        return false
    }
}
