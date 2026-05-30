# Product Spec

## Purpose

Asspp helps users with multiple Apple IDs search App Store regions, download IPA packages, keep versioned IPA archives, and export those IPA files for backup, analysis, external signing, or installation in another tool.

Fork-specific implementation details are documented in [FORK-CHANGES.md](./FORK-CHANGES.md).

## Core Workflows

- Add Apple ID accounts and use the account that matches the target App Store region.
- Search App Store apps by keyword, open product details, and inspect version metadata.
- Download the current version or historical versions of an app.
- Keep multiple downloads for the same app version instead of forcing the user to delete the existing IPA first.
- Export completed IPA files through the platform share UI, AirDrop on iOS, or Finder on macOS.
- Let users choose the completed-download behavior in Settings: export IPA only, or show built-in install options in addition to export actions.
- Download available updates for tracked macOS-connected iOS devices without directly installing them by default. If install options are enabled, the macOS update flow may install with `devicectl`.

## Signing Boundary

Asspp injects App Store SINF and iTunes metadata returned by ApplePackage so the saved IPA matches the App Store download data as closely as possible. Asspp does not re-sign downloaded IPAs with a user P12 certificate.

The fork auto-build P12 workflow signs the Asspp application itself only. Users who want to sign downloaded IPAs should export the IPA and use an external signing tool.

## Known Constraints

- App Store IPAs may remain subject to Apple account authorization and FairPlay restrictions.
- External signing can help with sideloading workflows, but it does not remove DRM or guarantee that every IPA can be installed or launched.
- External installation may fail when an existing app on the device has an incompatible signature, provisioning profile, or installation source.
- Downloaded IPA files are stored under `Documents/Asspp/Packages/<bundle id>/<version>/<uuid>.ipa` inside the app sandbox.
