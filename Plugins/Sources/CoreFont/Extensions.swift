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
