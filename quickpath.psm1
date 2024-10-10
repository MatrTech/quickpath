$Public = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Classes = @( Get-ChildItem -Path $PSScriptRoot\classes\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private + $Classes)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

<#
.SYNOPSIS
    A helper script to more easily navigate your system from the commandline.

.DESCRIPTION
    'quickpath' is a script to help easily navigate your system using the commandline.
    Using aliases the script saves relative paths to quickly navigate to folders associated with the alias
    and even makes it easy to open the folders/projects in your favorite tools.

    USAGE
        qp [command] [arguments]

    COMMANDS
        <path>
        rider, rider64
        vs, visualstudio
        code
        cd
        explorer
        alias
            add
            remove
            list
        source_folder
        help, -?

.EXAMPLE
    PS> qp alias list

.EXAMPLE
    PS> qp <ide> <alias>
    PS> qp rider MyCSharpProject 

.EXAMPLE
    PS> qp alias add '{"alias": "MyAlias", "windowsPath": "Path\To\My\Folder"}'
#>
function qp {
    #TODO: Print list of available commands on help
    # if (!$args[0]) {
    #     # TODO: Fix help
    #     Get-Help $PSCommandPath
    #     exit
    # }

    # # TODO: Move this to a seperate file and call something like 'init-commands'
    # # TODO: Add a way to list the commands
    $commands = @{
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
        "help"          = [Command]::new("help", { Write-Host (Get-Help qp | Out-String) } )
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

    $SCRIPT:ALIASES = Import-Aliases

    $alias = Get-Alias $args[0]
    $path = $alias.WindowsPath ?? $args[0]
    
    if (Test-Path -Path $path) {
        Set-Location $path
        return
    } 
    
    if ($commands.ContainsKey($args[0])) {
        $remainingArguments = $args[1..($args.length - 1)]
        $commands[$args[0]].InvokeFunction($remainingArguments)
        return
    }

    Write-Host (Get-Help qp | Out-String)
}
