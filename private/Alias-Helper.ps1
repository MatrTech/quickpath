. $PSScriptRoot\..\classes\AliasPathMapping.ps1

function Get-Script-Path {
    $appData = Join-Path $env:LOCALAPPDATA 'quickpath'
    if (-not (Test-Path $appData)) {
        New-Item -Path $appData -ItemType Directory -Force | Out-Null
    }

    $file = Join-Path $appData 'aliases.json'

    if (-not (Test-Path $file)) {
        '[]' | New-Item -Path $file -ItemType File -Force | Out-Null
    }

    return $file
}


function Import-Aliases {
    if (!(Test-Path $script:JSON_FILE_PATH)) {
        '[]' | Out-File -Path $script:JSON_FILE_PATH
    }
    
    $json = Get-Content -Raw -Path $script:JSON_FILE_PATH
    if ([string]::IsNullOrEmpty($json)) {
        $json = '[]'
    }

    try {
        return [AliasPathMapping[]][AliasPathMapping]::FromJsonArray($json)
    }
    catch {
        Write-Warning "Failed to parse aliases JSON; returning empty list. $_"
        return @()
    }
}

function Get-Alias([string[]]$aliases) {
    foreach ($alias in $aliases) {
        $aliasPath = $script:ALIASES | Where-Object { $_.Aliases -contains $alias }
        if ($null -ne $aliasPath) {
            return $aliasPath
        }
    }

    return $null
}

function Resolve-FullPath([string]$path) {
    if ([string]::IsNullOrEmpty($path)) { return $path }

    # expand ~ to user home
    if ($path -like '~*') {
        $path = $path -replace '^(~)', $HOME
    }

    # If already rooted (C:\, \\server\share, / on Linux) get full path
    if ([System.IO.Path]::IsPathRooted($path)) {
        return [System.IO.Path]::GetFullPath($path)
    }

    # otherwise combine with current location and get full path
    $base = (Get-Location).ProviderPath
    return [System.IO.Path]::GetFullPath((Join-Path $base $path))
}

function Add-Alias([string]$argument1, [string]$argument2) {
    if (-not [string]::IsNullOrEmpty($argument2) ) {
        Add-AliasFromPath -alias $argument1 -path $argument2
    }
    else {
        Add-AliasFromJson($argument1)
    }

    $json = [AliasPathMapping]::ToJson($script:ALIASES)
    $json | Out-File $script:JSON_FILE_PATH
}

function Add-AliasFromPath([string]$alias, [string]$path) {
    $resolvedPath = Resolve-FullPath $path

    if (-not (Test-Path $resolvedPath)) {
        Write-Error "Path does not exist: $resolvedPath"
        return $script:ALIASES
    }

    $script:ALIASES = @($script:ALIASES)
    
    $newAliasPath = [AliasPathMapping]::new()
    $newAliasPath.Aliases = @($alias)
    $newAliasPath.WindowsPath = $resolvedPath

    $aliases = $newAliasPath.Aliases
    $aliasPath = (Get-Alias $aliases)

    if ($aliasPath) {
        $aliasPath.Aliases = ($newAliasPath.Aliases + $aliasPath.Aliases) | Select-Object -Unique
        $aliasPath.WindowsPath = [String]::IsNullOrEmpty($newAliasPath.WindowsPath) ? $aliasPath.WindowsPath : $newAliasPath.WindowsPath
        $aliasPath.LinuxPath = [String]::IsNullOrEmpty($newAliasPath.LinuxPath) ? $aliasPath.LinuxPath : $newAliasPath.LinuxPath
        $aliasPath.Solution = [String]::IsNullOrEmpty($newAliasPath.Solution) ? $aliasPath.Solution : $newAliasPath.Solution
    }
    else {
        $script:ALIASES += $newAliasPath
    }

    return $script:ALIASES
}

function Add-AliasFromJson([string]$jsonString) {
    $script:ALIASES = @($script:ALIASES)
    $newAliasPath = [AliasPathMapping]::FromJson($jsonString)

    if (!($newAliasPath)) {
        Write-Output "Could not add alias"
        return $script:ALIASES
    }

    if ($newAliasPath.Aliases.Count -eq 0) {
        Write-Output "No Aliases defined"
        return $script:ALIASES
    }

    $aliases = $newAliasPath.Aliases
    $aliasPath = (Get-Alias $aliases)

    if ($aliasPath) {
        $aliasPath.Aliases = ($newAliasPath.Aliases + $aliasPath.Aliases) | Select-Object -Unique
        $aliasPath.WindowsPath = [String]::IsNullOrEmpty($newAliasPath.WindowsPath) ? $aliasPath.WindowsPath : $newAliasPath.WindowsPath
        $aliasPath.LinuxPath = [String]::IsNullOrEmpty($newAliasPath.LinuxPath) ? $aliasPath.LinuxPath : $newAliasPath.LinuxPath
        $aliasPath.Solution = [String]::IsNullOrEmpty($newAliasPath.Solution) ? $aliasPath.Solution : $newAliasPath.Solution
    }
    else {
        $script:ALIASES += $newAliasPath
    }

    return $script:ALIASES
}

function Remove-Alias([string] $alias) {
    $script:ALIASES = $script:ALIASES | Where-Object { $_.aliases -notcontains $alias }
    $json = [AliasPathMapping]::ToJson($script:ALIASES)
    $json | Out-File $script:JSON_FILE_PATH
}
