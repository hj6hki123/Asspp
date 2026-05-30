# Fork Changes

This fork keeps the upstream Asspp foundation, but changes the main user workflow from "download and install with Asspp" to "download, preserve, and export IPA files for external signing tools."

The goal is to make Asspp useful as an IPA acquisition and archive manager while leaving code signing and final installation to tools chosen by the user.

## Summary

- Completed downloads are presented as IPA files first.
- Completed downloads show IPA export actions first while keeping built-in install controls available.
- Users can export downloaded IPA files through the system share sheet, AirDrop on iOS, or Finder on macOS.
- The same app version can be downloaded multiple times, so users do not need to delete an existing download before obtaining another copy.
- The macOS connected-device update flow downloads the newer IPA and shows it to the user instead of installing it directly with `devicectl`.
- iOS OTA install manifests now use the downloaded IPA's build version instead of the App Store display version.
- The GitHub Actions build workflow now selects an Xcode installation that actually contains the required iPhoneOS SDK.
- Project documentation now separates "signing Asspp itself" from "signing downloaded IPA files."

## User-Facing Behavior Changes

### IPA Export First

Original behavior:

- A completed download emphasized direct installation actions.
- iOS showed a built-in `Install` action using Asspp's local OTA installer.
- macOS showed a connected-device install section backed by `devicectl`.

Fork behavior:

- A completed download now shows an `IPA File` section first.
- `Export IPA` uses SwiftUI `ShareLink` so the file can be passed to Files, AirDrop, a signing app, or another destination supported by the platform.
- iOS keeps an explicit `Send IPA via AirDrop` action.
- macOS keeps a `Show in Finder` action for direct file access.
- Built-in install controls remain available below the IPA export section.
- IPA files are stored inside the app sandbox at `Documents/Asspp/Packages/<bundle id>/<version>/<uuid>.ipa`.

Touched file:

- `Asspp/Interface/Download/PackageView.swift`

### Re-Download Without Deleting

Original behavior:

- Product pages only showed `Show Download` if the same app version already existed in the download list.
- Users had to delete the existing download before requesting another copy of the same app version.

Fork behavior:

- Product pages now show both `Show Download` and `Download Again` when a matching download already exists.
- Version rows can also request another copy of an already downloaded version.
- The download lookup returns the newest matching request, while all copies remain in the download list.

Touched files:

- `Asspp/Backend/Downloader/Downloads.swift`
- `Asspp/Interface/Search/ProductView.swift`
- `Asspp/Interface/Search/ProductVersionView.swift`

### Update Flow Downloads IPA Instead Of Installing

Original behavior:

- On macOS, the installed-app update flow downloaded the latest IPA and then immediately installed it on the connected device with `devicectl`.
- If iOS rejected the install because of signing, provisioning, or existing-app compatibility, the user could be forced to delete the installed app first.

Fork behavior:

- The update flow still checks App Store metadata and downloads the newer IPA.
- After download completion, it moves to a `downloaded` state.
- The UI shows `Show IPA`, letting the user open the package detail page and export the file for external signing or installation.
- Asspp no longer attempts to replace the installed app during this update flow.

Touched files:

- `Asspp/Backend/DeviceCTL/DeviceManager.swift`
- `Asspp/Interface/Installed/InstalledListView.swift`

### OTA Install Manifest Uses Build Version

Original behavior:

- The iOS OTA manifest wrote `bundle-version` from `archive.software.version`.
- That value is the App Store display version, not necessarily the IPA's `CFBundleVersion`.
- When installing over an existing app, iOS uses the manifest metadata to decide whether the package is a valid update candidate.

Fork behavior:

- Completed downloads read the saved App Store `iTunesMetadata.plist` and use its `bundleVersion` value for OTA installation.
- If metadata is missing, the installer falls back to the package display version so older or incomplete records still produce a manifest.
- This keeps the OTA manifest aligned with the actual downloaded App Store package and removes one concrete cause of "already installed" update rejection.
- Completed package details show `OTA Build Version` and `OTA Version Source` so failed installs can be diagnosed from the value actually sent to iOS.

