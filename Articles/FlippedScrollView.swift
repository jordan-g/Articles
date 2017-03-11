//
//  FlippedScrollView.swift
//  Papers
//
//  Created by Jordan Guerguiev on 2017-02-27.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class FlippedScrollView: NSScrollView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override var isFlipped: Bool {
        return false
    }
}
