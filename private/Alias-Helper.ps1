Write-Host "Alias-Helper: ROOT: $PSScriptRoot"
. $PSScriptRoot\classes\AliasPathMapping.ps1

function Get-Script-Path {
    $moduleName = "quickpath"
    $modulePath = (Get-Module -Name $moduleName -ListAvailable | Select-Object -First 1 -ExpandProperty Path)
    $rootPath = Split-Path $modulePath -Parent
    $rootPath = Split-Path $rootPath -Parent 
    
    $script:JSON_FILE_PATH = "$rootPath\aliases.json"    
}


function Import-Aliases {
    if (!(Test-Path $script:JSON_FILE_PATH)) {
        New-Item -Path $script:JSON_FILE_PATH -ItemType File
    }
    
    $json = Get-Content -Raw -Path $script:JSON_FILE_PATH
    return [AliasPathMapping[]][AliasPathMapping]::FromJsonArray($json)
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

function Add-Alias([string]$jsonString) {
    $script:ALIASES = @($script:ALIASES)
    $newAliasPath = [AliasPathMapping]::FromJson($jsonString)

    if (!($newAliasPath)) {
        Write-Output "Could not add route"
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

    $json = [AliasPathMapping]::ToJson($script:ALIASES)
    $json | Out-File $script:JSON_FILE_PATH
}

function Remove-Alias([string] $alias) {
    $script:ALIASES = $script:ALIASES | Where-Object { $_.aliases -notcontains $alias }
    $json = [AliasPathMapping]::ToJson($script:ALIASES)
    $json | Out-File $script:JSON_FILE_PATH
}
