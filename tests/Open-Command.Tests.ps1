Describe 'Open Command tests' {
    BeforeAll {
        . $PSScriptRoot\..\private\Open-Command.ps1
    }
    It 'Alias not found throws exception' {
        Mock Get-Alias { return $null }
        { Open-Command } | Should -Throw
    }
}
