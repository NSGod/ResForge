//
//  BitmapFontEditor.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/12/2026.
//

import Cocoa
import RFSupport
import CoreFont
import OrderedCollections

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
    @IBOutlet weak var overviewPreviewView:         BitmapFontPreviewView!
    
    @IBOutlet var popover:                          NSPopover!
    @IBOutlet weak var popoverButton:               NSButton!

    public let resource:                    Resource
    private let manager:                    RFEditorManager
    @objc var nfnt:                         NFNT

    @objc dynamic var objcFontType:         UInt16
    @objc dynamic var objcBitDepth:         UInt16

    private static var nfntContext = 1
    private static let nfntKeyPaths = Set(["firstChar", "lastChar", "widMax", "kernMax", "nDescent",
                    "fRectWidth", "fRectHeight", "owTLoc", "ascent", "descent", "rowWords"])
    private static let keyPaths = Set(["objcFontType", "objcBitDepth"])

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
            objcBitDepth = objcFontType & ~0xFFF3
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
        Self.nfntKeyPaths.forEach { nfnt.removeObserver(self, forKeyPath: $0) }
        Self.keyPaths.forEach { removeObserver(self, forKeyPath: $0) }
    }

    public override func awakeFromNib() {
        NSLog("\(type(of: self)).\(#function)")
        loadResource()
    }

    public override func windowDidLoad() {
        NSLog("\(type(of: self)).\(#function)")
        super.windowDidLoad()
        let bounds = box.bounds
        let prevView = BitmapFontPreviewView(frame: bounds)
        prevView.autoresizingMask = [.width, .height]
		prevView.padding = 10
		prevView.borderThickness = 2
		prevView.borderColor = .lightGray
        prevView.nfnt = nfnt
        previewView = prevView
        box.contentView = prevView
        previewView.alignment = .center
        self.previewView.stringValue = """
            ABCDEFGHIJKLM
            NOPQRSTUVWXYZ
            abcdefghijklm
            nopqrstuvwxyz
            0123456789
            """
        fontTypeBitfieldControl.bind(NSBindingName("objectValue"), to: self, withKeyPath: "objcFontType")
        Self.nfntKeyPaths.forEach { nfnt.addObserver(self, forKeyPath: $0, options: [.new, .old], context: &Self.nfntContext) }
        Self.keyPaths.forEach { addObserver(self, forKeyPath: $0, options: [.new, .old], context: nil) }
    }

    private func loadResource() {
        var string: String = ""
        for glyph in nfnt.glyphs {
            if glyph.uv != .undefined {
                if let scalar = UnicodeScalar(glyph.uv) {
                    string.append("\(Character(scalar))")
                }
            }
        }
        overviewPreviewView.alignment = .center
        overviewPreviewView.stringValue = string
        overviewPreviewView.nfnt = nfnt
    }

    @IBAction func showPopover(_ sender: Any) {
        popover.show(relativeTo: popoverButton.bounds, of: popoverButton, preferredEdge: .maxX)
    }

    @IBAction func changeFontType(_ sender: Any) {
        let sender = sender as! NSButton
        if sender.state == .on {
            objcFontType = objcFontType | UInt16(sender.tag)
        } else {
            objcFontType = objcFontType & ~UInt16(sender.tag)
        }
    }

    @IBAction func changeBitDepth(_ sender: Any) {
        let sender = sender as! NSPopUpButton
        undoManager?.disableUndoRegistration()
        objcFontType = (objcFontType & ~12) | UInt16(sender.selectedTag())
        undoManager?.enableUndoRegistration()
    }

    public func saveResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)()")
        nfnt.fontType = NFNT.FontType(rawValue: objcFontType)
        do {
            resource.data = try nfnt.data()
        } catch {
            NSLog("\(type(of: self)).\(#function)() *** ERROR: \(error)")
        }
        setDocumentEdited(false)
    }

    public func revertResource(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        undoManager?.disableUndoRegistration()
        do {
            nfnt = try NFNT(with: resource)
            objcFontType = nfnt.fontType.rawValue
            objcBitDepth = objcFontType & ~0xFFF3
        } catch {
            NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
        }
        undoManager?.removeAllActions()
        setDocumentEdited(false)
        undoManager?.enableUndoRegistration()
        previewView.nfnt = nfnt
        loadResource()
    }

    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
//        NSLog("\(type(of: self)).\(#function) keyPath == \(keyPath)")
        if !Self.nfntKeyPaths.contains(keyPath) && !Self.keyPaths.contains(keyPath) {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if context == &Self.nfntContext {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.nfnt.setValue(change![.oldKey], forKeyPath: keyPath)
            })
        } else {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.setValue(change![.oldKey], forKeyPath: keyPath)
                if keyPath == "objcBitDepth" {
                    let tag = change![.oldKey] as! UInt16
                    $0.undoManager?.disableUndoRegistration()
                    $0.objcFontType = (self.objcFontType & ~12) | tag
                    $0.undoManager?.enableUndoRegistration()
                }
            })
        }
        window?.isDocumentEdited = true
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
        } else if keyPath == "objcFontType" {
            undoManager?.setActionName(NSLocalizedString("Change Font Type", comment: ""))
        } else if keyPath == "objcBitDepth" {
            undoManager?.setActionName(NSLocalizedString("Change Bit Depth", comment: ""))
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

// MARK: - <PreviewProvider>
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
