//
//  ViewController_post.swift
//  FontEditor
//
//  Created by Mark Douma on 1/22/2026.
//

import Cocoa
import CoreFont

final class ViewController_post: FontTableViewController {
    var table:                FontTable_post

    private static var tableContext = 1
    private static let tableKeyPaths = Set(["version", "italicAngle", "underlinePosition",
                "underlineThickness", "isFixedPitch", "minMemType42", "maxMemType42",
                 "minMemType1", "maxMemType1"])

    required init?(with fontTable: FontTable) {
        self.table = fontTable as! FontTable_post
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
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_post
        }
    }

    override func prepareToSave() throws {
        NSLog("\(type(of: self)).\(#function)")
        if let window = view.window {
            if !window.makeFirstResponder(nil) {
                NSLog("\(type(of: self)).\(#function): could not commit editing")
            }
        }
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
            })
            view.window?.isDocumentEdited = true
            switch keyPath {
                case "version":
                    undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
                case "italicAngle":
                    undoManager?.setActionName(NSLocalizedString("Change Italic Angle", comment: ""))
                case "underlinePosition":
                    undoManager?.setActionName(NSLocalizedString("Change Underline Position", comment: ""))
                case "underlineThickness":
                    undoManager?.setActionName(NSLocalizedString("Change Underline Thickness", comment: ""))
                case "isFixedPitch":
                    undoManager?.setActionName(NSLocalizedString("Change Fixed Pitch", comment: ""))
                case "minMemType42":
                    undoManager?.setActionName(NSLocalizedString("Change Minimum Memory Type 42", comment: ""))
                case "maxMemType42":
                    undoManager?.setActionName(NSLocalizedString("Change Maximum Memory Type 42", comment: ""))
                case "minMemType1":
                    undoManager?.setActionName(NSLocalizedString("Change Minimum Memory Type 1", comment: ""))
                case "maxMemType1":
                    undoManager?.setActionName(NSLocalizedString("Change Maximum Memory Type 1", comment: ""))
                default:
                    break
            }
        }
    }
}
