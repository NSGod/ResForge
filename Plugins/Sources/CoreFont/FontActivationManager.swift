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
    private var descriptorsToFonts:     [NSFontDescriptor: [NSFont]] = [:]

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

    public func activateFontFile(with url: URL) throws -> [NSFont]? {
        if let fonts = urlsToFonts[url] {
            return fonts
        }
        let data = try Data(contentsOf: url)
        guard let desc: NSFontDescriptor = CTFontManagerCreateFontDescriptorFromData(data as CFData) as NSFontDescriptor?  else {
            throw FontActivationError.activationFailed(nil)
        }
        let done = DispatchSemaphore(value: 0)
        let naptime = DispatchTime.now() + .seconds(10)
        let type = "\(type(of: self))"
        var actErrors: [NSError] = []
        DispatchQueue.global().async {
            CTFontManagerRegisterFontDescriptors([desc] as CFArray, .process, true) { errors, descDone in
                if let errors: [NSError] = (errors as NSArray) as? [NSError], errors.count > 0 {
                    actErrors = errors
                    actErrors.forEach { NSLog("\(type).\(#function) *** ERROR: \($0)") }
                }
                if descDone { done.signal() }
                return true
            }
        }
        if done.wait(timeout: naptime) == .timedOut {
            NSLog("\(type).\(#function) *** ERROR: CTFontManagerRegisterFontDescriptors() timed out")
        }
        guard let font = NSFont(descriptor: desc, size: 12.0) else {
            throw FontActivationError.activationFailed("failed to get NSFont")
        }
        descriptorsToFonts[desc] = [font]
        urlsToFonts[url] = [font]
        return [font]
    }

    @objc private func appWillTerminate(_ notification: Notification) {
        if descriptorsToFonts.isEmpty { return }
        let done = DispatchSemaphore(value: 0)
        let naptime = DispatchTime.now() + .seconds(10)
        let descs: [NSFontDescriptor] = Array(self.descriptorsToFonts.keys)

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            CTFontManagerUnregisterFontDescriptors(descs as CFArray, .process) { errors, descDone in
                if let errors: [NSError] = (errors as NSArray) as? [NSError], errors.count > 0 {
                    errors.forEach { NSLog("\(type(of: self)).\(#function) *** ERROR: \($0)") }
                }
                if descDone { done.signal() }
                return true
            }
        }
        if done.wait(timeout: naptime) == .timedOut {
            NSLog("\(type(of: self)).\(#function) *** ERROR: CTFontManagerUnregisterFontDescriptors() timed out")
        }
        descriptorsToFonts = [:]
    }

}
