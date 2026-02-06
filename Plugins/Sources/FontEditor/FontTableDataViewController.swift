//
//  FontTableDataViewController.swift
//  FontEditor
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont
import HexFiend

struct HFDefaults {
    static let fontSize = "HFDefaultFontSize"
//    static let statusBarMode = "HFStatusBarDefaultMode" // This is defined and used by HexFiend automatically, it's just here for reference
}

// generic data viewer for non-specialized viewers
final class FontTableDataViewController: FontTableViewController {
    @IBOutlet weak var textView:    HFTextView!

    @IBOutlet var findView:         NSView!
    @IBOutlet var findField:        NSTextField!
    @IBOutlet var replaceField:     NSTextField!
    @IBOutlet var wrapAround:       NSButton!
    @IBOutlet var ignoreCase:       NSButton!
    @IBOutlet var searchText:       NSButton!
    @IBOutlet var searchHex:        NSButton!

    var hexController:              HFController?
    var table:                      FontTable

    required init?(with fontTable: FontTable) {
        UserDefaults.standard.register(defaults: [HFDefaults.fontSize: 10])
        table = fontTable
        super.init(with: fontTable)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        findView.isHidden = true

        let lineCountingRepresenter = HFLineCountingRepresenter()
        lineCountingRepresenter.lineNumberFormat = .hexadecimal
        let statusBarRepresenter = HFStatusBarRepresenter()

        textView.layoutRepresenter.addRepresenter(lineCountingRepresenter)
        textView.layoutRepresenter.addRepresenter(statusBarRepresenter)
        textView.controller.addRepresenter(lineCountingRepresenter)
        textView.controller.addRepresenter(statusBarRepresenter)
        let fontSize = UserDefaults.standard.integer(forKey: HFDefaults.fontSize)
        textView.controller.font = NSFont.userFixedPitchFont(ofSize: CGFloat(fontSize))!
        textView.data = table.tableData
        textView.controller.undoManager = self.view.window?.windowController?.undoManager
        textView.layoutRepresenter.performLayout()
        textView.delegate = self

        updateUI()
    }

    // MARK: - <HFTextViewDelegate>
    func hexTextView(_ view: HFTextView, didChangeProperties properties: HFControllerPropertyBits) {
        if properties.contains(.contentValue) {
            self.view.window?.windowController?.setDocumentEdited(true)
//            self.setDocumentEdited(true)
        }
    }

    override func updateUI() {
        NSLog("\(type(of: self)).\(#function) '\(table.tableTag.fourCharString)'")
    }

}
