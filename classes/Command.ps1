# TODO: Provide 'help' functionality
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

    [void] InvokeFunction([object[]]$arguments) {
        if ($this.FunctionPointer) {
            & $this.FunctionPointer @($arguments)
        }
        else {
            $subCommand = $this.SubCommands.Where({$_.Name -eq $arguments[0]})
            if($subCommand) {
                $subCommand.InvokeFunction($arguments[1..($arguments.length - 1)])
            } else {
                Write-Host "No function assigned for command: $($this.Name)"
            }
        }
    }
}



