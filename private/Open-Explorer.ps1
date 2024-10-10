function Open-Explorer {
    param([string]$aliasNameOrPath)
    $alias = Get-Alias $aliasNameOrPath
    $path = $alias.WindowsPath ?? $aliasNameOrPath
    if(!(Test-Path $path)) {
        throw "Could not find path for '$aliasNameOrPath'"
    }
    & "explorer" $path
}