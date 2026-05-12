//
//  CFResource.swift
//  CoreFont
//
//  Created by Mark Douma on 5/4/2026.
//

import Foundation
import RFSupport

public protocol CFResource: AnyObject {
    var resource: Resource { get set }
}
