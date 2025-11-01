. $PSScriptRoot\..\private\Get-MyModuleVersion.ps1

function Show-Version {
    Write-Host (Get-MyModuleVersion)
}
