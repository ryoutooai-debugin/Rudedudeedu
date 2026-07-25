# Recraft V4.1 vector output bakes an opaque full-canvas background as the FIRST <path>.
# Strip it so the mascot composites onto dark navy (#1a1a2e) as well as white cards.
# Usage: .\strip-bg.ps1 in.svg out.svg
param(
    [Parameter(Mandatory = $true)][string]$In,
    [Parameter(Mandatory = $true)][string]$Out
)

$svg = Get-Content -Raw -LiteralPath $In

# Match a full-canvas rectangle path drawn as M 0 0 L W 0 L W H L 0 H L 0 0 z with a solid fill.
$pattern = '<path\s+d="M\s*0\s*0\s*L\s*[\d.]+\s*0\s*L\s*[\d.]+\s*[\d.]+\s*L\s*0\s*[\d.]+\s*L\s*0\s*0\s*z"\s*fill="rgb\(\d+,\s*\d+,\s*\d+\)"[^>]*>\s*(?:</path>)?'

$stripped = [regex]::Replace($svg, $pattern, '', 'IgnoreCase')

if ($stripped -eq $svg) {
    Write-Warning "No full-canvas background path found in $In - left unchanged."
}
else {
    Write-Output "Stripped background from $(Split-Path -Leaf $In)"
}

Set-Content -LiteralPath $Out -Value $stripped -Encoding utf8
