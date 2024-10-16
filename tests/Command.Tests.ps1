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
        It 'Define command with function, function can gets called' {
            Mock Write-Host { "Hello, TestCommand" } -Verifiable

            $command = [Command]::new("TestCommand", "Write-Host")
            $command.InvokeFunction()

            Assert-MockCalled Write-host -Exactly 1 -Scope It
        }
        It 'Function with help argument, PrintHelp gets called' {
            Mock Write-Host -Verifiable

            $command = [Command]::new("TestCommand", "Write-Host")
            $command.InvokeFunction("help") | Should 

            Assert-MockCalled Write-Host -Exactly 1 -Scope It
        }
    }
}