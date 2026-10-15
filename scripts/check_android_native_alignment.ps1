param(
    [string]$BundlePath = 'build/app/outputs/bundle/release/app-release.aab',
    [string]$SdkPath = $env:ANDROID_HOME
)
$ErrorActionPreference = 'Stop'
$workspacePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
Push-Location $workspacePath
try {
    if (!$SdkPath) { $SdkPath = Join-Path $env:LOCALAPPDATA 'Android/Sdk' }
    $ndk = Get-ChildItem (Join-Path $SdkPath 'ndk') -Directory | Sort-Object Name -Descending | Select-Object -First 1
    if (!$ndk) { throw 'Android NDK is missing.' }
    $objdump = Join-Path $ndk.FullName 'toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-objdump.exe'
    $readelf = Join-Path $ndk.FullName 'toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-readelf.exe'
    if (!(Test-Path $objdump) -or !(Test-Path $readelf)) { throw 'Android NDK ELF tools are missing.' }
    $outputPath = Join-Path $workspacePath 'build/release-audit/native'
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $archive = [IO.Compression.ZipFile]::OpenRead([IO.Path]::GetFullPath($BundlePath))
    try {
        $results = foreach ($entry in $archive.Entries) {
            if ($entry.FullName -notmatch '^base/lib/(arm64-v8a|x86_64)/([^/]+\.so)$') { continue }
            $abi = $Matches[1]
            $name = $Matches[2]
            $abiPath = Join-Path $outputPath $abi
            New-Item -ItemType Directory -Path $abiPath -Force | Out-Null
            $targetPath = Join-Path $abiPath $name
            [IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $targetPath, $true)
            $loads = & $objdump -p $targetPath | Select-String 'LOAD'
            if ($LASTEXITCODE -ne 0) { throw "Unable to inspect $name" }
            $badLoads = @($loads | Where-Object {
                $_ -match 'align 2\*\*(\d+)' -and [int]$Matches[1] -lt 14
            })
            $relro = & $readelf -W -l $targetPath | Select-String 'GNU_RELRO'
            if ($LASTEXITCODE -ne 0) { throw "Unable to inspect RELRO in $name" }
            $badRelro = @($relro | Where-Object {
                $fields = $_.Line.Trim() -split '\s+'
                $address = [Convert]::ToInt64($fields[2].Substring(2), 16)
                $memorySize = [Convert]::ToInt64($fields[5].Substring(2), 16)
                (($address + $memorySize) % 16384) -ne 0
            })
            [pscustomobject]@{
                ABI = $abi; Library = $name
                LoadSegmentsAligned = ($loads.Count -gt 0 -and $badLoads.Count -eq 0)
                RelroAligned = ($badRelro.Count -eq 0)
            }
        }
    } finally { $archive.Dispose() }
    if (!$results) { throw 'No 64-bit native libraries were found in the bundle.' }
    $results | ConvertTo-Json | Set-Content 'build/release-audit/native-alignment.json' -Encoding UTF8
    $results | Format-Table -AutoSize
    if (@($results | Where-Object { !$_.LoadSegmentsAligned -or !$_.RelroAligned }).Count) {
        throw 'Native libraries are not fully 16 KB aligned. Update the responsible dependencies.'
    }
    Write-Output '64-bit ELF LOAD and RELRO alignment checks passed. APK packaging and actual 16 KB device testing are still required.'
} finally { Pop-Location }
