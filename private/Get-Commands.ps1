. $PSScriptRoot\..\classes\Command.ps1

$script:CachedCommands = $null

function Get-Commands {
    if ($null -eq $script:CachedCommands) {
        $script:CachedCommands = @(
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
            [Command]::new("help", "Show-Help")
            [Command]::new("alias", @(
                    [Command]::new("add", "Add-Alias" ), 
                    [Command]::new("remove", "Remove-Alias" )
                    [Command]::new("list", "List-Alias")
                )
            )
            [Command]::new("todo", @(
                    [Command]::new("add", "Add-Todo")
                    [Command]::new("remove", "Remove-Todo")
                    [Command]::new("list", "List-Todo")
                )
            )
            [Command]::new("version", "Show-Version")
            [Command]::new("update", "Invoke-Update")
        )
    }
    return $script:CachedCommands
}