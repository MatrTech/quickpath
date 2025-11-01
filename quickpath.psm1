$Public = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -Recurse -ErrorAction SilentlyContinue -Force )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -Recurse -ErrorAction SilentlyContinue -Force )
$Classes = @( Get-ChildItem -Path $PSScriptRoot\classes\*.ps1 -Recurse -ErrorAction SilentlyContinue -Force )

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
    try {
        $firstArgument = $args[0]
        $remainingArguments = $args[1..($args.length - 1)]

        $script:JSON_FILE_PATH = Get-Script-Path
        $commands = Get-Commands

        $commandNames = $commands | ForEach-Object { $_.Name } | Sort-Object
        $helpText = Get-DynamicHelp $commandNames

        $script:ALIASES = Import-Aliases
        $alias = Get-Alias $firstArgument
        $path = $alias.WindowsPath ?? $firstArgument

        if ($path -and (Test-Path -Path $path)) {
            Set-Location $path
            return
        } 
    
        $command = $commands | Where-Object { $_.Name -eq $firstArgument }
        if ($null -eq $command) {
            Write-Host $helpText
            return
        }

        if ($remainingArguments.length -eq 0) {
            $command.InvokeFunction()
            return;
        }

        $command.InvokeFunction($remainingArguments)
    }
    catch {
        Write-Error "Error: $($_.Exception.Message)"
    }
}

Register-ArgumentCompleter -CommandName qp -ScriptBlock {
    param(
        $wordToComplete,
        $commandAst,
        $cursorPosition
    )

    $commands = Get-Commands
    $inputCount = $commandAst.CommandElements.count
    if ($inputCount -eq 2) {
        $command = $commands | Where-Object { $_.Name -like "$wordToComplete*" }
        if ($command -ne $null) {
            return $command.Name
        }
    }

    $inputArguments = $commandAst.CommandElements | Select-Object -Skip 1 | ForEach-Object { $_.Extent.Text }
    $wordToComplete = $inputArguments | Select-Object -Last 1
    
    $subCommands = @()
    $command = $null

    foreach ($argument in $inputArguments[0..($inputArguments.Count - 2)]) {
        $command = $commands | Where-Object { $_.Name -eq $argument }
        $subCommands = $command.SubCommands
    }

    $command = $subCommands | Where-Object { $_.Name -like "$wordToComplete*" }

    if ($null -ne $command) {
        return $command.Name
    }

    $script:JSON_FILE_PATH = Get-Script-Path
    $aliasPathMappings = Import-Aliases
    foreach ($aliasMapping in $aliasPathMappings) {
        $matched = $aliasMapping.Aliases | Where-Object { $_ -like "$wordToComplete*" } | Select-Object -First 1
        if ($matched) {
            return "$matched"
        }
    }
}

Export-ModuleMember -Function qp