//
//  FontTableViewController.swift
//  Plugins
//
//  Created by Mark Douma on 1/19/2026.
//

import Cocoa
import CoreFont

// abstract superclass
public class FontTableViewController: NSViewController {

    required init?(with fontTable: FontTable) {
        let mainBundle = Bundle.main
        NSLog("\(type(of: self)).\(#function) mainBundle.path == \(mainBundle.bundleURL.path)")
        let ourBundle = Bundle(for: Self.self)
        NSLog("\(type(of: self)).\(#function) ourBundle.path == \(ourBundle.bundleURL.path)")

        let className = NSStringFromClass(Self.self)
        NSLog("\(type(of: self)).\(#function) className == \(className)")
        super.init(nibName: (NSStringFromClass(Self.self) as NSString).pathExtension, bundle: nil)
        self.representedObject = fontTable
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }

    public static func `class`(for tableTag: TableTag) -> FontTableViewController.Type {
//        if tableTag == .OS_2 { return ViewController_OS2.self }
//        if tableTag == .CFF_ { return ViewController_CFF.self }
//        if tableTag == .cvt_ { return ViewController_CVT.self }
        if let theClass: FontTableViewController.Type = (NSClassFromString("FontEditor.ViewController_\(tableTag.fourCharString)")) as? FontTableViewController.Type {
            return theClass
        }
        return FontTableDataViewController.self
    }
}
