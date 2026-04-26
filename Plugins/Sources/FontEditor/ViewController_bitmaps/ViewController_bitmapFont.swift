//
//  ViewController_bitmapFont.swift
//  FontEditor
//
//  Created by Mark Douma on 3/27/2026.
//

import Cocoa
import CoreFont
import RFSupport

final class ViewController_bitmapFont: FontTableViewController, NSTableViewDelegate {
    @IBOutlet weak var imageView:       CustomImageView!
    @IBOutlet var strikesController:    NSArrayController!
    @IBOutlet var glyphsController:     NSArrayController!

    @IBOutlet weak var tableView:       NSTableView!
    @IBOutlet weak var glyphsTableView: NSTableView!
    
    var blocTable:              FontTable_bloc
    var bdatTable:              FontTable_bdat

    @objc dynamic var strikes:  [FEBitmapStrike]

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    required init?(with fontTable: FontTable) {
        if fontTable is FontTable_bloc {
            blocTable = fontTable as! FontTable_bloc
            guard let bdatTable = blocTable.bdatTable else {
                NSLog("\(type(of: self)).\(#function) unexpected nil bdatTable")
                return nil
            }
            self.bdatTable = bdatTable
        } else {
            bdatTable = fontTable as! FontTable_bdat
            guard let blocTable = bdatTable.blocTable else {
                NSLog("\(type(of: self)).\(#function) unexpected nil blocTable")
                return nil
            }
            self.blocTable = blocTable
        }
        strikes = FEBitmapStrike.bitmapStrikes(with: bdatTable.bitmapStrikes)
        super.init(with: fontTable)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: <NSTableViewDelegate>
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tv = notification.object as? NSTableView, tv == glyphsTableView {
            let uiGlyph = glyphsController.selectedObjects.first! as! FEBitmapGlyph
            let image = uiGlyph.glyph.image
            imageView.image = image
        }
    }
}
