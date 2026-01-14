//
//  File.swift
//  FontEditor
//
//  Created by Mark Douma on 1/13/2026.
//

import Foundation
import RFSupport

extension BinaryDataReader {

    public func subdata(with range: Range<UInt32>) throws -> Data {
        pushSavedPosition()
        defer { popPosition() }
        try setPosition(Int(range.lowerBound))
        return try readData(length: range.count)
    }
}
