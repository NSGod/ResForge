//
//  BitmapFontEditor.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/12/2026.
//

import Cocoa
import RFSupport
import CoreFont

public class BitmapFontEditor: AbstractEditor, ResourceEditor, PlaceholderProvider, ExportProvider, NSTableViewDelegate {
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

    @objc var objcFontType:                 UInt16

    public override var windowNibName: NSNib.Name? {
        return "BitmapFontEditor"
    }

    public override var undoManager: UndoManager? {
        return window?.undoManager
    }

    public required init?(resource: Resource, manager: any RFEditorManager) {
        self.resource = resource
        self.manager = manager
        do {
            nfnt = try NFNT(with: self.resource)
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

    deinit {
        fontTypeBitfieldControl.unbind(NSBindingName("objectValue"))
    }

    public override func awakeFromNib() {
//        NSLog("\(type(of: self)).\(#function)")
    }

    static var nfntContext = 1

    public override func windowDidLoad() {
        super.windowDidLoad()
        let bounds = box.bounds
        let prevView = BitmapFontPreviewView(frame: bounds)
        prevView.autoresizingMask = [.width, .height]
		prevView.padding = 10
		prevView.borderThickness = 2
		prevView.borderColor = .darkGray
        prevView.nfnt = nfnt
        previewView = prevView
        box.contentView = prevView
        previewView.alignment = .center
//        self.previewView.stringValue = "Spinhx of black quartz, judge my vow!"
        self.previewView.stringValue = """
            ABCDEFGHIJKLM
            NOPQRSTUVWXYZ
            abcdefghijklm
            nopqrstuvwxyz
            0123456789
            """
        fontTypeBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFontType")
        bitDepthPopUpButton.selectItem(withTag: NFNT.FontType.viewTag(forFontBitDepth: nfnt.fontType))
        nfnt.addObserver(self, forKeyPath: "firstChar", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "lastChar", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "widMax", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "kernMax", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "nDescent", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "fRectWidth", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "fRectHeight", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "owTLoc", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "ascent", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "descent", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "leading", options: [.new, .old], context: &Self.nfntContext)
        nfnt.addObserver(self, forKeyPath: "rowWords", options: [.new, .old], context: &Self.nfntContext)
        addObserver(self, forKeyPath: "objcFontType", options: [.new, .old], context: nil)
    }

    @IBAction func showPopover(_ sender: Any) {
        popover.show(relativeTo: popoverButton.bounds, of: popoverButton, preferredEdge: .maxX)
    }

    @IBAction func changeFontType(_ sender: Any) {
        let sender = sender as! NSButton
        willChangeValue(forKey: "objcFontType")
        if sender.state == .on {
            objcFontType = objcFontType | UInt16(sender.tag)
        } else {
            objcFontType = objcFontType & ~UInt16(sender.tag)
        }
        didChangeValue(forKey: "objcFontType")
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

    static let keyPaths = Set(["firstChar", "lastChar", "widMax", "kernMax", "nDescent", "fRectWidth", "fRectHeight", "owTLoc", "ascent", "descent", "leading", "rowWords", "objcFontType"])

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let context, let keyPath else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
//        NSLog("\(type(of: self)).\(#function) keyPath == \(keyPath)")
        if Self.keyPaths.contains(keyPath) {
            if context == &Self.nfntContext {
                undoManager?.registerUndo(withTarget: self, handler: {
                    $0.nfnt.willChangeValue(forKey: keyPath)
                    $0.nfnt.setValue(change![.oldKey], forKey: keyPath)
                    $0.nfnt.didChangeValue(forKey: keyPath)
                })
            } else {
                undoManager?.registerUndo(withTarget: self, handler: {
                    $0.willChangeValue(forKey: keyPath)
                    $0.setValue(change![.oldKey], forKey: keyPath)
                    $0.didChangeValue(forKey: keyPath)
                })
            }
            window?.isDocumentEdited = true
        }
        if keyPath == "firstChar" {
            undoManager?.setActionName(NSLocalizedString("Change First Character", comment: ""))
        } else if keyPath == "lastChar" {
            undoManager?.setActionName(NSLocalizedString("Change Last Character", comment: ""))
        } else if keyPath == "widMax" {
            undoManager?.setActionName(NSLocalizedString("Change Maximum Width", comment: ""))
        } else if keyPath == "kernMax" {
            undoManager?.setActionName(NSLocalizedString("Change Kern Maximum", comment: ""))
        } else if keyPath == "nDescent" {
            undoManager?.setActionName(NSLocalizedString("Change Negative of Descent", comment: ""))
        } else if keyPath == "fRectWidth" {
            undoManager?.setActionName(NSLocalizedString("Change Font Rect Width", comment: ""))
        } else if keyPath == "fRectHeight" {
            undoManager?.setActionName(NSLocalizedString("Change Font Rect Height", comment: ""))
        } else if keyPath == "owTLoc" {
            undoManager?.setActionName(NSLocalizedString("Change Offset to Width Table Location", comment: ""))
        } else if keyPath == "ascent" {
            undoManager?.setActionName(NSLocalizedString("Change Ascent", comment: ""))
        } else if keyPath == "descent" {
            undoManager?.setActionName(NSLocalizedString("Change Descent", comment: ""))
        } else if keyPath == "leading" {
            undoManager?.setActionName(NSLocalizedString("Change Leading", comment: ""))
        } else if keyPath == "rowWords" {
            undoManager?.setActionName(NSLocalizedString("Change Image Row Words", comment: ""))
        } else {
            undoManager?.setActionName(NSLocalizedString("Change Font Type", comment: ""))
        }
    }

    public static func placeholderName(for resource: Resource) -> String? {
        // TODO: parse FONDs and label NFNTs according to font association entries?
        return nil
    }

    // MARK: <ExportProvider>
    public static func filenameExtension(for resourceType: String) -> String {
        return "png"
    }

    public static func export(_ resource: Resource, to url: URL) throws {
        let nfnt = try NFNT(with: resource)
        guard let image: NSImage = nfnt.bitmapImage else { return }
        guard let imageRep: NSBitmapImageRep = image.representations.first as? NSBitmapImageRep else { return }
        guard let data = imageRep.representation(using: .png, properties: [:]) else { return }
        _ = try data.write(to: url, options: .atomic)
    }
}

// MARK: <PreviewProvider>
extension BitmapFontEditor: PreviewProvider {
	static let previewView: BitmapFontPreviewView = BitmapFontPreviewView(frame: NSMakeRect(0, 0, 64, 64))
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
				let nfnt: NFNT = try NFNT(with: resource)
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
