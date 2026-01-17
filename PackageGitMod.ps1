# PackageMod.ps1
# Builds Witcher-style mod structure and outputs a zip in project root
# Cleans up the structured folder after packaging

$workspaceRoot = Get-Location
$workspaceName = Split-Path -Leaf $workspaceRoot
$modName       = "mod$workspaceName"

# Paths
$buildRoot = "$workspaceRoot\$modName"
$zipPath   = "$workspaceRoot\$workspaceName.zip"

# Remove old zip if present
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

# Define structure paths
$binPath     = "$buildRoot\bin\config\r4game\user_config_matrix\pc"
$modPath     = "$buildRoot\mods\$modName"
$contentPath = "$modPath\content"

# Ensure base directories exist
New-Item -Force -ItemType Directory -Path $contentPath | Out-Null

# Exclusion rule
function NotIgnored($item) {
    return ($item.FullName -notmatch '\\Ignored\\')
}

# Copy scripts folder (excluding Ignored)
Get-ChildItem "$workspaceRoot\scripts" -Recurse | Where-Object { NotIgnored $_ } | ForEach-Object {
    $dest = $_.FullName.Replace($workspaceRoot, $contentPath)
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item $_.FullName $dest -Force
}

# Copy w3strings (excluding Ignored)
Get-ChildItem $workspaceRoot -Recurse -Filter *.w3strings | Where-Object { NotIgnored $_ } | ForEach-Object {
    Copy-Item $_.FullName $contentPath
}

# Copy *.settings.txt (excluding Ignored)
Get-ChildItem $workspaceRoot -Recurse -Filter *.settings.txt | Where-Object { NotIgnored $_ } | ForEach-Object {
    Copy-Item $_.FullName $modPath
}

# Copy XMLs (excluding Ignored)
$xmlFiles = Get-ChildItem $workspaceRoot -Recurse -Filter *.xml | Where-Object { NotIgnored $_ }
if ($xmlFiles) {
    New-Item -Force -ItemType Directory -Path $binPath | Out-Null
    $xmlFiles | ForEach-Object {
        Copy-Item $_.FullName $binPath
    }
}

# Remove empty bin if unused
if ((Test-Path $binPath) -and (-not (Get-ChildItem $binPath -Recurse))) {
    Remove-Item "$buildRoot\bin" -Recurse -Force
}

# Zip the structured mod folder
Compress-Archive -Path "$buildRoot\*" -DestinationPath $zipPath -Force

Write-Host "Packaged $zipPath successfully!"

# Clean up the structured folder, leaving only the zip
Remove-Item $buildRoot -Recurse -Force