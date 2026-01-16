//
//  BitmapFontEditor.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/12/2026.
//

import Cocoa
import RFSupport
import FONDEditor

public class BitmapFontEditor: AbstractEditor, ResourceEditor, NSTableViewDelegate {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "NFNT",
        "FONT",
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    @IBOutlet weak var fontTypeBitfieldControl:     BitfieldControl!
    @IBOutlet weak var colorFontPopUpButton:        NSPopUpButton!
    /// Not sure why, but creating a custom PreviewView in the nib file was
    /// not working without crashing. So create it programatically and set the box's contentView.
    @IBOutlet weak var box:                         NSBox!
    @IBOutlet weak var previewView:                 PreviewView!

    public let resource:                    Resource
    private let manager:                    RFEditorManager
    @objc var nfnt:                         NFNT

    @objc var objcFontType:                 NFNT.FontType.RawValue

    public override var windowNibName: NSNib.Name? {
        return "BitmapFontEditor"
    }

    public required init?(resource: RFSupport.Resource, manager: any RFSupport.RFEditorManager) {
        self.resource = resource
        self.manager = manager
        do {
            nfnt = try NFNT(resource.data, resource: resource)
            objcFontType = nfnt.fontType.rawValue
        } catch  {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
            return nil
        }
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func awakeFromNib() {
        NSLog("\(type(of: self)).\(#function)")
    }

    public override func windowDidLoad() {
        NSLog("\(type(of: self)).\(#function)")
        let bounds = box.bounds
        let previewView = PreviewView(frame: bounds)
        previewView.nfnt = nfnt
        self.previewView = previewView
        box.contentView = previewView
        self.previewView.stringValue = "Spinhx of black quartz, judge my vow!"
        super.windowDidLoad()
    }

    public func saveResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)()")

    }

    public func revertResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)()")

    }

}
