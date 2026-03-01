//
//  ViewController_vhea.swift
//  FontEditor
//
//  Created by Mark Douma on 3/1/2026.
//

import Cocoa
import CoreFont

final class ViewController_vhea: FontTableViewController, NSControlTextEditingDelegate {
    @IBOutlet weak var ascenderField:   NSTextField!
    @IBOutlet weak var descenderField:  NSTextField!
    @IBOutlet weak var lineGapField:    NSTextField!

    var table:      FontTable_vhea

    private static var tableContext = 1
    private static let tableKeyPaths = Set(["version", "vertTypoAscender", "vertTypoDescender", "vertTypoLineGap",
        "advanceHeightMax", "minTopSideBearing", "minBottomSideBearing", "yMaxExtent", "caretSlopeRise",
        "caretSlopeRun", "carretOffset", "reserved0", "reserved1", "reserved2", "reserved3",
        "metricDataFormat", "numberOfVMetrics"])

    required init?(with fontTable: FontTable) {
        table = fontTable as! FontTable_vhea
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
        updateUI()
    }

    override var representedObject: Any? {
        didSet {
            self.table = self.representedObject as! FontTable_vhea
        }
    }

    @IBAction func changeVersion(_ sender: Any) {
        updateUI()
    }

    override func updateUI() {
        if table.version == .version1_0 {
            ascenderField.stringValue = NSLocalizedString("ascender:", comment: "")
            descenderField.stringValue = NSLocalizedString("descender:", comment: "")
            lineGapField.stringValue = NSLocalizedString("lineGap:", comment: "")
        } else {
            ascenderField.stringValue = NSLocalizedString("vertTypoAscender:", comment: "")
            descenderField.stringValue = NSLocalizedString("vertTypoDescender:", comment: "")
            lineGapField.stringValue = NSLocalizedString("vertTypoLineGap:", comment: "")
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
            case "vertTypoAscender":
                undoManager?.setActionName(NSLocalizedString("Change Typo Ascender", comment: ""))
            case "vertTypoDescender":
                undoManager?.setActionName(NSLocalizedString("Change Typo Descender", comment: ""))
            case "vertTypoLineGap":
                undoManager?.setActionName(NSLocalizedString("Change Typo Line Gap", comment: ""))
            case "advanceHeightMax":
                undoManager?.setActionName(NSLocalizedString("Change Advance Height Max", comment: ""))
            case "minTopSideBearing":
                undoManager?.setActionName(NSLocalizedString("Change Min Top Side Bearing", comment: ""))
            case "minBottomSideBearing":
                undoManager?.setActionName(NSLocalizedString("Change Min Bottom Side Bearing", comment: ""))
            case "yMaxExtent":
                undoManager?.setActionName(NSLocalizedString("Change Y Max Extent", comment: ""))
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
            case "numberOfVMetrics":
                undoManager?.setActionName(NSLocalizedString("Change Number of Metrics", comment: ""))
            default:
                break
        }
    }
}
