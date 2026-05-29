//
//  FontActivationManager.swift
//  CoreFont
//
//  Created by Mark Douma on 5/23/2026.
//

import Cocoa
import CoreText
import RFSupport
import Dispatch

public enum FontActivationError: Error {
    case activationFailed(String?)
}

public final class FontActivationManager {

    private var urlsToFonts:            [URL: [NSFont]] = [:]

    public static let `default` = FontActivationManager()

    private init() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(appWillTerminate(_:)), name: NSApplication.willTerminateNotification, object: nil)
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    @discardableResult
    public func activateFontFile(forResource name: String, withExtension ext: String) throws -> [NSFont]? {
        if let url = Bundle.module.url(forResource: name, withExtension: ext) {
            return try activateFontFile(with: url)
        }
        return nil
    }

    @discardableResult
    public func activateFontFile(with url: URL) throws -> [NSFont]? {
        if let fonts = urlsToFonts[url] {
            return fonts
        }
        guard let descriptors: [NSFontDescriptor] = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as? [NSFontDescriptor] else {
            throw FontActivationError.activationFailed(nil)
        }
        let done = DispatchSemaphore(value: 0)
        let naptime = DispatchTime.now() + .seconds(10)
        let type = "\(type(of: self))"
        var actErrors: [NSError] = []
        DispatchQueue.global().async {
            CTFontManagerRegisterFontURLs([url as CFURL] as CFArray, .process, true) { errors, descDone in
                if let errors: [NSError] = (errors as NSArray) as? [NSError], errors.count > 0 {
                    actErrors.append(contentsOf: errors)
                }
                if descDone { done.signal() }
                return true
            }
        }

        if done.wait(timeout: naptime) == .timedOut {
            NSLog("\(type).\(#function) *** ERROR: CTFontManagerRegisterFontDescriptors() timed out")
        }
        actErrors.forEach { NSLog("\(type).\(#function) *** ERROR: \($0)") }
        var mFonts: [NSFont] = []
        for descriptor in descriptors {
            if let font: NSFont = NSFont(descriptor: descriptor, size: 12.0) {
                mFonts.append(font)
            }
        }
        urlsToFonts[url] = mFonts
        return mFonts
    }

    @objc private func appWillTerminate(_ notification: Notification) {
        if urlsToFonts.isEmpty { return }
        let done = DispatchSemaphore(value: 0)
        let naptime = DispatchTime.now() + .seconds(10)
        let urls: [URL] = Array(self.urlsToFonts.keys)
        DispatchQueue.global().async {
            CTFontManagerUnregisterFontURLs(urls as CFArray, .process) { errors, urlDone in
                if let errors: [NSError] = (errors as NSArray) as? [NSError], errors.count > 0 {
                    errors.forEach { NSLog("\(type(of: self)).\(#function) *** ERROR: \($0)") }
                }
                if urlDone { done.signal() }
                return true
            }
        }
        if done.wait(timeout: naptime) == .timedOut {
            NSLog("\(type(of: self)).\(#function) *** ERROR: CTFontManagerUnregisterFontDescriptors() timed out")
        }
        urlsToFonts = [:]
    }

}
