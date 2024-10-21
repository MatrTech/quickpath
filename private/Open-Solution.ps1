# $knownIdes = @{
#     visualstudio = "devenv";
#     rider        = "rider"
#     intellij     = "idea64";

# }

. $PSScriptRoot\..\private\Alias-Helper.ps1

function Open-Solution {
    param([string]$ide, [string]$aliasName)
    $alias = Get-Alias $aliasName

    if (!$alias) {
        throw "Alias not found with name: '$aliasName'"
    }
    
    Start-Process $ide $alias.Solution
}