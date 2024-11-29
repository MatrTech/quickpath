. $PSScriptRoot\..\private\Alias-Helper.ps1

function Open-Command {
    param([string]$program, [string]$aliasNameOrPath, [bool]$isSolution)
    $alias = Get-Alias $aliasNameOrPath

    if (!$alias) {
        throw "Alias not found with name: '$aliasNameOrPath'"
    }

    if (-not(Get-Command "$program" -ErrorAction SilentlyContinue)) {
        throw "$program is not installed or available in the PATH. Please install $program and try again."
    }

    $path = if ($isSolution) { $alias.Solution } else { $alias.WindowsPath ?? $aliasNameOrPath }
    $pathType = if ($isSolution) { "solution" } else { "path" } 

    if (!(Test-Path $path)) {
        throw "Could not find alias $pathType '$path'"
    }

    Start-Process $program $path -NoNewWindow
}