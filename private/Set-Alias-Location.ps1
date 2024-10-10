. $PSScriptRoot\..\private\Alias-Helper.ps1

function Set-Alias-Location {
    param([string]$aliasName)

    $alias = Get-Alias $aliasName

    if(!$alias) {
        throw "Alias not found with name: '$aliasName'"
    }
    Set-Location $alias.WindowsPath
}