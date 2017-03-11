//
//  URLTextField.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-03-06.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class URLTextField: NSTextField {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func resetCursorRects() {
        // Make clickable
        self.addCursorRect(self.bounds, cursor: NSCursor.pointingHand())
    }
    
}
