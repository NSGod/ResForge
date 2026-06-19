import Cocoa
import RFSupport
import CoreFont

extension NSRange {
    static let empty: NSRange = .init(location: 0, length: 0)

    var isEmpty: Bool {
        self == NSRange(location: 0, length: 0)
    }
}

public class TextEditor: AbstractEditor, ResourceEditor, NSTextViewDelegate {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "TEXT"
    ]
    public static func register() {
        PluginRegistry.register(self)
    }

    @IBOutlet weak var textView:                NSTextView!
    @IBOutlet weak var styleControl:            NSSegmentedControl!
    @IBOutlet weak var widthControl:            NSSegmentedControl!
    @IBOutlet weak var colorWell:               NSColorWell!
    @IBOutlet weak var fontPopUpButton:         NSPopUpButton!
    @IBOutlet weak var sizeComboBox:            NSComboBox!

    public let resource: Resource
    private let manager: RFEditorManager

    var stylResource:   Resource!
    var style:          Styl!
    var textStorage:    Styl.TextStorage!
    var currentStyle:   Styl.Style

    var selectedRange: NSRange {
        /// I think this should be safe?:
        return textView.selectedRanges.first!.rangeValue
    }

    var configuredStyle: Styl.Style {
        let obj = sizeComboBox.objectValue as? String ?? "12"
        let fontPointSize = Int(obj) ?? 12
        return .init(fontFamilyID: ResID(fontPopUpButton.selectedTag()), fontStyle: selectedFontStyle, fontPointSize: fontPointSize, color: colorWell.color)
    }

    var configuredAttrs: [NSAttributedString.Key: Any] {
        return [.stylStyle: configuredStyle]
    }

    var selectedFontStyle: MacFontStyle {
        var style = MacFontStyle.normal
        for i in 0..<styleControl.segmentCount {
            if styleControl.isSelected(forSegment: i) {
                style.formUnion(MacFontStyle(rawValue: UInt16(styleControl.tag(forSegment: i))))
            }
        }
        for i in 0..<widthControl.segmentCount {
            if widthControl.isSelected(forSegment: i) {
                style.formUnion(MacFontStyle(rawValue: UInt16(widthControl.tag(forSegment: i))))
            }
        }
        return style
    }

    private var selectedWidthTag = 0

    public override var windowNibName: String {
        return "TextEditor"
    }

    public required init(resource: Resource, manager: RFEditorManager) {
        self.resource = resource
        self.manager = manager
        currentStyle = .default
        super.init(window: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func windowDidLoad() {
        styleControl.setImage(NSImage(contentsOf: Self.bundle.url(forResource: "outline", withExtension: "pdf")!), forSegment: 3)
        widthControl.setImage(NSImage(contentsOf: Self.bundle.url(forResource: "condensed", withExtension: "pdf")!), forSegment: 0)
        widthControl.setImage(NSImage(contentsOf: Self.bundle.url(forResource: "extended", withExtension: "pdf")!), forSegment: 1)

        loadResourceIntoView()
    }

    @IBAction public func saveResource(_ sender: Any) {
        do {
            resource.data = textView.string.data(using: .macOSRoman, allowLossyConversion: true) ?? Data()
            if let txtStorage = textView.textStorage as? Styl.TextStorage {
                style.runs = txtStorage.styleRuns
                stylResource.data = try style.data()
            }
        } catch {
            self.window?.presentError(error)
        }
        self.setDocumentEdited(false)
    }

    /// Revert the resource to its on-disk state.
    @IBAction public func revertResource(_ sender: Any) {
        self.window?.contentView?.undoManager?.removeAllActions()
        loadResourceIntoView()
        self.setDocumentEdited(false)
    }

    func loadResourceIntoView() {
        NotificationCenter.default.removeObserver(self, name: NSTextStorage.didProcessEditingNotification, object: textView.textStorage)
        textStorage = Styl.TextStorage()
        textView.layoutManager?.replaceTextStorage(textStorage)
        /// get style stuff loaded before setting `textView.string`
        do {
            if let stylResource = manager.findResource(type: .styl, id: resource.id, currentDocumentOnly: true) {
                // TODO: Convert MacRoman byte offsets to UTF8 offsets.
                self.stylResource = stylResource
                style = try Styl(with: stylResource, count: resource.data.count)
            } else {
                if resource.data.isEmpty {
                    /// we're newly-created
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        /// schedule creating the cooresponding `styl` resource on the next event loop to allow
                        /// first call to EditorManager.createResource to finish
                        self.manager.createResource(type: .styl, id: resource.id) { stylRes in
                            self.stylResource = stylRes
                            do {
                                self.style = try Styl(with: self.stylResource, count: self.resource.data.count)
                            } catch {
                                NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                            }
                        }
                    }
                }
            }
        } catch {
            self.window?.presentError(error)
        }

        /// this causes `textViewDidChangeSelection()` to be called
        textView.string = String(data: resource.data, encoding: .macOSRoman) ?? ""
        if let style {
            for run in style.runs {
                textView.textStorage?.addAttributes(run.style.attrs, range: run.range)
            }
        }
        /// resend a synthesized `textViewDidChangeSelection()` event so the UI can be updated for selected text which now has proper `.stylStyle` information
        textViewDidChangeSelection(Notification(name: NSTextView.didChangeSelectionNotification, object: textView))
        window?.makeFirstResponder(textView)
        NotificationCenter.default.addObserver(self, selector: #selector(didProcessEditing(_:)), name: NSTextStorage.didProcessEditingNotification, object: textView.textStorage)
    }

    @IBAction func changeStyle(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        changeAttributes(sender)
    }

    @IBAction func changeWidth(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        /// make the condensed/extended choices mutually-exclusive, like radio buttons
        if widthControl.isSelected(forSegment: 0) {
            if selectedWidthTag == 32 {
                /// currently on, turn off
                widthControl.setSelected(false, forSegment: 0)
                selectedWidthTag = -1
            } else {
                widthControl.setSelected(false, forSegment: 1)
                selectedWidthTag = 32
            }
        }
        if widthControl.isSelected(forSegment: 1) {
            if selectedWidthTag == 64 {
                /// currently on, turn off
                widthControl.setSelected(false, forSegment: 1)
                selectedWidthTag = -1
            } else {
                widthControl.setSelected(false, forSegment: 0)
                selectedWidthTag = 64
            }
        }
        changeAttributes(sender)
    }

    @IBAction func changeFont(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        changeAttributes(sender)
    }

    @IBAction func changeColor(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        changeAttributes(sender)
    }

    @IBAction func changeFontSize(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        changeAttributes(sender)
    }

    @IBAction func changeLineHeight(_ sender: Any) {
        NSLog("\(type(of: self)).\(#function)")
        changeAttributes(sender)
    }

    func changeAttributes(_ sender: Any) {
        if selectedRange.location >= textStorage.length {
            currentStyle = configuredStyle
        } else {
            setAttributes(configuredAttrs, range: selectedRange)
        }
    }

    func setAttributes(_ attributes: [NSAttributedString.Key: Any], range: NSRange) {
        guard let existingAttrs = textView.textStorage?.attributes(at: range.location, effectiveRange: nil) else {
            return
        }
        window?.undoManager?.setActionName(NSLocalizedString("Change Attributes", comment: ""))
        window?.undoManager?.registerUndo(withTarget: self) {
            $0.setAttributes(existingAttrs, range: range)
            /// force UI to update to reverted style information
            let note = Notification(name: NSTextView.didChangeSelectionNotification, object: self.textView, userInfo: nil)
            $0.textViewDidChangeSelection(note)
        }
        textView.textStorage?.setAttributes(attributes, range: range)
        setDocumentEdited(true)
    }

    // MARK: - <NSTextViewDelegate>
    public func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        NSLog("\(type(of: self)).\(#function) \(NSStringFromSelector(commandSelector))")
        return false
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
        NSLog("\(type(of: self)).\(#function) notification == \(notification)")
        let ranges: [NSRange] = textView.selectedRanges.map(\.rangeValue)
        if !ranges.isEmpty {
            var totalRange: NSRange = .init()
            for range in ranges {
                if totalRange.isEmpty {
                    totalRange = range
                } else {
                    totalRange = totalRange.union(range)
                }
            }
            if let textStorage {
                let style: Styl.Style?
                if textStorage.length == 0 {
                    style = currentStyle
                } else {
                    if totalRange.location >= textStorage.length {
                        totalRange.location = textStorage.length - 1
                    }
                    let attrs = textStorage.attributes(at: totalRange.location, effectiveRange: nil)
                    style = attrs[.stylStyle] as? Styl.Style
                }
                if let style {
                    let attrs = style.attrs
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
                    sizeComboBox.objectValue = "\(style.fontPointSize)"
                    if style.fontStyle.contains(.shadow) {
                        if let shadow = attrs[.shadow] as? NSShadow, let color = shadow.shadowColor {
                            colorWell.color = color
                        }
                    } else {
                        colorWell.color = attrs[.foregroundColor] as! NSColor
                    }
                    fontPopUpButton.selectItem(withTag: Int(style.fontFamilyID))
                }
            }
        }
    }

    @objc func didProcessEditing(_ notification: Notification) {
        self.setDocumentEdited(true)
    }
}
