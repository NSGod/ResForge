//
//  DataHandle.swift
//  CoreFont
//
//  Created by Mark Douma on 2/2/2026.
//

import Foundation

public enum DataHandleError: Error {
    case stringEncodeFailure
}

public protocol DataHandleWriting {
//    func write(to dataHandle: DataHandle, offset:Int?) throws
    func write(to dataHandle: DataHandle) throws
}

public extension DataHandleWriting {
//    func write(to dataHandle: DataHandle, offset: Int? = nil) throws {
//
//    }

    func write(to dataHandle: DataHandle) throws {

    }
}

public class DataHandle {
    public var data:                    Data
    public var bigEndian:               Bool

    public private(set) var currentOffset: Int {
        get {
            return _dataOffset - data.startIndex
        }
        set {
            _dataOffset = data.startIndex + newValue
        }
    }

    private var offsetStack:                [Int] = []
    private var _dataOffset:                Int

    public init(capacity: Int = 0, bigEndian: Bool = true) {
        data = Data(capacity: capacity)
        self.bigEndian = bigEndian
        _dataOffset = data.startIndex
    }

    public func seek<T: FixedWidthInteger>(to offset: T) {
        let offset = Int(offset)
        seek(to: offset)
    }

    public func seek(to offset: Int) {
        assert(offset >= 0)
        if offset > data.count {
            data.count = offset
        }
        currentOffset = offset
    }

    public func pushSavedOffset() {
        offsetStack.append(currentOffset)
    }

    public func popAndSeekToSavedOffset() {
        assert(!offsetStack.isEmpty, "Offset stack is empty")
        currentOffset = offsetStack.removeLast()
    }

    public func truncate() {
        truncate(at: currentOffset)
    }

    public func truncate(at offset: Int) {
        data.count = offset
        currentOffset = offset
    }

    public func write<T: FixedWidthInteger>(_ value: T, bigEndian: Bool? = nil) {
        let val = bigEndian ?? self.bigEndian ? value.bigEndian : value.littleEndian
        let end = _dataOffset + T.bitWidth / 8
        if !data.indices.contains(end) {
            data.count = end - data.startIndex
        }
        withUnsafeBytes(of: val) {
            data.replaceSubrange(_dataOffset..<end, with: $0)
        }
        _dataOffset = end
    }

    public func write<T: RawRepresentable>(_ value: T, bigEndian: Bool? = nil) where T.RawValue: FixedWidthInteger {
        write(value.rawValue, bigEndian: bigEndian)
    }

    public func writeData(_ newData: Data) {
        let subrange = _dataOffset..<_dataOffset + newData.count
        if !data.indices.contains(subrange.upperBound) {
            data.count = subrange.upperBound - data.startIndex
        }
        data.replaceSubrange(subrange, with: newData)
        _dataOffset += newData.count
    }

    public func writeString(_ value: String, encoding: String.Encoding = .utf8) throws {
        guard let data = value.data(using: encoding) else {
            throw DataHandleError.stringEncodeFailure
        }
        writeData(data)
    }

    public func writePString(_ value: String, encoding: String.Encoding = .macOSRoman) throws {
        guard let data = value.data(using: encoding), data.count <= UInt8.max else {
            throw DataHandleError.stringEncodeFailure
        }
        var encodedData = Data(repeating: UInt8(data.count), count: 1)
        encodedData.append(contentsOf: data)
        writeData(encodedData)
    }
}
