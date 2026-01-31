//
//  FontTableViewController.swift
//  FontEditor
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont

// abstract superclass
class FontTableViewController: NSViewController {

    required init?(with fontTable: FontTable) {
        super.init(nibName: (NSStringFromClass(Self.self) as NSString).pathExtension, bundle: Bundle.module)
        self.representedObject = fontTable
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    static func `class`(for tableTag: TableTag) -> FontTableViewController.Type {
        if tableTag == .OS_2 { return ViewController_OS2.self }
//        if tableTag == .CFF_ { return ViewController_CFF.self }
//        if tableTag == .cvt_ { return ViewController_CVT.self }
        if let theClass: FontTableViewController.Type = (NSClassFromString("FontEditor.ViewController_\(tableTag.fourCharString)")) as? FontTableViewController.Type {
            return theClass
        }
        return FontTableDataViewController.self
    }
}
