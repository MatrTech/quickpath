. $PSScriptRoot\..\classes\AliasPathMapping.ps1

$moduleName = "quickpath"
$modulePath = (Get-Module -Name $moduleName -ListAvailable | Select-Object -First 1 -ExpandProperty Path)
$rootPath = Split-Path $modulePath -Parent
$rootPath = Split-Path $rootPath -Parent 

$script:JSON_FILE_PATH = "$rootPath\aliases.json"

function Import-Aliases {
    if (!(Test-Path $script:JSON_FILE_PATH)) {
        New-Item -Path $script:JSON_FILE_PATH -ItemType File
    }
    
    $json = Get-Content -Raw -Path $script:JSON_FILE_PATH
    return [AliasPathMapping[]][AliasPathMapping]::FromJsonArray($json)
}

function Get-Alias([string[]]$aliases) {
    foreach ($alias in $aliases) {
        $aliasPath = $script:ALIASES.Where({ $_.aliases -contains $alias })
        return $aliasPath
    }

    return $null
}

# TODO: If any of the aliases match update the alias instead of creating a new one.
function Add-Alias([string]$jsonString) {
    $script:ALIASES = @($script:ALIASES)
    $newAliasPath = [AliasPathMapping]::FromJson($jsonString)

    if (!($newAliasPath)) {
        Write-Output "Could not add alias"
        return $script:ALIASES
    }

    if ($newAliasPath.aliases.Count -eq 0) {
        Write-Output "No Aliases defined"
        return $script:ALIASES
    }

    $aliases = $newAliasPath.aliases
    $aliasPath = (Get-Alias $aliases)

    if ($aliasPath) {
        $aliasPath.aliases = ($newAliasPath.aliases + $aliasPath.aliases) | Select-Object -Unique
        $aliasPath.windowsPath = [String]::IsNullOrEmpty($newAliasPath.windowsPath) ? $aliasPath.windowsPath : $newAliasPath.windowsPath
        $aliasPath.linuxPath = [String]::IsNullOrEmpty($newAliasPath.linuxPath) ? $aliasPath.linuxPath : $newAliasPath.linuxPath
        $aliasPath.solution = [String]::IsNullOrEmpty($newAliasPath.solution) ? $aliasPath.solution : $newAliasPath.solution
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
