[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$BinaryPath,

    [string]$OutputPath = "artifacts\BravoERP-Remoto-Agent.msix",
    [string]$IdentityName = "BravoERP.RemotoAgent",
    [string]$Publisher = "CN=BravoERP Store Placeholder",
    [ValidatePattern('^\d+\.\d+\.\d+\.\d+$')]
    [string]$Version = "1.0.0.0",
    [ValidateSet('x64', 'x86', 'arm64')]
    [string]$Architecture = "x64",
    [string]$MakeAppxPath
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$resolvedBinary = (Resolve-Path $BinaryPath).Path
$resolvedOutput = [System.IO.Path]::GetFullPath((Join-Path $repoRoot $OutputPath))
$stagingRoot = Join-Path $repoRoot "artifacts\msix-$Architecture"

if (-not $MakeAppxPath) {
    $kitsBin = 'C:\Program Files (x86)\Windows Kits\10\bin'
    $MakeAppxPath = Get-ChildItem $kitsBin -Filter makeappx.exe -Recurse |
        Where-Object { $_.FullName -match '\\x64\\makeappx\.exe$' } |
        Sort-Object FullName -Descending |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $MakeAppxPath -or -not (Test-Path $MakeAppxPath)) {
    throw 'No se encontro makeappx.exe. Instale Windows SDK 10 o indique -MakeAppxPath.'
}

if (Test-Path $stagingRoot) {
    Remove-Item -LiteralPath $stagingRoot -Recurse -Force
}
New-Item -ItemType Directory -Path (Join-Path $stagingRoot 'Assets') -Force | Out-Null
New-Item -ItemType Directory -Path ([System.IO.Path]::GetDirectoryName($resolvedOutput)) -Force | Out-Null

Copy-Item -LiteralPath $resolvedBinary -Destination (Join-Path $stagingRoot 'BravoERP-Remoto-Agent.exe')

$manifest = Get-Content (Join-Path $PSScriptRoot 'AppxManifest.xml.in') -Raw
$manifest = $manifest.Replace('@@IDENTITY_NAME@@', $IdentityName)
$manifest = $manifest.Replace('@@PUBLISHER@@', $Publisher)
$manifest = $manifest.Replace('@@VERSION@@', $Version)
$manifest = $manifest.Replace('@@ARCHITECTURE@@', $Architecture)
[System.IO.File]::WriteAllText(
    (Join-Path $stagingRoot 'AppxManifest.xml'),
    $manifest,
    [System.Text.UTF8Encoding]::new($false)
)

Add-Type -AssemblyName System.Drawing
function New-BravoErpLogo {
    param([int]$Size, [string]$Path)
    $bitmap = [System.Drawing.Bitmap]::new($Size, $Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $margin = [Math]::Max(1, [int]($Size * 0.08))
        $brush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(37, 99, 235))
        $font = [System.Drawing.Font]::new('Segoe UI', [single]($Size * 0.42), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
        $textBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::White)
        try {
            $graphics.FillEllipse($brush, $margin, $margin, $Size - (2 * $margin), $Size - (2 * $margin))
            $format = [System.Drawing.StringFormat]::new()
            $format.Alignment = [System.Drawing.StringAlignment]::Center
            $format.LineAlignment = [System.Drawing.StringAlignment]::Center
            $graphics.DrawString('B', $font, $textBrush, [System.Drawing.RectangleF]::new(0, 0, $Size, $Size), $format)
            $format.Dispose()
        }
        finally {
            $textBrush.Dispose()
            $font.Dispose()
            $brush.Dispose()
        }
        $bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}

New-BravoErpLogo -Size 44 -Path (Join-Path $stagingRoot 'Assets\Square44x44Logo.png')
New-BravoErpLogo -Size 150 -Path (Join-Path $stagingRoot 'Assets\Square150x150Logo.png')
New-BravoErpLogo -Size 50 -Path (Join-Path $stagingRoot 'Assets\StoreLogo.png')

if (Test-Path $resolvedOutput) {
    Remove-Item -LiteralPath $resolvedOutput -Force
}
& $MakeAppxPath pack /o /d $stagingRoot /p $resolvedOutput
if ($LASTEXITCODE -ne 0) {
    throw "MakeAppx fallo con codigo $LASTEXITCODE."
}

$hash = (Get-FileHash -LiteralPath $resolvedOutput -Algorithm SHA256).Hash.ToLowerInvariant()
$hashPath = "$resolvedOutput.sha256"
"$hash  $([System.IO.Path]::GetFileName($resolvedOutput))" | Set-Content -LiteralPath $hashPath -Encoding ascii

Write-Host "MSIX creado: $resolvedOutput"
Write-Host "SHA-256: $hash"
Write-Warning 'El Publisher es provisional. Reemplacelo por el valor exacto asignado en Partner Center antes de enviar a Microsoft Store.'
