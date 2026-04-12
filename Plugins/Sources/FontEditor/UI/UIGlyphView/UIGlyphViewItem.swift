//
//  UIGlyphViewItem.swift
//  FontEditor
//
//  Created by Mark Douma on 4/9/2026.
//

import Cocoa

public class UIGlyphViewItem: NSCollectionViewItem {
    @IBOutlet var backgroundView:   UIGlyphBackgroundView!
    @IBOutlet var glyphView:        UIGlyphView!

    /// for maintaining aspect ratio:
    public var originalSize: NSSize = .zero

    public override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        originalSize = self.view.frame.size
    }

    public override var isSelected: Bool {
        didSet {
            backgroundView.isSelected = isSelected
        }
    }
}
