//
//  Styl.StyledString.swift
//  CoreFont
//
//  Created by Mark Douma on 6/2/2026.
//

import Cocoa
import RFSupport

extension NSPasteboard.PasteboardType {
    public static let RFAttributedStylString     = Self("com.resforge.attributed-styl-string")
}

extension Styl {

    @objc(MDStyledString) public final class StyledString: NSObject, NSSecureCoding, NSPasteboardReading, NSPasteboardWriting {
        public var string:     String
        public var style:      Style

        public static let supportsSecureCoding: Bool = true

        public init(string: String, style: Style) {
            self.string = string
            self.style = style
            super.init()
        }

        public required init?(coder: NSCoder) {
            string = coder.decodeObject(of: NSString.self, forKey: "string") as? String ?? ""
            style = coder.decodeObject(of: Style.self, forKey: "style") ?? .default
        }

        public func encode(with coder: NSCoder) {
            coder.encode(string, forKey: "string")
            coder.encode(style, forKey: "style")
        }

        // MARK: - <NSPasteboardReading>
        public static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
            return [.RFAttributedStylString]
        }

        public static func readingOptions(forType pboardType: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.ReadingOptions {
            return .asKeyedArchive
        }

        public required init?(pasteboardPropertyList propertyList: Any, ofType pboardType: NSPasteboard.PasteboardType) {
            return nil
        }

        // MARK: - <NSPasteboardWriting>
        public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
            return [.RFAttributedStylString]
        }

        public func pasteboardPropertyList(forType pboardType: NSPasteboard.PasteboardType) -> Any? {
            if pboardType == .RFAttributedStylString {
                return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: true)
            }
            return nil
        }
    }
}
