//
//  Extensions.swift
//  CoreFont
//
//  Created by Mark Douma on 1/13/2026.
//

import Foundation
import RFSupport

public extension BinaryDataReader {

    func subdata(with range: Range<UInt32>) throws -> Data {
        pushSavedPosition()
        defer { popPosition() }
        try setPosition(Int(range.lowerBound))
        return try readData(length: range.count)
    }

    func peek<T: FixedWidthInteger>(bigEndian: Bool? = nil) throws -> T {
        let length = T.bitWidth / 8
        try self.advance(length)
        let val = data.withUnsafeBytes {
            $0.loadUnaligned(fromByteOffset: position-length-data.startIndex, as: T.self)
        }
        try self.advance(-length)
        return bigEndian ?? self.bigEndian ? T(bigEndian: val) : T(littleEndian: val)
    }
}

public extension Date {
    init(secondsSince1904: Int64) {
        self.init(timeIntervalSinceReferenceDate: Double(secondsSince1904) - kCFAbsoluteTimeIntervalSince1904)
    }

    var secondsSince1904: Int64 {
        Int64((self.timeIntervalSinceReferenceDate + kCFAbsoluteTimeIntervalSince1904))
    }
}

public extension URL {
    // FIXME: need to make sure this doesn't exceed NAME_MAX
    func assuringUniqueFilename() -> URL {
        var targetURL = self
        do {
            if try !checkResourceIsReachable() { return self }
            let parentDirURL = self.deletingLastPathComponent()
            let filename = self.lastPathComponent
            let ext = self.pathExtension
            let basename = (filename as NSString).deletingPathExtension
            var targetBasename = basename
            var index = 0
            let components = basename.components(separatedBy: " ")
            if components.count > 1 {
                // "blah blah" or "blah blah 2"
                let lastWord = components.last!
                index = abs(Int(lastWord) ?? 0)
                if index == 0 {
                    // "blah blah"
                    index = 2
                } else {
                    // "blah blah #"
                    index += 1
                    // make targetBasename be everything before the number
                    let endIndex: String.Index = basename.index(basename.endIndex, offsetBy: -(lastWord.count + 1))
                    targetBasename = String(basename[..<endIndex])
                }
            }
            while true {
                let extLength = ext.count != 0 ? ext.count + 1 : 0
                if index == 0 { index = 2 }
                var targetName = "\(targetBasename) \(index)"
                if extLength != 0 { targetName += ".\(ext)" }
                targetURL = parentDirURL.appendingPathComponent(targetName, isDirectory: false)
                if try !targetURL.checkResourceIsReachable() {
                    return targetURL
                }
                if index == 0 {
                    index = 2
                } else { index += 1 }
            }
        } catch {
            if let error = error as? CocoaError, error.code != CocoaError.fileReadNoSuchFile {
                NSLog("\(type(of: self)).\(#function) ERROR: \(error)")
            }
        }
        return targetURL
    }
}
