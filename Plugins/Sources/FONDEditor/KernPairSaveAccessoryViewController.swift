//
//  KernPairSaveAccessoryViewController.swift
//  FONDEditor
//
//  Created by Mark Douma on 1/18/2026.
//

import Cocoa
import CoreFont

class KernPairSaveAccessoryViewController: NSViewController {
    weak var savePanel:                 NSSavePanel!
    @IBOutlet weak var scaleCheckbox:   NSButton!
    @IBOutlet weak var resolveCheckbox: NSButton!

    @objc var allowedFileTypes:         [String] = []
    @objc var selectedFileType:         String {
        didSet {
            guard let savePanel else { return }
            // change filename extension in save panel's field
            savePanel.allowedFileTypes = [selectedFileType == KernTableEntry.GPOSFeatureFileType
                                          ? KernTableEntry.GPOSFeatureUTType : KernTableEntry.CSVUTType]
            scaleCheckbox.isEnabled = selectedFileType != KernTableEntry.GPOSFeatureFileType
            resolveCheckbox.isEnabled = selectedFileType != KernTableEntry.GPOSFeatureFileType
            if selectedFileType == KernTableEntry.GPOSFeatureFileType {
                shouldResolveGlyphNames = true
                scaleToUnitsPerEm = true
            }
        }
    }
    @objc var shouldResolveGlyphNames:  Bool
    @objc var scaleToUnitsPerEm:        Bool

    var kernExportConfig: KernTableEntry.KernExportConfig {
        KernTableEntry.KernExportConfig(resolveGlyphNames: shouldResolveGlyphNames, scaleToUnitsPerEm: scaleToUnitsPerEm)
    }

    static private let SaveFileTypeKey:         String = "KernPairs.SaveFileType"
    static private let ResolveGlyphNamesKey:    String = "KernPairs.ResolveGlyphNames"
    static private let ScaleToUnitsPerEmKey:    String = "KernPairs.ScaleToUnitsPerEm"

    required init?(with savePanel: NSSavePanel, allowedFileTypes: [String]) {
        let defaults: [String : Any] = [Self.SaveFileTypeKey: KernTableEntry.GPOSFeatureFileType,
                        Self.ResolveGlyphNamesKey: true,
                        Self.ScaleToUnitsPerEmKey: true]
        UserDefaults.standard.register(defaults: defaults)
        NSUserDefaultsController.shared.initialValues = defaults
        self.savePanel = savePanel
        self.allowedFileTypes = allowedFileTypes
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
        // Do view setup here.
    }

    func saveOptions() {
        UserDefaults.standard.set(selectedFileType, forKey: Self.SaveFileTypeKey)
        UserDefaults.standard.set(shouldResolveGlyphNames, forKey: Self.ResolveGlyphNamesKey)
        UserDefaults.standard.set(scaleToUnitsPerEm, forKey: Self.ScaleToUnitsPerEmKey)
    }
}
