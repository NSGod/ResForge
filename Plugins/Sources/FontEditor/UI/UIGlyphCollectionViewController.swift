//
//  UIGlyphCollectionViewController.swift
//  FontEditor
//
//  Created by Mark Douma on 4/9/2026.
//

import Cocoa
import CoreFont

public final class UIGlyphCollectionViewController: NSViewController, NSWindowDelegate {

    @IBOutlet weak var collectionView:  NSCollectionView!
    @IBOutlet var glyphsController:     NSArrayController!

    @IBInspectable public var itemSizeAutosaveName: String?

    public var glyphsProvider:          UIGlyphsProvider!
    public var glyphs:                  [UIGlyph] = []

    public var itemSize:                CGFloat = 128.0 {
        didSet {
            collectionView.reloadData()
        }
    }

    public var aspectRatio:             CGFloat = 1.0 // height to width; usually >= 1.0

    private var _haveSetupWindowObserving = false

    private static let itemSizeKey = "UIGlyphCollectionViewController.itemSize"

    private static let largeIdentifier = NSUserInterfaceItemIdentifier(NSStringFromClass(UIGlyphViewItemLarge.self))
    private static let smallIdentifier = NSUserInterfaceItemIdentifier(NSStringFromClass(UIGlyphViewItemSmall.self))

    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        UserDefaults.standard.register(defaults: [Self.itemSizeKey: 128.0])
        NSUserDefaultsController.shared.initialValues = [Self.itemSizeKey: 128.0]
        super.init(nibName: "UIGlyphCollectionViewController", bundle: .module)
    }

    public convenience init(glyphsProvider: UIGlyphsProvider, itemSizeAutosaveName: String? = nil) {
        self.init(nibName: "UIGlyphCollectionViewController", bundle: .module)
        self.itemSizeAutosaveName = itemSizeAutosaveName
        self.glyphsProvider = glyphsProvider
        self.glyphs = glyphsProvider.glyphs
        if let itemSizeAutosaveName {
            UserDefaults.standard.register(defaults: [Self.itemSizeKey + " \(itemSizeAutosaveName)": 128.0])
            NSUserDefaultsController.shared.initialValues = [Self.itemSizeKey + " \(itemSizeAutosaveName)": 128.0]
            itemSize = UserDefaults.standard.double(forKey: Self.itemSizeKey + " \(itemSizeAutosaveName)")
        } else {
            itemSize = UserDefaults.standard.double(forKey: Self.itemSizeKey)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UIGlyphViewItemLarge.self, forItemWithIdentifier: Self.largeIdentifier)
        collectionView.register(UIGlyphViewItemSmall.self, forItemWithIdentifier: Self.smallIdentifier)
        collectionView.reloadData()
    }

    public override func viewDidAppear() {
        super.viewDidAppear()
        if !_haveSetupWindowObserving {
            NotificationCenter.default.addObserver(self, selector: #selector(windowWillClose(_:)), name: NSWindow.didResizeNotification, object: view.window)
            _haveSetupWindowObserving = true
        }
    }

    public func windowWillClose(_ notification: Notification) {
        if let itemSizeAutosaveName {
            UserDefaults.standard.set(itemSize, forKey: Self.itemSizeKey + " \(itemSizeAutosaveName)")
        } else {
            UserDefaults.standard.set(itemSize, forKey: Self.itemSizeKey)
        }
    }

    @IBAction func search(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        collectionView.reloadData()
    }
}

extension UIGlyphCollectionViewController: NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return (glyphsController.arrangedObjects as! [UIGlyph]).count
    }
    
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let glyphViewItem: UIGlyphViewItem
        if itemSize >= 128 {
            glyphViewItem = collectionView.makeItem(withIdentifier: Self.largeIdentifier, for: indexPath) as! UIGlyphViewItem
        } else {
            glyphViewItem = collectionView.makeItem(withIdentifier: Self.smallIdentifier, for: indexPath) as! UIGlyphViewItem
        }
        aspectRatio = glyphViewItem.originalSize.height / glyphViewItem.originalSize.width
        let glyph = (glyphsController.arrangedObjects as! [UIGlyph])[indexPath._index(at: 1)]
        glyphViewItem.glyphView.glyph = glyph
        glyphViewItem.representedObject = glyph
        return glyphViewItem
    }

    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
        return NSMakeSize(itemSize, itemSize)
    }

    public func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return itemSize >= 128.0 ? 10.0 : 0.0
    }
}
