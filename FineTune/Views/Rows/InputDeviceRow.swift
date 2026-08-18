// FineTune/Views/Rows/InputDeviceRow.swift
import SwiftUI

/// A row displaying an input device (microphone) with volume controls
/// Used in the Input Devices section
struct InputDeviceRow: View {
    let device: AudioDevice
    let isDefault: Bool
    let volume: Float
    let isMuted: Bool
    let onSetDefault: () -> Void
    let onVolumeChange: (Float) -> Void
    let onMuteToggle: () -> Void
    let isFocused: Bool
    let iconOverrideSymbol: String?

    @State private var sliderValue: Double
    @State private var isEditing = false
    /// Suppresses write-back when slider is being synced from a device volume change.
    /// Breaks the quantization feedback loop on USB DACs with discrete dB steps.
    @State private var isUpdatingSliderFromDevice = false

    /// The displayed percentage value, matching EditablePercentage's formula.
    private var displayedPercentage: Int { Int(round(sliderValue * 100)) }

    /// Show muted icon when system muted OR displayed volume is 0%.
    /// Uses percentage threshold (not exact sliderValue == 0) because SwiftUI Slider
    /// and volume clamping can leave sliderValue at tiny non-zero values (e.g. 0.003)
    /// that display as "0%" but fail exact Double equality.
    private var showMutedIcon: Bool { isMuted || displayedPercentage == 0 }

    /// Default volume to restore when unmuting from 0 (50%)
    private let defaultUnmuteVolume: Double = 0.5

    private var displayIcon: NSImage? {
        DeviceIconResolver.displayIcon(
            overrideSymbol: iconOverrideSymbol,
            automatic: device.icon,
            deviceName: device.name
        )
    }

    init(
        device: AudioDevice,
        isDefault: Bool,
        volume: Float,
        isMuted: Bool,
        onSetDefault: @escaping () -> Void,
        onVolumeChange: @escaping (Float) -> Void,
        onMuteToggle: @escaping () -> Void,
        isFocused: Bool = false,
        iconOverrideSymbol: String? = nil
    ) {
        self.device = device
        self.isDefault = isDefault
        self.volume = volume
        self.isMuted = isMuted
        self.onSetDefault = onSetDefault
        self.onVolumeChange = onVolumeChange
        self.onMuteToggle = onMuteToggle
        self.isFocused = isFocused
        self.iconOverrideSymbol = iconOverrideSymbol
        self._sliderValue = State(initialValue: Double(volume))
    }

    var body: some View {
        deviceHeader
            .contentShape(Rectangle())
            .onTapGesture {
                if !isDefault {
                    onSetDefault()
                }
            }
            .hoverableRow(isFocused: isFocused)
            .onChange(of: volume) { _, newValue in
                // Skip external sync mid-drag.
                guard !isEditing else { return }
                let newSlider = Double(newValue)
                guard newSlider != sliderValue else { return }
                isUpdatingSliderFromDevice = true
                sliderValue = newSlider
            }
    }

    // MARK: - Device Header

    private var deviceHeader: some View {
        HStack(spacing: 8) {
            DeviceBadge(icon: displayIcon, isSelected: isDefault, fallbackSymbol: "mic.fill")

            // Device name
            Text(device.name)
                .font(.system(size: 12.5, weight: isDefault ? .semibold : .regular))
                .foregroundStyle(isDefault ? DesignTokens.Colors.textPrimary : DesignTokens.Colors.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Mute button (mic icon)
            InputMuteButton(isMuted: showMutedIcon) {
                if showMutedIcon {
                    if displayedPercentage == 0 {
                        sliderValue = defaultUnmuteVolume
                    }
                    if isMuted {
                        onMuteToggle()
                    }
                } else {
                    onMuteToggle()
                }
            }

            // Volume slider
            LiquidGlassSlider(
                value: $sliderValue,
                onEditingChanged: { editing in
                    isEditing = editing
                }
            )
            .frame(width: 100)
            .opacity(showMutedIcon ? 0.5 : 1.0)
            .onChange(of: sliderValue) { _, newValue in
                if isUpdatingSliderFromDevice {
                    isUpdatingSliderFromDevice = false
                    return
                }
                onVolumeChange(Float(newValue))
                if isMuted && newValue > 0 {
                    onMuteToggle()
                }
            }
            .scrollWheelStep($sliderValue, in: 0.0...1.0)

            // Active checkmark
            if isDefault {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 14)
            } else {
                Color.clear
                    .frame(width: 14)
            }
        }
        .frame(height: 28)
    }
}

// MARK: - Previews

#Preview("Input Device Row - Default") {
    PreviewContainer {
        VStack(spacing: 0) {
            InputDeviceRow(
                device: AudioDevice(
                    id: 1,
                    uid: "built-in-mic",
                    name: "MacBook Pro Microphone",
                    icon: nil,
                    supportsAutoEQ: false
                ),
                isDefault: true,
                volume: 0.75,
                isMuted: false,
                onSetDefault: {},
                onVolumeChange: { _ in },
                onMuteToggle: {}
            )

            InputDeviceRow(
                device: AudioDevice(
                    id: 2,
                    uid: "usb-mic",
                    name: "Blue Yeti",
                    icon: nil,
                    supportsAutoEQ: false
                ),
                isDefault: false,
                volume: 1.0,
                isMuted: false,
                onSetDefault: {},
                onVolumeChange: { _ in },
                onMuteToggle: {}
            )

            InputDeviceRow(
                device: AudioDevice(
                    id: 3,
                    uid: "airpods-mic",
                    name: "AirPods Pro",
                    icon: nil,
                    supportsAutoEQ: false
                ),
                isDefault: false,
                volume: 0.5,
                isMuted: true,
                onSetDefault: {},
                onVolumeChange: { _ in },
                onMuteToggle: {}
            )
        }
    }
}
