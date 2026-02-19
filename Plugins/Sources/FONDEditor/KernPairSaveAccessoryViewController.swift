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

    @objc dynamic var allowedFileTypes: [String] = [KernPairExporter.GPOSFeatureFileType,
                                                    KernPairExporter.CSVFileType]
    @objc dynamic var selectedFileType: String {
        didSet {
            updateUI()
        }
    }

    @objc dynamic var shouldResolveGlyphNames:  Bool
    @objc dynamic var scaleToUnitsPerEm:        Bool

    var config: KernPairExporter.Config {
        KernPairExporter.Config(format: (selectedFileType == KernPairExporter.GPOSFeatureFileType ? .GPOS : .CSV),
                                       resolveGlyphNames: shouldResolveGlyphNames,
                                       scaleToUnitsPerEm: scaleToUnitsPerEm)
    }

    private static let SaveFileTypeKey:         String = "KernPairs.SaveFileType"
    private static let ResolveGlyphNamesKey:    String = "KernPairs.ResolveGlyphNames"
    private static let ScaleToUnitsPerEmKey:    String = "KernPairs.ScaleToUnitsPerEm"

    required init(with panel: NSSavePanel) {
        let defaults: [String : Any] = [Self.SaveFileTypeKey: KernPairExporter.GPOSFeatureFileType,
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
        updateUI()
    }

    func updateUI() {
        guard let panel else { return }
        /// Try to change filename extension in save panel's field
        /// by limiting the allowed UT types to the currently selected one.
        /// This only appears to work to change .txt to .csv, but not the
        /// other way around.
        if selectedFileType == KernPairExporter.GPOSFeatureFileType {
            panel.allowedFileTypes = [KernPairExporter.GPOSFeatureUTType]
            shouldResolveGlyphNames = true
            scaleToUnitsPerEm = true
        } else {
            panel.allowedFileTypes = [KernPairExporter.CSVUTType]
        }
        /// GPOS format must have both scale and glyph names resolved
        scaleCheckbox.isEnabled = selectedFileType != KernPairExporter.GPOSFeatureFileType
        resolveCheckbox.isEnabled = selectedFileType != KernPairExporter.GPOSFeatureFileType
    }

    func saveOptions() {
        UserDefaults.standard.set(selectedFileType, forKey: Self.SaveFileTypeKey)
        UserDefaults.standard.set(shouldResolveGlyphNames, forKey: Self.ResolveGlyphNamesKey)
        UserDefaults.standard.set(scaleToUnitsPerEm, forKey: Self.ScaleToUnitsPerEmKey)
    }
}
