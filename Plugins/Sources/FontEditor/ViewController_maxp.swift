//
//  ViewController_maxp.swift
//  FontEditor
//
//  Created by Mark Douma on 1/21/2026.
//

import Cocoa
import CoreFont

final class ViewController_maxp: FontTableViewController {
	@IBOutlet weak var version1View:    NSView!

	var table:                          FontTable_maxp

    private static var tableContext = 1
    private static let tableKeyPaths = Set(["version", "numGlyphs", "maxPoints", "maxContours",
        "maxCompositePoints", "maxCompositeContours", "maxZones", "maxTwilightPoints",
        "maxStorage", "maxFunctionDefs", "maxInstructionDefs", "maxStackElements", "maxSizeOfInstructions",
        "maxComponentElements", "maxComponentDepth"])

	required init?(with fontTable: FontTable) {
		self.table = fontTable as! FontTable_maxp
		super.init(with: fontTable)
	}

    @MainActor required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

    deinit {
        Self.tableKeyPaths.forEach { table.removeObserver(self, forKeyPath: $0, context: &Self.tableContext) }
    }

	override func viewDidLoad() {
        super.viewDidLoad()
        Self.tableKeyPaths.forEach { table.addObserver(self, forKeyPath: $0, options: [.new, .old], context: &Self.tableContext) }
        updateUI()
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_maxp
            updateUI()
        }
    }

    override func prepareToSave() throws {
        NSLog("\(type(of: self)).\(#function)")
    }

    override func updateUI() {
        // allow us to be called before nib is loaded
        guard let version1View else { return }
        for control: NSControl in version1View.subviews as? [NSControl] ?? [] {
            control.isEnabled = table.version == .version1_0
        }
    }

    @IBAction func changeVersion(_ sender: Any) {
        updateUI()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if !Self.tableKeyPaths.contains(keyPath) {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if context == &Self.tableContext {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.setValue(change![.oldKey], forKeyPath: keyPath)
                if keyPath == "version" { $0.updateUI() }
            })
        }
        view.window?.isDocumentEdited = true
        if keyPath == "version" {
            undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
        } else if keyPath == "numGlyphs" {
            undoManager?.setActionName(NSLocalizedString("Change Number of Glyphs", comment: ""))
        } else if keyPath == "maxPoints" {
            undoManager?.setActionName(NSLocalizedString("Change Max Number of Points", comment: ""))
        } else if keyPath == "maxContours" {
            undoManager?.setActionName(NSLocalizedString("Change Max Number of Contours", comment: ""))
        } else if keyPath == "maxCompositePoints" {
            undoManager?.setActionName(NSLocalizedString("Change Max Number of Composite Points", comment: ""))
        } else if keyPath == "maxCompositeContours" {
            undoManager?.setActionName(NSLocalizedString("Change Max Number of Composite Contours", comment: ""))
        } else if keyPath == "maxZones" {
            undoManager?.setActionName(NSLocalizedString("Change Max Number of Zones", comment: ""))
        } else if keyPath == "maxTwilightPoints" {
            undoManager?.setActionName(NSLocalizedString("Change Max Number of Twilight Points", comment: ""))
        } else if keyPath == "maxStorage" {
            undoManager?.setActionName(NSLocalizedString("Change Max Storage", comment: ""))
        } else if keyPath == "maxFunctionDefs" {
            undoManager?.setActionName(NSLocalizedString("Change Max Function Defs", comment: ""))
        } else if keyPath == "maxInstructionDefs" {
            undoManager?.setActionName(NSLocalizedString("Change Max Instruction Defs", comment: ""))
        } else if keyPath == "maxStackElements" {
            undoManager?.setActionName(NSLocalizedString("Change Max Stack Elements", comment: ""))
        } else if keyPath == "maxSizeOfInstructions" {
            undoManager?.setActionName(NSLocalizedString("Change Max Size of Instructions", comment: ""))
        } else if keyPath == "maxComponentElements" {
            undoManager?.setActionName(NSLocalizedString("Change Max Component Elements", comment: ""))
        } else if keyPath == "maxComponentDepth" {
            undoManager?.setActionName(NSLocalizedString("Change Max Component Depth", comment: ""))
        }
    }

}
