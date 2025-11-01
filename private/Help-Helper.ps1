function Show-Help {
    $commands = Get-Commands
    $commandNames = $commands | ForEach-Object { $_.Name } | Sort-Object
    Write-Host (Get-DynamicHelp $commandNames)
}
