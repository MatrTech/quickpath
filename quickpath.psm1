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
    param([string[]]$arguments)
    Write-Output "Running qp with arguments: $arguments"

    $script:JSON_FILE_PATH = Get-Script-Path
    $commands = Get-Commands

    $commandNames = $commands.Values | ForEach-Object { $_.Name } | Sort-Object
    $helpText = Get-DynamicHelp $commandNames

    $script:ALIASES = Import-Aliases
    $alias = Get-Alias $arguments[0]
    $path = $alias.WindowsPath ?? $arguments[0]

    if (Test-Path -Path $path) {
        Set-Location $path
        return
    } 
    
    if (-not $commands.ContainsKey($arguments[0])) {
        Write-Host $helpText
        return
    }

    $command = $commands[$arguments[0]]

    if ($arguments.length -eq 1) {
        $command.InvokeFunction()
        return;
    }

    $remainingArguments = $arguments[1..($arguments.length - 1)]
    $command.InvokeFunction($remainingArguments)
}

$qpCommands = @('alias', 'rider', 'build', 'test', 'deploy')
Register-ArgumentCompleter -CommandName qp -ParameterName arguments -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

    # Filter the list based on the current input ($wordToComplete)
    (Get-Commands).Keys | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', "Command: $_")
    }
}