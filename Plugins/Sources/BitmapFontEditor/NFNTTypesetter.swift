//
//  NFNTTypesetter.swift
//  BitmapFontEditor
//
//  Created by Mark Douma on 1/14/2026.
//

import Cocoa
import RFSupport

class NFNTTypesetter {

    weak var layoutManager:         NFNTLayoutManager!  // weak
    weak var currentTextContainer:  NFNTTextContainer!  // weak

    private var maxLineWidth:       CGFloat = 0
    private var spaceWidth:         CGFloat = 0

    func generatedLineFragments(for string: String, at point: NSPoint, maxNumberOfLineFragments: Int) -> [NFNTLineFragment] {
        maxLineWidth = currentTextContainer.size.width
        spaceWidth = self.width(of: " ")
        var mLineFragments = [NFNTLineFragment]()
        let sampleStringWords = string.split(separator: " ")
        var isBeginningOfLine: Bool = true
        var drawPoint = point
        let nfnt: NFNT = layoutManager.textStorage.nfnt
        let alignment: NSTextAlignment = layoutManager.textStorage.alignment
        var currentLineFragment = NFNTLineFragment(frame: NSMakeRect(drawPoint.x, drawPoint.y, maxLineWidth, nfnt.lineHeight), alignment: alignment)
        mLineFragments.append(currentLineFragment)
        for word in sampleStringWords {
            let wordWidth = self.width(of: String(word))
            /// is the word wider than the entire line width?
            if wordWidth <= maxLineWidth {
                /// If this is not the beginning of the line, is there room for a space + the word on this line?
                if !isBeginningOfLine && (spaceWidth + wordWidth > (maxLineWidth - drawPoint.x)) {
                    /// if there isn't enough room on the current line for this word, finish this lineFragment, create a new one,
                    /// and reset the draw point, but *only* if we haven't surpassed the max number of lines
                    if mLineFragments.count == maxNumberOfLineFragments {
                        return mLineFragments
                    }
                    drawPoint.x = point.x
                    drawPoint.y += nfnt.lineHeight
                    currentLineFragment = NFNTLineFragment(frame: NSMakeRect(drawPoint.x,
                                                                            drawPoint.y,
                                                                            maxLineWidth,
                                                                            nfnt.lineHeight),
                                                           alignment: layoutManager.textStorage.alignment)
                    mLineFragments.append(currentLineFragment)
                    isBeginningOfLine = true
                }
                if !isBeginningOfLine {
                    // FIXME: figure out what to do for a space if font doesn't have one
                    if let spaceGlyph = nfnt.glyphEntries[" "] {
                        currentLineFragment.add(spaceGlyph)
                        drawPoint.x += CGFloat(nfnt.kernMax + Int16(spaceGlyph.offset)) + CGFloat(spaceGlyph.width)
                    }
                }
                for char: Character in word {
                    if let glyph = nfnt.glyphEntries["\(char)"] {
                        drawPoint.x += CGFloat(nfnt.kernMax + Int16(glyph.offset) + Int16(glyph.width))
                        currentLineFragment.add(glyph)
                        if isBeginningOfLine { isBeginningOfLine = false }
                    }
                }
            } else {
                /// we'll have to do char-wrapping
                for char: Character in word {
                    let currentLetter = "\(char)"
                    let letterWidth = self.width(of: currentLetter)
                    if letterWidth > (maxLineWidth - drawPoint.x) {
                        /// If there isn't enough room on the current line for this word,
                        /// finish this lineFragment, create a new one, and reset
                        /// the draw point, but *only* if we haven't surpassed the max
                        /// number of lines.
                        if mLineFragments.count == maxNumberOfLineFragments {
                            return mLineFragments
                        }
                        drawPoint.x = point.x
                        drawPoint.y += nfnt.lineHeight
                        currentLineFragment = NFNTLineFragment(frame: NSMakeRect(drawPoint.x, drawPoint.y, maxLineWidth, nfnt.lineHeight), alignment: alignment)
                        mLineFragments.append(currentLineFragment)
                        isBeginningOfLine = true // ??
                    }
                    if let glyph = nfnt.glyphEntries["\(char)"] {
                        drawPoint.x += CGFloat(nfnt.kernMax + Int16(glyph.offset) + Int16(glyph.width))
                        currentLineFragment.add(glyph)
                        if isBeginningOfLine { isBeginningOfLine = false }
                    }
                }
            }
        }
        return mLineFragments
    }

    private func widthsOfGlyphs(in string: String) -> [CGFloat] {
        let nfnt: NFNT = layoutManager.textStorage.nfnt
        var widths: [CGFloat] = []
        for char: Character in string {
            if let glyph = nfnt.glyphEntries["\(char)"] {
                widths.append(CGFloat(nfnt.kernMax + Int16(glyph.offset) + Int16(glyph.width)))
            }
        }
        return widths
    }

    private func width(of word: String) -> CGFloat {
        return widthsOfGlyphs(in: word).reduce(0.0, +)
    }
}
