//
//  KernPairExporterController.swift
//  FONDEditor
//
//  Created by Mark Douma on 3/10/2026.
//

import Cocoa
import RFSupport
import CoreFont

public final class KernPairExporterController {
    public var entries: [FOND.KernTable.Entry]
    public weak var editor: FONDEditor?
    public weak var manager: RFEditorManager?

    public init(entries: [FOND.KernTable.Entry], editor: FONDEditor, manager: RFEditorManager) {
        assert(entries.count > 0)
        self.entries = entries
        self.editor = editor
        self.manager = manager
    }

    public func export() {
        let fond: FOND = entries.first!.fond!
        var panel: NSSavePanel!
        if entries.count == 1 {
            panel = NSSavePanel()
            panel.allowedFileTypes = [KernPairExporter.GPOSFeatureUTType,
                                      KernPairExporter.CSVUTType]
            let entry = entries[0]
            if let name = fond.postScriptNameForFont(with: entry.style) {
                if let filename = (name as NSString).appendingPathExtension("txt") {
                    panel.nameFieldStringValue = filename
                }
            }
        } else {
            // if more than one entry, we need to export multiple files
            let oPanel = NSOpenPanel()
            oPanel.allowsMultipleSelection = false
            oPanel.canChooseFiles = false
            oPanel.canChooseDirectories = true
            oPanel.prompt = NSLocalizedString("Choose", comment: "")
            oPanel.message = NSLocalizedString("Choose the folder to export the kern pair files to", comment: "")
            panel = oPanel
        }
        panel.isExtensionHidden = false
        let viewController = KernPairSaveAccessoryViewController(with: panel)
        panel.accessoryView = viewController.view
        (panel as? NSOpenPanel)?.isAccessoryViewDisclosed = true
        panel.beginSheetModal(for: editor!.window!) { [self] (result) in
            if result == .OK {
                viewController.saveOptions()
                let config = viewController.config
                if entries.count == 1 {
                    guard let rep: String = KernPairExporter.representation(of: entries.first!, using: config, manager: manager) else { return }
                    do {
                        try rep.write(to: panel.url!, atomically: true, encoding: .utf8)
                    } catch {
                        NSLog("\(type(of: self)).\(#function) *** ERROR == \(error)")
                    }
                } else {
                    guard let parentDirURL = panel.url else { return }
                    for entry in entries {
                        if let name = fond.postScriptNameForFont(with: entry.style) {
                            guard let rep = KernPairExporter.representation(of: entry, using: config, manager: manager) else { continue }
                            let url = parentDirURL.appendingPathComponent(name).appendingPathExtension(config.pathExtension).assuringUniqueFilename()
                            do {
                                try rep.write(to: url, atomically: true, encoding: .utf8)
                            } catch {
                                 NSLog("\(type(of: self)).\(#function) *** ERROR: \(error)")
                            }
                        }
                    }
                }
            }
        }
    }
}
