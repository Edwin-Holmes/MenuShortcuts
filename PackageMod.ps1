$workspaceRoot = Get-Location
$workspaceName = Split-Path -Leaf $workspaceRoot
$modName       = "mod$workspaceName"

# Repo-local Temp folder
$buildRoot = "$workspaceRoot\Temp\$workspaceName"
$zipPath   = "$workspaceRoot\Temp\$workspaceName.zip"

# Prompt if zip already exists
if (Test-Path $zipPath) {
    $response = Read-Host "File $zipPath already exists. Overwrite? (y/n)"
    if ($response -ne "y") {
        Write-Host "Aborted packaging."
        exit
    }
    Remove-Item $zipPath -Force
}

# Paths
$binPath     = "$buildRoot\bin\config\r4game\user_config_matrix\pc"
$modPath     = "$buildRoot\mods\$modName"
$contentPath = "$modPath\content"

# Clean staging area
if (Test-Path $buildRoot) { Remove-Item $buildRoot -Recurse -Force }
New-Item -Force -ItemType Directory -Path $contentPath | Out-Null

# Define exclusion rule
function NotIgnored($item) {
    return ($item.FullName -notmatch '\\Ignored\\')
}

# Copy scripts folder exactly as-is, excluding Ignored
Get-ChildItem "$workspaceRoot\scripts" -Recurse | Where-Object { NotIgnored $_ } | ForEach-Object {
    $dest = $_.FullName.Replace($workspaceRoot, $contentPath)
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item $_.FullName $dest -Force
}

# Copy w3strings (search anywhere), excluding Ignored
Get-ChildItem $workspaceRoot -Recurse -Filter *.w3strings | Where-Object { NotIgnored $_ } | ForEach-Object {
    Copy-Item $_.FullName $contentPath
}

# Copy *.settings.txt (search anywhere), excluding Ignored
Get-ChildItem $workspaceRoot -Recurse -Filter *.settings.txt | Where-Object { NotIgnored $_ } | ForEach-Object {
    Copy-Item $_.FullName $modPath
}

# Copy XMLs (search anywhere), excluding Ignored
$xmlFiles = Get-ChildItem $workspaceRoot -Recurse -Filter *.xml | Where-Object { NotIgnored $_ }
if ($xmlFiles) {
    New-Item -Force -ItemType Directory -Path $binPath | Out-Null
    $xmlFiles | ForEach-Object {
        Copy-Item $_.FullName $binPath
    }
}

# Remove empty bin if created but unused
if ((Test-Path $binPath) -and (-not (Get-ChildItem $binPath -Recurse))) {
    Remove-Item "$buildRoot\bin" -Recurse -Force
}

# Zip only the staged buildRoot contents
Compress-Archive -Path "$buildRoot\*" -DestinationPath $zipPath -Force

Write-Host "Packaged $zipPath successfully!"

# Remove staging folder now that zip is created
Remove-Item $buildRoot -Recurse -Force