Touched files:

- `Asspp/Backend/Downloader/PackageManifest.swift`
- `Asspp/Backend/Installer/Installer.swift`
- `Asspp/Backend/Installer/Installer+Compute.swift`
- `Asspp/Interface/Download/PackageView.swift`
- `Resources/Scripts/verify.ota.manifest.ps1`

## Signing Boundary

This fork does not add P12-based signing for downloaded IPA files.

Asspp still injects App Store SINF and iTunes metadata returned by ApplePackage into downloaded packages. That process is not the same as developer certificate signing. It helps preserve App Store download metadata, but it does not re-sign the app with the user's Apple Developer certificate.

The fork auto-build workflow can sign the Asspp application itself. That certificate flow does not sign IPAs downloaded inside Asspp.

Recommended workflow:

1. Use Asspp to download and export the IPA.
2. Use an external tool such as SideStore, AltStore, TrollStore, or a personal signing workflow to sign or install the exported IPA.
3. Treat App Store FairPlay and account authorization as separate constraints. External signing does not remove DRM and may not make every IPA installable or runnable.

Related files:

- `Asspp/Backend/Downloader/Downloads.swift`
- `.github/workflows/upstream-signed-ios.yml`
- `Resources/Document/FORK_AUTOBUILD_GUIDE.md`

## GitHub Actions Changes

### Build App Workflow

Original behavior:

- `.github/workflows/build.yml` selected `/Applications/Xcode_26.0.app` directly.
- On runners where that Xcode installation existed but did not include the iPhoneOS SDK, the iOS job failed before compilation with no matching `generic/platform=iOS` destination.

Fork behavior:

- The iOS job now tries several Xcode installations and only accepts one where `xcodebuild -showsdks` contains `iphoneos`.
- The macOS job also selects the first available Xcode installation and prints the selected version.
- Both build jobs run the OTA manifest metadata verifier before compiling.

Touched file:

- `.github/workflows/build.yml`

### Upstream Signed iOS Build

The repository still contains the upstream signed build workflow. It can be triggered manually and may also be scheduled depending on the current workflow configuration. Users concerned about Actions usage should disable or reduce the schedule in `.github/workflows/upstream-signed-ios.yml`.

Touched file:

- `.github/workflows/upstream-signed-ios.yml`

## Documentation Changes

- `README.md` links to this file and summarizes IPA export/signing behavior.
- `PRODUCT-SPEC.md` documents the fork's intended product behavior.
- `AGENTS.md` documents the current architecture and developer expectations.

## Files Changed By This Fork

- `.github/workflows/build.yml`
- `.github/workflows/upstream-signed-ios.yml`
- `AGENTS.md`
- `PRODUCT-SPEC.md`
- `README.md`
- `Asspp/Backend/DeviceCTL/DeviceManager.swift`
- `Asspp/Backend/Downloader/PackageManifest.swift`
- `Asspp/Backend/Downloader/Downloads.swift`
- `Asspp/Backend/Installer/Installer.swift`
- `Asspp/Backend/Installer/Installer+Compute.swift`
- `Asspp/Interface/Download/PackageView.swift`
- `Asspp/Interface/Installed/InstalledListView.swift`
- `Asspp/Interface/Search/ProductVersionView.swift`
- `Asspp/Interface/Search/ProductView.swift`
- `Resources/Scripts/verify.ota.manifest.ps1`

## Not Changed

- This fork does not remove ApplePackage or replace the App Store download implementation.
- This fork does not bypass FairPlay, DRM, or Apple account authorization.
- This fork does not provide built-in P12 signing for downloaded IPAs.
- This fork does not guarantee that an exported App Store IPA can be installed after external signing.
