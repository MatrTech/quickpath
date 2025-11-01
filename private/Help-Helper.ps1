function Show-Help {
    try {
        $commands = Get-Commands
        $commandNames = $commands | ForEach-Object { $_.Name } | Sort-Object
        Write-Host (Get-DynamicHelp $commandNames)
    }
    catch {
        Write-Error "Failed to display help: $($_.Exception.Message)"
    }
}
