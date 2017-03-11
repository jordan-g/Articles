//
//  ExpandingTextField.swift
//  Papers
//
//  Created by Jordan Guerguiev on 2017-02-23.
//  Copyright © 2017 Jordan Guerguiev. All rights reserved.
//

import Cocoa

class ExpandingTextField: NSTextField {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    var _isEditing : Bool = false
    var _hasLastIntrinsicSize : Bool = false
    var _lastIntrinsicSize : NSSize? = nil
    
    override func textDidBeginEditing(_ notification: Notification) {
        super.textDidBeginEditing(notification)
        _isEditing =  true
    }
    
    override func textDidEndEditing(_ notification: Notification) {
        super.textDidEndEditing(notification)
        _isEditing = false
    }
    
    override var intrinsicContentSize: NSSize {
        var intrinsicSize = super.intrinsicContentSize
        
        if (_isEditing || !_hasLastIntrinsicSize) {
            let fieldEditor = window?.fieldEditor(false, for: self)
            
            if fieldEditor is NSTextView {
                let textView = fieldEditor as! NSTextView
                
                let usedRect = textView.textContainer?.layoutManager?.usedRect(for: textView.textContainer!)
                
//                usedRect?.size.height += 5.0
                
                intrinsicSize.height = (usedRect?.size.height)!
            }
        }
        
        return intrinsicSize
    }
    
    override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        
        self.invalidateIntrinsicContentSize()
    }
    
}
