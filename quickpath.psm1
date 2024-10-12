. "$PSScriptRoot/private/Alias-Helper.ps1"
return;

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

function Get-DynamicHelp {
    param([string[]]$CommandList)

    $commandText = $CommandList | ForEach-Object { "`t$_" }
    $commandText = $commandText -join "`n"

    @"
NAME
    quickpath

SYNOPSIS
    A helper script to more easily navigate your system from the commandline.

DESCRIPTION
    'quickpath' is a script to help easily navigate your system using the commandline.
    Using aliases the script saves relative paths to quickly navigate to folders associated with the alias
    and even makes it easy to open the folders/projects in your favorite tools.

    USAGE
        qp [command] [arguments]
    
    EXAMPLE
        qp alias add '{"aliases": ["<myalias>"], "windowsPath": "the\\path\\to\\my\\alias" }'

    COMMANDS
        <path>
$commandText
"@
}

function qp {
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

    $commandNames = $commands.Values | ForEach-Object { $_.Name } | Sort-Object
    $helpText = Get-DynamicHelp $commandNames

    $SCRIPT:ALIASES = Import-Aliases
    $alias = Get-Alias $args[0]
    $path = $alias.WindowsPath ?? $args[0]
    
    if (Test-Path -Path $path) {
        Set-Location $path
        return
    } 
    
    if ($commands.ContainsKey($args[0])) {
        $command = $commands[$args[0]]
        if ($args.length -eq 1) {
            $command.InvokeFunction()    
        }
        else {
            $remainingArguments = $args[1..($args.length - 1)]
            $command.InvokeFunction($remainingArguments)
        }
        return
    }

    Write-Host $helpText
}
