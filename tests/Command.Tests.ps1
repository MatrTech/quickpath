. $PSScriptRoot\..\classes\Command.ps1

Describe 'Command tests' {
    BeforeAll {
        . $PSScriptRoot\..\classes\Command.ps1
    }
    It 'First test' {
        Mock Write-Host { "Hello, TestCommand" } -Verifiable
        
        $command = [Command]::new("TestCommand", "Write-Host" )
        $command | Should -Not -Be $null
        $command.InvokeFunction()

        Assert-MockCalled Write-Host -Exactly 1 -Scope It
    }
}