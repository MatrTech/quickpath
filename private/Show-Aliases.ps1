function Show-Aliases {
    [CmdletBinding()]
    param ()

    Write-Host (Get-Aliases | Format-Table | Out-String)
}
