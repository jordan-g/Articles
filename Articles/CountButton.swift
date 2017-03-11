//
//  CountButton.swift
//  Articles
//
//  Created by Jordan Guerguiev on 2017-02-26.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class CountButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
        let bgColor = NSColor.red
        
        self.layer?.cornerRadius = 10
//        self.layer?.masksToBounds = true
        self.layer?.backgroundColor = bgColor.cgColor
        bgColor.setFill()
        NSRectFill(dirtyRect)
        self.title.draw(in: dirtyRect)
    }
    
}
