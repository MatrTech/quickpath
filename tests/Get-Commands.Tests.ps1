Describe 'Get commands' {
    BeforeAll {
        . $PSScriptRoot\..\private\Get-Commands.ps1
    }
    It 'Should return list of commands' {
        Get-Commands | Should -Not -Be @()
    }
}