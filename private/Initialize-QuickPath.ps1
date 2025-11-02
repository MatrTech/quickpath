. $PSScriptRoot\..\private\Alias-Helper.ps1
. $PSScriptRoot\..\private\Get-Commands.ps1

function Initialize-QuickPath {
    [CmdletBinding()]
    param()
    Write-Verbose "Initializing QuickPath..."

    $aliasFilePath = EnsureAliasFile
    $script:JSON_FILE_PATH = $aliasFilePath

    $aliases = Import-Aliases $aliasFilePath
    if ($null -eq $aliases) { $aliases = @() }
    $script:ALIASES = $aliases
    $script:COMMANDS = Get-Commands

    Write-Verbose "QuickPath initialized. JSON file: $aliasFilePath"
    Write-Verbose "Loaded $($script:ALIASES.Count) aliases and $($script:COMMANDS.Count) commands"
}

function EnsureAliasFile {
    $aliasFilePath = Get-AliasFilePath
    $aliasDirectory = Split-Path $aliasFilePath -Parent

    if (-not (Test-Path $aliasDirectory)) {
        New-Item -Path $aliasDirectory -ItemType Directory -Force | Out-Null
    }
            
    if (-not (Test-Path $aliasFilePath)) {
        '[]' | Out-File -FilePath $aliasFilePath -Encoding UTF8
    }

    return $aliasFilePath
}

function Get-Aliases {
    return $script:ALIASES
}