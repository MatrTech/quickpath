function Get-Commands {
    return @{
        "cd"            = [Command]::new("cd", "Set-Alias-Location")
        "rider"         = [Command]::new("rider", "Open-Solution rider" )
        "vs"            = [Command]::new("vs", "Open-Solution visualstudio" )
        "visualstudio"  = [Command]::new("visualstudio", "Open-Solution visualstudio" )
        "intellij"      = [Command]::new("intellij", "Open-Solution intellij")
        "code"          = [Command]::new("code", "Open-Code")
        "ws"            = [Command]::new("ws", "Open-Webstorm")
        "webstorm"      = [Command]::new("webstorm", "Open-Webstorm")
        "explorer"      = [Command]::new("explorer", "Open-Explorer")
        "source-folder" = [Command]::new("sourcefolder", "Set-Source-Folder")
        "help"          = [Command]::new("help", 'Write-Host $(Get-DynamicHelp $commandNames)' )
        "alias"         = [Command]::new("alias", @(
                [Command]::new("add", "Add-Alias" ), 
                [Command]::new("remove", "Remove-Alias" ),
                [Command]::new("list", { Write-Host ($script:ALIASES | Format-Table | Out-String) })))
        "todo"          = [Command]::new("todo", @(
                [Command]::new("add", "Add-Todo"),
                [Command]::new("remove", { Write-Host "TODO: remove item from todolist: qp todo remove x" }),
                [Command]::new("list", { Write-Host "TODO: Output todo list" })))
        "version"       = [Command]::new("version", { Write-Host (Get-MyModuleVersion) })
    }
}