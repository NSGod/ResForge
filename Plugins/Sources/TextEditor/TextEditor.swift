import Cocoa
import RFSupport
import CoreFont

public class TextEditor: AbstractEditor, ResourceEditor, NSTextViewDelegate {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "TEXT"
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    @IBOutlet weak var textView:            NSTextView!
    @IBOutlet weak var styleControl:        NSSegmentedControl!
    @IBOutlet weak var widthControl:        NSSegmentedControl!
    @IBOutlet weak var colorWell:           NSColorWell!
    @IBOutlet weak var fontPopUpButton:     NSPopUpButton!
    @IBOutlet weak var sizeComboBox:        NSComboBox!

    public let resource: Resource
    private let manager: RFEditorManager

    var style:          Styl!
    var textStorage:    StylTextStorage!

    private var selectedWidthTag = 0

    public override var windowNibName: String {
        return "TextEditor"
    }

    public required init(resource: Resource, manager: RFEditorManager) {
        self.resource = resource
        self.manager = manager
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func windowDidLoad() {
        styleControl.setImage(NSImage(contentsOf: Self.bundle.url(forResource: "outline", withExtension: "pdf")!), forSegment: 3)
        widthControl.setImage(NSImage(contentsOf: Self.bundle.url(forResource: "condensed", withExtension: "pdf")!), forSegment: 0)
        widthControl.setImage(NSImage(contentsOf: Self.bundle.url(forResource: "extended", withExtension: "pdf")!), forSegment: 1)

        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: NSTextStorage.didProcessEditingNotification, object: self.textView.textStorage)

        loadResourceIntoView()
    }

    @IBAction public func saveResource(_ sender: Any) {
//        do {
            resource.data = textView.string.data(using: .macOSRoman, allowLossyConversion: true) ?? Data()
//        } catch {
//            self.window?.presentError(error)
//        }
        self.setDocumentEdited(false)
    }

    /// Revert the resource to its on-disk state.
    @IBAction public func revertResource(_ sender: Any) {
        self.window?.contentView?.undoManager?.removeAllActions()
        loadResourceIntoView()
    }

    func loadResourceIntoView() {
        textStorage = StylTextStorage()
        textView.layoutManager?.replaceTextStorage(textStorage)
        textView.string = String(data: resource.data, encoding: .macOSRoman) ?? ""

        do {
            if let styleResource = manager.findResource(type: ResourceType("styl"), id: resource.id, currentDocumentOnly: true) {
                // TODO: Convert MacRoman byte offsets to UTF8 offsets.
                style = try Styl(with: styleResource, count: resource.data.count)
                for run in style.runs {
                    textView.textStorage?.addAttributes(run.style.attrs, range: run.range)
                }
            }
        } catch {
            self.window?.presentError(error)
        }

        self.setDocumentEdited(false)
    }

    @IBAction func changeStyle(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")

    }

    @IBAction func changeWidth(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        /// make the condensed/extended choices mutually-exclusive, like radio buttons
        if widthControl.isSelected(forSegment: 0) {
            if selectedWidthTag == 64 {
                widthControl.setSelected(false, forSegment: 1)
            }
        }
        if widthControl.isSelected(forSegment: 1) {
            if selectedWidthTag == 32 {
                widthControl.setSelected(false, forSegment: 0)
            }
        }
        selectedWidthTag = widthControl.tag(forSegment: widthControl.selectedSegment)

    }

    @IBAction func changeFont(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")

    }

    @IBAction func changeColor(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")

    }

    @IBAction func changeFontSize(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")

    }

    public func textView(_ textView: NSTextView, willChangeSelectionFromCharacterRanges oldSelectedCharRanges: [NSValue], toCharacterRanges newSelectedCharRanges: [NSValue]) -> [NSValue] {
        // NSLog("\(type(of: self)).\(#function) old == \(oldSelectedCharRanges), new == \(newSelectedCharRanges)")
        /// We want only a contiguous selection
        if newSelectedCharRanges.isEmpty {
            return newSelectedCharRanges
        }
        var totalRange: NSRange = .init()
        for range in newSelectedCharRanges {
            if totalRange == .init() {
                totalRange = range.rangeValue
            } else {
                totalRange = totalRange.union(range.rangeValue)
            }
        }
        return [NSValue(range: totalRange)]
    }

    @objc public func textViewDidChangeSelection(_ notification: Notification) {
        // NSLog("\(type(of: self)).\(#function) notification == \(notification)")
        let ranges: [NSRange] = textView.selectedRanges.map(\.rangeValue)
        if !ranges.isEmpty {
            var totalRange: NSRange = .init()
            for range in ranges {
                if totalRange == .init() {
                    totalRange = range
                } else {
                    totalRange = totalRange.union(range)
                }
            }
            if let textStorage {
                if totalRange.location >= textStorage.length {
                    return
                }
                let attrs = textStorage.attributes(at: totalRange.location, effectiveRange: nil)
                if let style = attrs[.stylStyle] as? Styl.Style {
                    for i in 0..<styleControl.segmentCount {
                        styleControl.setSelected(style.fontStyle.contains(MacFontStyle(rawValue: UInt16(styleControl.tag(forSegment: i)))), forSegment: i)
                    }
                    selectedWidthTag = 0
                    for i in 0..<widthControl.segmentCount {
                        widthControl.setSelected(style.fontStyle.contains(MacFontStyle(rawValue: UInt16(widthControl.tag(forSegment: i)))), forSegment: i)
                        if widthControl.isSelected(forSegment: i) {
                            selectedWidthTag = widthControl.tag(forSegment: i)
                        }
                    }
                    sizeComboBox.objectValue = style.fontPointSize
                    if style.fontStyle.contains(.shadow) {
                        if let shadow = attrs[.shadow] as? NSShadow, let color = shadow.shadowColor {
                            colorWell.color = color
                        }
                    } else {
                        colorWell.color = attrs[.foregroundColor] as! NSColor
                    }
                    if let font = attrs[.font] as? NSFont {
                        fontPopUpButton.selectItem(withTag: Int(FOND.fontFamilyID(for: font)))
                    }
                }
            }
        }
    }

    func selectedRange() -> NSRange? {
        textView.selectedRanges.first?.rangeValue
    }

    @objc func textFieldDidChange(_ notification: Notification) {
        self.setDocumentEdited(true)
    }
}
