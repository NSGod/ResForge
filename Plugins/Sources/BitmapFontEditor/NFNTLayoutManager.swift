//
//  NFNTLayoutManager.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/14/2026.
//

import Cocoa
import RFSupport
import FONDEditor

class NFNTLayoutManager {
    weak var textStorage:       NFNTTextStorage!

    var textContainer:          NFNTTextContainer! {
        didSet {
            NSLog("\(type(of: self)).\(#function)")
            textContainer.layoutManager = self
            typesetter.currentTextContainer = textContainer
        }
    }

    var typesetter:             NFNTTypesetter

    private var layoutIsValid:  Bool = false
    private var lineFragments:  [NFNTLineFragment] = []

    init() {
        NSLog("\(type(of: self)).\(#function)")
        typesetter = NFNTTypesetter()
        typesetter.layoutManager = self
    }

    // called by `NFNTTextStorage` to notify of changes to model:
    func stringDidChange() {
        self.invalidateLayout()
    }

    func alignmentDidChange() {
        self.invalidateLayout()
    }

    func fontDidChange() {
        self.invalidateLayout()
    }

    /// Called by `NFNTTextContainer` whenever it changes sizes or shape.
    /// Invalidates layout of all glyphs in container and all subsequent containers.
    func textContainerChangedGeometry(_ container: NFNTTextContainer) {
        self.invalidateLayout()
    }

    func invalidateLayout() {
        layoutIsValid = false
        lineFragments.removeAll()
    }

    /// Do the actual drawing:
    func drawGlyphs(at point: NSPoint) {
        if !layoutIsValid { generateGlyphs() }
        var drawRect: NSRect = .zero
        drawRect.origin = point
        for lineFragment in lineFragments {
            drawRect.origin = lineFragment.alignedFrame.origin
            for glyph in lineFragment.generatedGlyphs {
                drawRect.origin.x += CGFloat(glyph.nfnt.kernMax + Int16(glyph.offset))
                drawRect.size.height = NSHeight(glyph.glyphRect)
                if glyph.charCode == CharCode16.space {
                    drawRect.size.width = CGFloat(glyph.width)
                    NSColor.white.setFill()
                    NSBezierPath(rect: drawRect).fill()
                    drawRect.origin.x += CGFloat(glyph.width)
                } else {
                    drawRect.size.width = glyph.glyphRect.size.width
                    glyph.nfnt.bitmapImage?.draw(in: drawRect, from: glyph.glyphRect, operation: .plusDarker, fraction: 1.0, respectFlipped: true, hints: nil)
                    drawRect.origin.x += glyph.glyphRect.size.width
                }
            }
        }
    }

    private func generateGlyphs() {
        if layoutIsValid { return }
        let maxLineCount = Int(floor(textContainer.size.height/textStorage.nfnt.lineHeight))
        let sampleStringParagraphs = textStorage.string.components(separatedBy: CharacterSet.newlines)
        var lineIndex = 0
        for paragraph in sampleStringParagraphs {
            let lineFrags = typesetter.generatedLineFragments(for: paragraph, at: NSMakePoint(0, textStorage.nfnt.lineHeight * CGFloat(lineIndex)), maxNumberOfLineFragments: maxLineCount - lineIndex)
            if !lineFrags.isEmpty {
                lineFragments.append(contentsOf: lineFrags)
            }
            lineIndex += lineFrags.count
            if lineIndex == maxLineCount { break }
        }
        layoutIsValid = true
    }
}
