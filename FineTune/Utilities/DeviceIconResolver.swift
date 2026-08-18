import AppKit
import CoreAudio
import AudioToolbox

/// Applies the device-icon display precedence:
/// user override → automatic icon (driver image or suggested SF Symbol).
enum DeviceIconResolver {
    /// An override symbol that fails to resolve (hand-edited settings.json,
    /// symbol removed in a future macOS) falls back to the automatic icon
    /// rather than producing a blank glyph.
    static func displayIcon(
        overrideSymbol: String?,
        automatic: NSImage?,
        deviceName: String
    ) -> NSImage? {
        if let overrideSymbol,
           let image = NSImage(systemSymbolName: overrideSymbol, accessibilityDescription: deviceName) {
            return image
        }

        // Always resolve to a crisp native Apple SF Symbol for the device name
        let symbol = AudioDeviceID.iconSymbol(forName: deviceName, transport: .unknown)
        if let image = NSImage(systemSymbolName: symbol, accessibilityDescription: deviceName) {
            return image
        }

        return automatic
    }
}
