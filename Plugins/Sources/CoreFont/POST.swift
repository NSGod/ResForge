//
//  POST.swift
//  CoreFont
//
//  Created by Mark Douma on 1/12/2026.
//

import Foundation
import RFSupport

// represents a single 'POST' resource
public struct POST {
    private let dataType:           DataType    // UInt8
    private let ignored:            UInt8       // ignored
    private let postScriptData:     Data

    private enum DataType: UInt8 {
        case ascii      = 1
        case binary     = 2
        case end        = 5
        // mine:
        case none       = 255
    }

    fileprivate static let hexDataLineLength: Int = 64

    public init(resource: Resource) throws {
        let reader = BinaryDataReader(resource.data)
        dataType = try reader.read()
        ignored = try reader.read()
        postScriptData = try reader.readData(length: reader.bytesRemaining)
    }

    public static func postResources(from resources: [Resource]) throws -> [POST] {
        var postResources: [POST] = []
        for resource in resources {
            let post = try POST(resource: resource)
            postResources.append(post)
        }
        return postResources
    }

    // MARK: only .ascii output format is currently supported
    public static func data(from postResources: [POST], outputFormat: PostScriptType1FontFile.Format = .ascii) throws -> Data? {
        if outputFormat == .binary {
            fatalError("Binary PostScript output format not supported")
        }
        var mString = ""
        var lastType: DataType = .none
        var hexColumn = 0
        for post in postResources {
            if post.dataType == .ascii {
                if var postString = String(data: post.postScriptData, encoding: .macOSRoman) {
                    postString = postString.replacingOccurrences(of: "\r", with: "\n")
                    if lastType == .binary { mString += "\n" }
                    mString.append(postString)
                    lastType = .ascii
                } else {
                    NSLog("\(type(of: self)).\(#function)() ERROR: failed to create string with .macOSRoman encoding! skipping...")
                    if lastType == .binary { mString += "\n" }
                    continue
                }
            } else if post.dataType == .binary {
                if lastType != .binary { hexColumn = 0 }
                let length = post.postScriptData.count
                for i in 0..<length {
                    if hexColumn >= hexDataLineLength {
                        mString += "\n"
                        hexColumn = 0
                    }
                    mString += String(format: "%02x", post.postScriptData[post.postScriptData.startIndex + i])
                    hexColumn += 2
                }
                lastType = .binary
            } else if post.dataType == .end {
                break
            }
        }
        // FIXME: or should this be .macOSRoman?
        // FIXME: this still needs to have octal escape sequences resolved (for example, '\251' -> '©')
        return mString.data(using: .utf8)
    }
}
