$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")

$packageManifest = Get-Content -Raw -Path (Join-Path $repoRoot "Asspp\Backend\Downloader\PackageManifest.swift")
$installerCompute = Get-Content -Raw -Path (Join-Path $repoRoot "Asspp\Backend\Installer\Installer+Compute.swift")
$packageView = Get-Content -Raw -Path (Join-Path $repoRoot "Asspp\Interface\Download\PackageView.swift")

if ($packageManifest -notmatch "var\s+installBundleVersion\s*:\s*String") {
    throw "PackageManifest must expose installBundleVersion for OTA installs."
}

if ($packageManifest -notmatch "iTunesMetadata" -or $packageManifest -notmatch "bundleVersion") {
    throw "installBundleVersion must read bundleVersion from saved iTunesMetadata."
}

if ($packageManifest -notmatch "installBundleVersionSource") {
    throw "PackageManifest must expose the OTA bundle version source for diagnostics."
}

if ($installerCompute -notmatch '"bundle-version"\s*:\s*bundleVersion') {
    throw "OTA manifest bundle-version must use the downloaded IPA build version."
}

if ($installerCompute -match '"bundle-version"\s*:\s*archive\.software\.version\s*,') {
    throw "OTA manifest bundle-version must not be written directly from the App Store display version."
}

if ($packageView -notmatch "Installer\(archive:\s*archive,\s*path:\s*url,\s*bundleVersion:\s*pkg\.installBundleVersion\)") {
    throw "PackageView must pass PackageManifest.installBundleVersion into Installer."
}

if ($packageView -notmatch "OTA Build Version" -or $packageView -notmatch "OTA Version Source") {
    throw "PackageView must show OTA version diagnostics on completed packages."
}

Write-Output "OTA manifest verification passed."
