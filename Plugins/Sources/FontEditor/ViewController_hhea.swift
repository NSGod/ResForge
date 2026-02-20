//
//  ViewController_hhea.swift
//  FontEditor
//
//  Created by Mark Douma on 1/26/2026.
//

import Cocoa
import CoreFont

final class ViewController_hhea: FontTableViewController, NSControlTextEditingDelegate {
    var table:      FontTable_hhea

    private static var tableContext = 1
    private static let tableKeyPaths = Set(["version", "ascender", "descender", "lineGap",
        "advanceWidthMax", "minLeftSideBearing", "minRightSideBearing", "xMaxExtent", "caretSlopeRise",
        "caretSlopeRun", "carretOffset", "reserved0", "reserved1", "reserved2", "reserved3",
        "metricDataFormat", "numberOfHMetrics"])

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_hhea
        super.init(with: fontTable)
    }

    deinit {
        Self.tableKeyPaths.forEach { table.removeObserver(self, forKeyPath: $0, context: &Self.tableContext) }
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Self.tableKeyPaths.forEach { table.addObserver(self, forKeyPath: $0, options: [.new, .old], context: &Self.tableContext) }
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_hhea
        }
    }

    // MARK: - <NSControlTextEditingDelegate>
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if fieldEditor.string.isEmpty { return false }
        return true
    }

    // MARK: -
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath else {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
//        NSLog("\(type(of: self)).\(#function) keyPath: \(keyPath)")
        if !Self.tableKeyPaths.contains(keyPath) {
            return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        if context == &Self.tableContext {
            undoManager?.registerUndo(withTarget: self, handler: {
                $0.table.setValue(change![.oldKey], forKey: keyPath)
            })
        }
        view.window?.isDocumentEdited = true
        switch keyPath {
            case "version":
                undoManager?.setActionName(NSLocalizedString("Change Version", comment: ""))
            case "ascender":
                undoManager?.setActionName(NSLocalizedString("Change Ascender", comment: ""))
            case "descender":
                undoManager?.setActionName(NSLocalizedString("Change Descender", comment: ""))
            case "lineGap":
                undoManager?.setActionName(NSLocalizedString("Change Line Gap", comment: ""))
            case "advanceWidthMax":
                undoManager?.setActionName(NSLocalizedString("Change Advance Width Max", comment: ""))
            case "minLeftSideBearing":
                undoManager?.setActionName(NSLocalizedString("Change Min Left Side Bearing", comment: ""))
            case "minRightSideBearing":
                undoManager?.setActionName(NSLocalizedString("Change Min Right Side Bearing", comment: ""))
            case "xMaxExtent":
                undoManager?.setActionName(NSLocalizedString("Change X Max Extent", comment: ""))
            case "caretSlopeRise":
                undoManager?.setActionName(NSLocalizedString("Change Caret Slope Rise", comment: ""))
            case "caretSlopeRun":
                undoManager?.setActionName(NSLocalizedString("Change Caret Slope Run", comment: ""))
            case "carretOffset":
                undoManager?.setActionName(NSLocalizedString("Change Caret Offset", comment: ""))
            case "reserved0", "reserved1", "reserved2", "reserved3":
                undoManager?.setActionName(NSLocalizedString("Change Reserved", comment: ""))
            case "metricDataFormat":
                undoManager?.setActionName(NSLocalizedString("Change Metric Data Format", comment: ""))
            case "numberOfHMetrics":
                undoManager?.setActionName(NSLocalizedString("Change Number of Metrics", comment: ""))
            default:
                break
        }
    }
}
