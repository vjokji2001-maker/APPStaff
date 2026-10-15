param([string]$ConfigPath = 'config/release.json')
$ErrorActionPreference = 'Stop'
$workspacePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Push-Location $workspacePath
try {
    if (!(Test-Path -LiteralPath $ConfigPath)) {
        throw 'Copy config/release.example.json to config/release.json and fill the real HTTPS URLs first.'
    }
    $config = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    foreach ($name in @('SMARTCARE_BASE_URL', 'HR_BASE_URL', 'SAM_BASE_URL', 'PRIVACY_POLICY_URL')) {
        $value = [string]$config.$name
        $uri = $null
        if (![Uri]::TryCreate($value, [UriKind]::Absolute, [ref]$uri) -or
            $uri.Scheme -ne 'https' -or !$uri.Host -or $uri.UserInfo) {
            throw "$name must be a real HTTPS URL without embedded credentials."
        }
        if ($uri.Host -match '(^|\.)(example\.(com|org|net)|localhost|test)$') {
            throw "$name still points to a placeholder/local server."
        }
    }
    if (!(Test-Path 'android/key.properties') -or !(Test-Path 'android/app/upload-keystore.jks')) {
        throw 'Release signing files are missing. Follow docs/PLAY_STORE_RELEASE.md.'
    }
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'Dependency resolution failed.' }
    & flutter analyze --no-fatal-infos --no-fatal-warnings
    if ($LASTEXITCODE -ne 0) { throw 'Dart analysis found errors. Fix them before building.' }
    & flutter test
    if ($LASTEXITCODE -ne 0) { throw 'Tests failed. Release stopped.' }
    & flutter build appbundle --release "--dart-define-from-file=$ConfigPath"
    if ($LASTEXITCODE -ne 0) { throw 'Release bundle build failed.' }
    & (Join-Path $PSScriptRoot 'check_android_native_alignment.ps1')
    Write-Output 'Bundle built. Complete real-device, API and Play internal testing before production rollout.'
} finally {
    Pop-Location
}
