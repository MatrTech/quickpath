function Get-Commands {
    return @(
        [Command]::new("cd", "Set-Alias-Location")
        [Command]::new("rider", "Open-Solution rider" )
        [Command]::new("vs", "Open-Solution visualstudio" )
        [Command]::new("visualstudio", "Open-Solution visualstudio" )
        [Command]::new("intellij", "Open-Solution intellij")
        [Command]::new("code", "Open-Code")
        [Command]::new("ws", "Open-Webstorm")
        [Command]::new("webstorm", "Open-Webstorm")
        [Command]::new("explorer", "Open-Explorer")
        [Command]::new("sourcefolder", "Set-Source-Folder")
        [Command]::new("help", 'Write-Host $(Get-DynamicHelp $commandNames)' )
        [Command]::new("alias", @(
                [Command]::new("add", "Add-Alias" ), 
                [Command]::new("remove", "Remove-Alias" )
                [Command]::new("list", { Write-Host ($script:ALIASES | Format-Table | Out-String) }))
        )
        [Command]::new("todo", @(
                [Command]::new("add", "Add-Todo")
                [Command]::new("remove", { Write-Host "TODO: remove item from todolist: qp todo remove x" })
                [Command]::new("list", { Write-Host "TODO: Output todo list" }))
        )
        [Command]::new("version", { Write-Host (Get-MyModuleVersion) })
        [Command]::new("update", { 
                Write-Host "updating quickpath..."
                Update-Module quickpath
                Write-Host "quickpath has been updated"
            })
    )
}