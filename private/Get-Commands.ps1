. $PSScriptRoot\..\classes\Command.ps1

function Get-Commands {
    if ($null -ne $script:COMMANDS) {
        return $script:COMMANDS
    }
    $script:COMMANDS = @(
        [Command]::new("cd", "Set-Alias-Location")
        [Command]::new("rider", "Open-Command rider" )
        [Command]::new("vs", "Open-Command visualstudio" )
        [Command]::new("visualstudio", "Open-Command visualstudio" )
        [Command]::new("intellij", "Open-Command intellij")
        [Command]::new("code", "Open-Command code")
        [Command]::new("ws", "Open-Command webstorm")
        [Command]::new("webstorm", "Open-Command webstorm")
        [Command]::new("explorer", "Open-Command explorer")
        [Command]::new("sourcefolder", "Set-Source-Folder")
        [Command]::new("help", 'Write-Host $(Get-DynamicHelp $commandNames)' )
        [Command]::new("alias", @(
                [Command]::new("add", "Add-Alias" ), 
                [Command]::new("remove", "Remove-Alias" )
                [Command]::new("list", { Write-Host ($script:ALIASES | Format-Table | Out-String) })
            )
        )
        [Command]::new("todo", @(
                [Command]::new("add", "Add-Todo")
                [Command]::new("remove", { Write-Host "TODO: remove item from todolist: qp todo remove x" })
                [Command]::new("list", { Write-Host "TODO: Output todo list" })
            )
        )
        [Command]::new("version", { Write-Host (Get-MyModuleVersion) } )
        [Command]::new("update", { Update-QuickPath -FromGallery })
    )
    return $script:COMMANDS
}