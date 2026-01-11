import Foundation

public class AppleDoubleFormat: AppleSingleFormat {
    public override var name: String { NSLocalizedString("AppleDouble Archive", comment: "") }

    override class var signature: UInt32 { 0x00051607 }
}
