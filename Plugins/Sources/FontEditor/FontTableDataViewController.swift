//
//  FontTableDataViewController.swift
//  FontEditor
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont
import HexFiend

// generic data viewer for non-specialized viewers
final public class FontTableDataViewController: FontTableViewController {

    @IBOutlet weak var box:         NSBox!

    var hexController:              HFController?
    var table:                      FontTable?

    required init?(with fontTable: FontTable) {
        table = fontTable
        super.init(with: fontTable)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    private func updateUI() {
        NSLog("\(type(of: self)).\(#function)")
        guard let hexController else {
            guard let table else {
                // if no data, add empty view
                let view = NSView(frame: NSMakeRect(0.0, 0.0, 20.0, 20.0))
                box.contentView = view
                return
            }
            hexController = HFController()
            let byteSlice = HFSharedMemoryByteSlice(unsharedData: table.tableData)
            let byteArray = HFBTreeByteArray(byteSlice: byteSlice)
            hexController?.byteArray = byteArray
            let layoutRep = HFLayoutRepresenter()
            let hexRep = HFHexTextRepresenter()
            let asciiRep = HFStringEncodingTextRepresenter()
            let scrollRep = HFVerticalScrollerRepresenter()
            hexController?.addRepresenter(layoutRep)
            hexController?.addRepresenter(hexRep)
            hexController?.addRepresenter(asciiRep)
            hexController?.addRepresenter(scrollRep)
            layoutRep.addRepresenter(hexRep)
            layoutRep.addRepresenter(asciiRep)
            layoutRep.addRepresenter(scrollRep)
            box.contentView = layoutRep.view()
            return
        }
        guard let table else {
            // if no data, add empty view
            let view = NSView(frame: NSMakeRect(0.0, 0.0, 20.0, 20.0))
            box.contentView = view
            return
        }
        let byteSlice = HFSharedMemoryByteSlice(unsharedData: table.tableData)
        let byteArray = HFBTreeByteArray(byteSlice: byteSlice)
        hexController.byteArray = byteArray
    }
}
