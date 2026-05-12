//
//  Sfnt.swift
//  CoreFont
//
//  Created by Mark Douma on 5/4/2026.
//

import Cocoa
import RFSupport

public final class Sfnt: NSObject, CFResource {
    public var resource:    Resource
    public var fontFile:    OTFFontFile?

    public init(resource: Resource, fontFile: OTFFontFile? = nil) {
        self.resource = resource
        self.fontFile = fontFile
        super.init()
    }
}
