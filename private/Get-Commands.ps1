. $PSScriptRoot\..\classes\Command.ps1
. $PSScriptRoot\Alias-Helper.ps1

function Get-Commands {
    if ($null -ne $script:COMMANDS) {
        return $script:COMMANDS
    }
    $script:COMMANDS = @(
        [Command]::new("cd", { Set-AliasLocation } )
        [Command]::new("rider", { Open-Command rider } )
        [Command]::new("vs", { Open-Command visualstudio } )
        [Command]::new("visualstudio", { Open-Command visualstudio } )
        [Command]::new("intellij", { Open-Command intellij } )
        [Command]::new("code", { Open-Command code } )
        [Command]::new("ws", { Open-Command webstorm } )
        [Command]::new("webstorm", { Open-Command webstorm } )
        [Command]::new("explorer", { Open-Command explorer } )
        [Command]::new("sourcefolder", { Set-SourceFolder } )
        [Command]::new("help", { Write-Host $(Get-DynamicHelp $commandNames) } )
        [Command]::new("alias", @(
                [Command]::new("add", { Add-Alias } ), 
                [Command]::new("remove", { Remove-Alias } ),
                [Command]::new("list", { Show-Aliases } )
            )
        )
        [Command]::new("todo", @(
                [Command]::new("add", { Add-Todo })
                [Command]::new("remove", { Remove-Todo })
                [Command]::new("list", { Show-Todos })
            )
        )
        [Command]::new("version", { Show-ModuleVersion } )
        [Command]::new("update", { Update-QuickPath -FromGallery })
    )
    return $script:COMMANDS
}