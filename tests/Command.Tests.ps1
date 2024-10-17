. $PSScriptRoot\..\classes\Command.ps1

Describe 'Command tests' {
    BeforeAll {
        . $PSScriptRoot\..\classes\Command.ps1
    }
    context 'Create Commands' {
        It 'Function by name, calls function' {
            Mock Write-Host { "Hello, TestCommand" } -Verifiable
        
            $command = [Command]::new("TestCommand", "Write-Host" )
            $command.InvokeFunction()

            Assert-MockCalled Write-Host -Exactly 1 -Scope It
        }
        It 'Function by scriptblock, calls function' {
            Mock Write-Host { "Hello, TestCommand" } -Verifiable

            $command = [Command]::new("TestCommand", { Write-Host })
            $command.InvokeFunction()

            Assert-MockCalled Write-host -Exactly 1 -Scope It
        }
        It 'Command with sub command, parent called with child as argument, calls function' {
            Mock Write-Host { "Hello, TestCommand" } -Verifiable

            $command = [Command]::new("parent", @([Command]::new("child", { Write-Host })))
            $command.InvokeFunction("child")

            Assert-MockCalled Write-host -Exactly 1 -Scope It
        }
    }
    Context 'InvokeFunction' {
        BeforeAll {
            Mock Write-Host { "Hello, TestCommand" } -Verifiable
        }
        It 'Define command with function, function can gets called' {
            $command = [Command]::new("TestCommand", "Write-Host")
            $command.InvokeFunction()

            Assert-MockCalled Write-host -Exactly 1 -Scope It
        }
        It 'Function with help argument, PrintHelp gets called' {
            $command = [Command]::new("TestCommand", "Write-Host")
            $command.InvokeFunction("help")

            Assert-MockCalled Write-Host -Exactly 1 -Scope It
        }
        It 'Function with subcommands, dont print help' {
            $command = [Command]::new("parent", @([Command]::new("child", { Write-Host "Hello, child command" })))
            $command.InvokeFunction("help")
        }
        It 'Defined function, function called' {
            $command = [Command]::new("TestCommand", { Write-Host 'Hello Test' })
            $command.InvokeFunction()

            Assert-MockCalled Write-Host -Exactly 1 -Scope It
        }
        It 'Function not defined, call subcommand function' {
            $command = [Command]::new("parrent", @([Command]::new("child", { Write-Host "Hello, child command" })))
            $command.InvokeFunction("child")

            Assert-MockCalled Write-Host -Exactly 1 -Scope It
        }
        It 'Subcommand not part of command, Write-Host called' {
            $command = [Command]::new("parrent", @([Command]::new("child", $null)))
            $command.InvokeFunction("not a child")

            Assert-MockCalled Write-Host -Exactly 1 -Scope It
        }
    }
}