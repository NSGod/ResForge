//
//  KernPairSaveAccessoryViewController.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/18/2026.
//

import Cocoa
import CoreFont
import RFSupport

class KernPairSaveAccessoryViewController: NSViewController {
    weak var panel:                     NSSavePanel! // or NSOpenPanel
    @IBOutlet weak var scaleCheckbox:   NSButton!
    @IBOutlet weak var resolveCheckbox: NSButton!

    @objc var allowedFileTypes:         [String] = [KernTableEntry.GPOSFeatureFileType,
                                                    KernTableEntry.CSVFileType]
    @objc var selectedFileType:         String {
        didSet {
            guard let panel else { return }
            /// try to change filename extension in save panel's field
            /// by limiting the allowed UT types to the currently selected one.
            if selectedFileType == KernTableEntry.GPOSFeatureFileType {
                panel.allowedFileTypes = [KernTableEntry.GPOSFeatureUTType]
                shouldResolveGlyphNames = true
                scaleToUnitsPerEm = true
            } else {
                panel.allowedFileTypes = [KernTableEntry.CSVUTType]
            }
            /// GPOS format must have both scale and glyph names resolved
            scaleCheckbox.isEnabled = selectedFileType != KernTableEntry.GPOSFeatureFileType
            resolveCheckbox.isEnabled = selectedFileType != KernTableEntry.GPOSFeatureFileType
        }
    }

    @objc var shouldResolveGlyphNames:  Bool {
        didSet {
            NSLog("\(type(of: self)).\(#function) didSet")
        }
    }

    @objc var scaleToUnitsPerEm:        Bool {
        didSet {
            NSLog("\(type(of: self)).\(#function) didSet")
        }
    }

    var config: KernTableEntry.KernExportConfig {
        KernTableEntry.KernExportConfig(format: (selectedFileType == KernTableEntry.GPOSFeatureFileType ? .GPOS : .CSV),
                                        resolveGlyphNames: shouldResolveGlyphNames, scaleToUnitsPerEm: scaleToUnitsPerEm)
    }

    private static let SaveFileTypeKey:         String = "KernPairs.SaveFileType"
    private static let ResolveGlyphNamesKey:    String = "KernPairs.ResolveGlyphNames"
    private static let ScaleToUnitsPerEmKey:    String = "KernPairs.ScaleToUnitsPerEm"

    required init(with panel: NSSavePanel) {
        let defaults: [String : Any] = [Self.SaveFileTypeKey: KernTableEntry.GPOSFeatureFileType,
                        Self.ResolveGlyphNamesKey: true,
                        Self.ScaleToUnitsPerEmKey: true]
        UserDefaults.standard.register(defaults: defaults)
        NSUserDefaultsController.shared.initialValues = defaults
        self.panel = panel
        selectedFileType = UserDefaults.standard.string(forKey: Self.SaveFileTypeKey)!
        shouldResolveGlyphNames = UserDefaults.standard.bool(forKey: Self.ResolveGlyphNamesKey)
        scaleToUnitsPerEm = UserDefaults.standard.bool(forKey: Self.ScaleToUnitsPerEmKey)
        super.init(nibName: "KernPairSaveAccessoryViewController", bundle: Bundle.module)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func saveOptions() {
        UserDefaults.standard.set(selectedFileType, forKey: Self.SaveFileTypeKey)
        UserDefaults.standard.set(shouldResolveGlyphNames, forKey: Self.ResolveGlyphNamesKey)
        UserDefaults.standard.set(scaleToUnitsPerEm, forKey: Self.ScaleToUnitsPerEmKey)
    }
}
