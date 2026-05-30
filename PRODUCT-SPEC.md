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
- Keep built-in install controls available on completed download pages while presenting IPA export first.
- When using the built-in iOS OTA installer, generate the manifest with the IPA build version from saved App Store metadata.
- Show completed-package OTA version diagnostics so users can verify the build version and metadata source before installing.
- Download available updates for tracked macOS-connected iOS devices without directly installing them, then show the downloaded IPA for export or manual install.

## Signing Boundary

Asspp injects App Store SINF and iTunes metadata returned by ApplePackage so the saved IPA matches the App Store download data as closely as possible. Asspp does not re-sign downloaded IPAs with a user P12 certificate.

The fork auto-build P12 workflow signs the Asspp application itself only. Users who want to sign downloaded IPAs should export the IPA and use an external signing tool.

## Known Constraints

- App Store IPAs may remain subject to Apple account authorization and FairPlay restrictions.
- External signing can help with sideloading workflows, but it does not remove DRM or guarantee that every IPA can be installed or launched.
- External installation may fail when an existing app on the device has an incompatible signature, provisioning profile, or installation source.
- OTA installation depends on accurate manifest metadata; the manifest should use the IPA build version, not only the App Store display version.
- `Resources/Scripts/verify.ota.manifest.ps1` guards this OTA manifest invariant during local review.
- Downloaded IPA files are stored under `Documents/Asspp/Packages/<bundle id>/<version>/<uuid>.ipa` inside the app sandbox.
