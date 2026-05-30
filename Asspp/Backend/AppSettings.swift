//
//  AppSettings.swift
//  Asspp
//
//  Created by Codex on 2026/5/30.
//

import Foundation

enum CompletedDownloadAction: String, Codable, CaseIterable, Identifiable {
    case exportOnly
    case showInstallOptions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .exportOnly:
            String(localized: "Export IPA only")
        case .showInstallOptions:
            String(localized: "Show install options")
        }
    }

    var description: String {
        switch self {
        case .exportOnly:
            String(localized: "Completed downloads show IPA export actions only.")
        case .showInstallOptions:
            String(localized: "Completed downloads also show the built-in install controls.")
        }
    }
}

@Observable
class AppSettings {
    static let this = AppSettings()

    @ObservationIgnored
    private var _completedDownloadAction = Persist<CompletedDownloadAction>(
        key: "CompletedDownloadAction",
        defaultValue: .exportOnly,
    )

    var completedDownloadAction: CompletedDownloadAction {
        get {
            access(keyPath: \.completedDownloadAction)
            return _completedDownloadAction.wrappedValue
        }
        set {
            withMutation(keyPath: \.completedDownloadAction) {
                _completedDownloadAction.wrappedValue = newValue
            }
        }
    }
}
