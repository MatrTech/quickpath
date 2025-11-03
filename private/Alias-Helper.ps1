. $PSScriptRoot\..\classes\AliasPathMapping.ps1

$aliases = @()

function Get-AliasFilePath {
    if ($IsWindows) {
        $baseDir = $env:LOCALAPPDATA ?? (Join-Path $env:USERPROFILE "AppData\Local")
    } else {
        $baseDir = $env:XDG_DATA_HOME ?? (Join-Path $HOME ".local/share")
    }
    
    Write-Host "Base directory for aliases: $baseDir" -ForegroundColor Yellow
    $aliasFilePath = Join-Path $baseDir "quickpath" "aliases.json"
    Write-Host "Alias file path: $aliasFilePath" -ForegroundColor Yellow
    return $aliasFilePath
}

function Import-Aliases {
    param(
        [string]$aliasFilePath
    )

    if ([string]::IsNullOrWhiteSpace($aliasFilePath)) {
        if ([string]::IsNullOrWhiteSpace($aliasFilePath)) { return @() }
    }
    
    if (!(Test-Path $aliasFilePath)) {
        '[]' | Out-File -Path $aliasFilePath
    }

    $json = Get-Content -Raw -Path $aliasFilePath
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

function Add-Alias {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$argument1, 
        [string]$argument2
    )

    Write-Verbose "Adding alias with argument1: $argument1, argument2: $argument2"

    if (-not [string]::IsNullOrEmpty($argument2) ) {
        Write-Verbose "Adding alias: $argument1 from path: $argument2"
        Add-AliasFromPath -alias $argument1 -path $argument2
    }
    else {
        Write-Verbose "Adding alias from JSON"
        Add-AliasFromJson($argument1)
    }

    $json = [AliasPathMapping]::ToJson($script:ALIASES)
    $json | Out-File $script:JSON_FILE_PATH
    Write-Verbose "Alias added successfully."
}

function Add-AliasFromPath([string]$alias, [string]$path) {
    $resolvedPath = Resolve-FullPath $path

    if (-not (Test-Path $resolvedPath)) {
        Write-Error "Path does not exist: $resolvedPath"
        return $script:ALIASES
    }

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
    $newAliasPath = [AliasPathMapping]::FromJson($jsonString)

    if (!($newAliasPath)) {
        Write-Error "Could not add alias"
        return $script:ALIASES
    }

    if ($newAliasPath.Aliases.Count -eq 0) {
        Write-Error "No Aliases defined"
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
    # If alias isn't present anywhere, do nothing
    if (-not ($script:ALIASES | Where-Object { $_.Aliases -contains $alias })) {
        return $script:ALIASES
    }

    # Remove mappings that contain the alias and persist only if changed
    $script:ALIASES = $script:ALIASES | Where-Object { $_.Aliases -notcontains $alias }
    $json = [AliasPathMapping]::ToJson($script:ALIASES)
    $json | Out-File $script:JSON_FILE_PATH

    return $script:ALIASES
}

function Get-Aliases {
    if( -not $script:ALIASES) {
        $script:JSON_FILE_PATH = Get-AliasFilePath
        $script:ALIASES = Import-Aliases -aliasFilePath $script:JSON_FILE_PATH
    }
    return $script:ALIASES
}

<#
.SYNOPSIS
    Displays all aliases stored in the script-scoped ALIASES variable.

.DESCRIPTION
    This function retrieves the aliases from the script-scoped ALIASES variable and displays them in a formatted table view to the console.

.EXAMPLE
    Show-Aliases
    
    Displays all available aliases in a table format.

.NOTES
    This function depends on the $script:ALIASES variable being properly initialized with alias data.
#>
function Show-Aliases {
    Write-Host ($script:ALIASES | Format-Table | Out-String) 
}