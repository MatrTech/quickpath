# TODO: #3 Provide 'help' functionality
class Command {
    [string] $Name
    [scriptblock] $FunctionPointer
    [Command[]]$SubCommands

    Command([string]$Name, [string]$FunctionName) {
        $this.Name = $Name
        $this.FunctionPointer = [scriptblock]::Create("param(`$arguments); $FunctionName @arguments")
        $this.SubCommands = @()
    }

    Command([string]$Name, [scriptblock]$FunctionPointer) {
        $this.Name = $Name
        $this.FunctionPointer = $FunctionPointer
        $this.SubCommands = @()
    }

    Command([string]$Name, [array]$SubCommands) {
        $this.Name = $Name
        $this.SubCommands = $SubCommands
    }

    [void] InvokeFunction() {
        & $this.FunctionPointer
    }

    [void] InvokeFunction([object[]]$arguments) {
        if ($arguments[0] -eq "help") {
            $this.PrintHelp()
            return
        }

        if ($this.FunctionPointer) {
            & $this.FunctionPointer @($arguments)
        }
        else {
            $subCommand = $this.SubCommands.Where({ $_.Name -eq $arguments[0] })
            
            if ($subCommand) {
                $subCommand.InvokeFunction($arguments[1..($arguments.length - 1)])
            }
            else {
                Write-Host "No function assigned for command: $($this.Name) $($arguments[0])"
            }
        }
    }

    [void] PrintHelp() {
        if ($this.SubCommands.count -eq 0) {
            Write-Host @"
    NAME
        $($this.Name)

    USAGE
        qp [parent] $($this.Name)
"@
        }
        else {

            $commandList = $this.SubCommands | Select-Object -ExpandProperty Name
            $commandText = $commandList | ForEach-Object { "`t$_" }
            $commandText = $commandText -join "`n"

            Write-Host @"
    NAME
        $($this.Name)

    USAGE
        qp $($this.Name) [sub-command]

    SUB-COMMANDS
    $commandText
"@
        }
    }
}



