//
//  BitmapFontEditor.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/12/2026.
//

import Cocoa
import RFSupport
import CoreFont

public class BitmapFontEditor: AbstractEditor, ResourceEditor, PlaceholderProvider, NSTableViewDelegate {
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
    /// Not sure why, but creating a custom BitmapFontPreviewView in the nib file was
    /// not working without crashing. So create it programatically and set the box's `contentView`
    @IBOutlet weak var box:                         NSBox!
    @IBOutlet weak var previewView:                 BitmapFontPreviewView!

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
//        NSLog("\(type(of: self)).\(#function)")
    }

    public override func windowDidLoad() {
//        NSLog("\(type(of: self)).\(#function)")
        let bounds = box.bounds
        let prevView = BitmapFontPreviewView(frame: bounds)
        prevView.autoresizingMask = [.width, .height]
		prevView.padding = 10
		prevView.borderThickness = 2
		prevView.borderColor = .red
        prevView.nfnt = nfnt
        self.previewView = prevView
        box.contentView = prevView
//        self.previewView.stringValue = "Spinhx of black quartz, judge my vow!"
        self.previewView.stringValue = """
            ABCDEFGHIJKLM
            NOPQRSTUVWXYZ
            abcdefghijklm
            nopqrstuvwxyz
            0123456789
            """
        previewView.alignment = .center
        fontTypeBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFontType")
        nfnt.bind(NSBindingName("objcFontType"), to: self, withKeyPath: "objcFontType")
        bitDepthPopUpButton.selectItem(withTag: NFNT.FontType.viewTag(forFontBitDepth: nfnt.fontType))
        super.windowDidLoad()
    }

    public static func placeholderName(for resource: Resource) -> String? {
        // TODO: parse FONDs and label NFNTs according to font association entries?
        return nil
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

// MARK: <PreviewProvider>
extension BitmapFontEditor: PreviewProvider {
	static var previewView: BitmapFontPreviewView = BitmapFontPreviewView(frame: NSMakeRect(0, 0, 64, 64))
	static var isSetup = false
	
	public static func image(for resource: Resource) -> NSImage? {
		let image: NSImage = NSImage()
		DispatchQueue.main.async {
			do {
				if !isSetup {
					previewView.backgroundColor = .white
					previewView.borderThickness = 1
					previewView.borderColor = .secondaryLabelColor
					previewView.alignment = .center
					previewView.stringValue = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcde12345"
					isSetup = true
				}
				let nfnt: NFNT = try NFNT(resource.data, resource: resource)
				previewView.nfnt = nfnt
				if let bitmapRep = previewView.bitmapImageRepForCachingDisplay(in: previewView.bounds) {
					previewView.cacheDisplay(in: previewView.bounds, to: bitmapRep)
					image.addRepresentation(bitmapRep)
				}
			} catch { }
		}
		return image
	}
	
	public static func maxThumbnailSize(for resourceType: String) -> Int? {
		return 64
	}
}
