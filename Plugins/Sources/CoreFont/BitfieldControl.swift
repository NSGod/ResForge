//
//  BitfieldControl.swift
//  CoreFont
//
//  Created by Mark Douma on 12/29/2025.
//

import Cocoa

/// A convient control that allows setting bitmasks via objectValue.
/// You should place checkboxes with tags set to each power-of-two value
/// you wish to allow control over. Set the
/// In -awakeFromNib, -viewDidLoad, or -windowDidLoad, set up a binding between
///

public class BitfieldControl: NSControl {
    @IBInspectable public var backgroundColor:   NSColor? = nil {
        didSet {
            self.needsDisplay = true
        }
    }

    override public var isEnabled: Bool {
        didSet {
            if isEnabled == false {
                enabledMask = 0
            } else {
                enabledMask = 0xFFFF_FFFF
            }
        }
    }

    @IBInspectable public var numberOfBits:      Int = 16         // 16 or 32

    // to allow disabling or enabling of specific checkboxes via a mask
    public var enabledMask:       Int = 0 {
        didSet {
            NSLog("\(type(of: self)).\(#function)() enabledMask == \(enabledMask)")

            var i = 1
            let max = numberOfBits == 16 ? UInt32(UInt16.max) : UInt32.max
            while i < max {
                if let button = self.viewWithTag(i) as? NSButton {
                    button.isEnabled = (enabledMask & i) != 0
                }
                i *= 2
            }
        }
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override class func awakeFromNib() {
        NSLog("\(type(of: self)).\(#function)()")
        super.awakeFromNib()
    }

    @objc dynamic override open var objectValue: Any? {
        get { return super.objectValue }
        set {
            NSLog("\(type(of: self)).\(#function)() newValue == \(String(describing: newValue))")
            super.objectValue = newValue
            if objectValue == nil {
                self.enabledMask = 0
                return
            } else {
                if enabledMask == 0 {
                    self.enabledMask = (numberOfBits == 16 ? 0xFFFF : 0xFFFFFFFF)
                }
            }
            guard let bitfield = objectValue as? Int else {
                return
            }
            var i = 1
            let max = numberOfBits == 16 ? UInt32(UInt16.max) : UInt32.max
            while i <= max {
                if let button = self.viewWithTag(i) as? NSButton {
                    button.state = (bitfield & i) != 0 ? .on : .off
                }
                i *= 2
            }
        }
    }

    // override to exclude ourself
    override open func viewWithTag(_ tag: Int) -> NSView? {
        let view = super.viewWithTag(tag)
        if view != self { return view }
        let subviews = self.subviews
        for view in subviews {
            if view.tag == tag { return view }
        }
        return nil
    }

    open override func draw(_ dirtyRect: NSRect) {
        let bounds = self.bounds
        if let backgroundColor = backgroundColor {
            backgroundColor.set()
            NSBezierPath.fill(bounds)
        } else {
            super.draw(bounds)
        }
    }

}
