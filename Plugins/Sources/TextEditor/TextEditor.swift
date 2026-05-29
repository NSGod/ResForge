import Cocoa
import RFSupport
import SwiftUI
import CoreFont

/// To simulate bold?:
/// Technical Q&A QA1531
/// Drawing attributed strings that are both filled and stroked
/// https://developer.apple.com/library/archive/qa/qa1531/_index.html#//apple_ref/doc/uid/DTS40007490

public class TextEditor: AbstractEditor, ResourceEditor {
    public static var bundle: Bundle { .module }
    public static let supportedTypes = [
        "TEXT"
    ]
    public static func register() {
        PluginRegistry.register(self)
    }
    @IBOutlet weak var textView: NSTextView!
    public let resource: Resource
    private let manager: RFEditorManager

    var style: Styl!

    public override var windowNibName: String {
        return "TextEditorWindow"
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
        self.textView.string = String(data: resource.data, encoding: .macOSRoman) ?? ""

        do {
            if let styleResource = manager.findResource(type: ResourceType("styl"), id: resource.id, currentDocumentOnly: true) {
                // TODO: Convert MacRoman byte offsets to UTF8 offsets.
                style = try Styl(with: styleResource, count: resource.data.count)
                for run in style.runs {
                    textView.textStorage?.addAttributes(run.attrs, range: run.range)
                }
            }
        } catch {
            self.window?.presentError(error)
        }

        self.setDocumentEdited(false)
    }

    @objc func textFieldDidChange(_ notification: Notification) {
        self.setDocumentEdited(true)
    }
}
