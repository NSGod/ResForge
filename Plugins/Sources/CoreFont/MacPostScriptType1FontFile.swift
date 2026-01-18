//
//  MacPostScriptType1FontFile.swift
//  CoreFont
//
//  Created by Mark Douma on 1/11/2026.
//

import Foundation
import RFSupport

//NSString * const MDUTTypeMacOutlineFont                = @"com.adobe.postscript-lwfn-font";
//const OSType     MDOSTypeMacOutlineFont                = 'LWFN';

public enum MacPostScriptType1FontFileError: Error {
    case notAPostScriptFont
}

// represents an 'LWFN' file w/ an "embedded" PFA/PFB file split into 'POST' resources
public struct MacPostScriptType1FontFile {

    public var postScriptFontFile:      PostScriptType1FontFile?     // "embedded" PFA/PFB file
    private var resourceFile:           ClassicFormat!

    /// 99% of 'LWFN' files will be resource-fork-based, but Apple's Multiple Master
    /// substitution fonts (/System/Library/Fonts/TimesLTMM &&
    /// /System/Library/Fonts/HelveLTMM) are data-fork-based.
    /// So, default to resource-fork, but also try data fork as a last resort.
    public init(contentsOf url: URL) throws {
        let values = try url.resourceValues(forKeys: [.fileSizeKey, .totalFileSizeKey])
        let hasRsrc = (values.totalFileSize! - values.fileSize!) > 0
        let data = try Data(contentsOf: (hasRsrc ? url.appendingPathComponent("..namedfork/rsrc") : url))
        try self.init(data: data)
    }

    public init(data: Data) throws {
        resourceFile = ClassicFormat()
        let resourceMap: ResourceMap = try resourceFile.read(data)
        guard var resources: [Resource] = resourceMap[ResourceType("POST")], resources.count > 0 else {
            throw MacPostScriptType1FontFileError.notAPostScriptFont
        }
        // MARK: make sure to sort the 'POST' resources by ID in case they're out of order (by indexes) in the font file
        resources.sort { $0.id < $1.id }
        let postResources = try POST.postResources(from: resources)
        guard let postScriptData = try POST.data(from: postResources, outputFormat: .ascii) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        postScriptFontFile = try PostScriptType1FontFile(data: postScriptData)
    }
}
