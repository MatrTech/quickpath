Describe 'Open Command tests' {
    BeforeAll {
        . $PSScriptRoot\..\private\Open-Command.ps1
    }
    It 'Alias not found throws exception' {
        Mock Get-Alias { return $null }
        { Open-Command } | Should -Throw
    }

    It 'Program not found throws exception' {
        Mock Get-Alias { return "hello world" }
        Mock Get-Command { return $null }
        { Open-Command } | Should -Throw
    }

    It 'Path could not be found throws exception' {
        Mock Get-Alias { return "hello world" }
        Mock Get-Command { }
        Mock Test-Path { return $null }
        { Open-Command } | Should -Throw 
    }

    It 'Valid command Start-Process called' {
        Mock Get-Alias { return "hello world" }
        Mock -CommandName Get-Command -MockWith { @{} }
        Mock -CommandName Test-Path -MockWith { $true }
        Mock Start-Process

        Open-Command "some-program" "some-alias" $true

        Assert-MockCalled Start-Process -Exactly 1 -Scope It 
    }
}
