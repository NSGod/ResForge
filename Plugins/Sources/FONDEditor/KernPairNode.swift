//
//  KernPairNode.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/1/2026.
//

import Cocoa

// for display
final class KernPairNode: NSObject {
    let kernFirstGlyphName:     String
    let kernSecondGlyphName:    String
    let kernWidth:              Fixed4Dot12

    init(with kernPair: KernPair, fond: FOND) {
        kernFirstGlyphName = fond.glyphName(for: kernPair.kernFirst) ?? "???"
        kernSecondGlyphName = fond.glyphName(for: kernPair.kernSecond) ?? "???"
        kernWidth = kernPair.kernWidth
        super.init()
    }

    func localizedStandardCompare(_ otherNode: KernPairNode) -> ComparisonResult {
        if kernFirstGlyphName == otherNode.kernFirstGlyphName {
            if kernSecondGlyphName == otherNode.kernSecondGlyphName {
                return (Fixed4Dot12ToDouble(kernWidth) as NSNumber).compare(Fixed4Dot12ToDouble(otherNode.kernWidth) as NSNumber)
            } else {
                // or localizedStandardCompare:?
                return kernSecondGlyphName.compare(otherNode.kernSecondGlyphName)
            }
        } else {
            // or localizedStandardCompare:?
            return kernFirstGlyphName.compare(otherNode.kernFirstGlyphName)
        }
    }
}
