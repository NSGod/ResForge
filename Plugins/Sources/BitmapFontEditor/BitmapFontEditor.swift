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
    @IBOutlet weak var bitDepthPopUpButton:         NSPopUpButton!
    /// Not sure why, but creating a custom PreviewView in the nib file was
    /// not working without crashing. So create it programatically and set the box's contentView.
    @IBOutlet weak var box:                         NSBox!
    @IBOutlet weak var previewView:                 PreviewView!

    @IBOutlet var popover:                          NSPopover!
    @IBOutlet weak var popoverButton:               NSButton!

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
        previewView.autoresizingMask = [.width, .height]
        previewView.nfnt = nfnt
        self.previewView = previewView
        box.contentView = previewView
        self.previewView.stringValue = "Spinhx of black quartz, judge my vow!"
        fontTypeBitfieldControl.bind(NSBindingName(rawValue: "objectValue"), to: self, withKeyPath: "objcFontType")
        nfnt.bind(NSBindingName(rawValue:"objcFontType"), to: self, withKeyPath: "objcFontType")
        bitDepthPopUpButton.selectItem(withTag: NFNT.FontType.viewTag(forFontBitDepth: nfnt.fontType))
        super.windowDidLoad()
    }

    @IBAction func showPopover(_ sender: Any) {
        popover.show(relativeTo: popoverButton.bounds, of: popoverButton, preferredEdge: .maxX)
    }

    @IBAction func changeFontType(_ sender: Any) {
        guard let sender = sender as? NSButton else { return }
        let isOn = sender.state == .on
        if isOn {
            self.objcFontType = objcFontType | UInt16(sender.tag)
        } else {
            self.objcFontType = objcFontType & ~UInt16(sender.tag)
        }
    }

    @IBAction func changeBitDepth(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        guard let sender = sender as? NSPopUpButton else { return }

    }

    public func saveResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)()")

    }

    public func revertResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)()")

    }

}
