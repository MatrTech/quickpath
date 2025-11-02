BeforeAll {
    . "$PSScriptRoot\..\private\Initialize-QuickPath.ps1"
}

Describe "Initialize-QuickPath" {
    BeforeEach {
        Mock Import-Aliases { @() }
        Mock Get-AliasFilePath { return "quickpath\\aliases.json" }
        Mock Test-Path { return $false }
        Mock Out-File {}
        Mock New-Item {}
        Mock Get-Commands { @([pscustomobject]@{ Name = 'test' }) }
    }

    It 'File exists, does not recreate' {
        Mock Test-Path { return $true }

        Initialize-QuickPath

        Assert-MockCalled Out-File -Exactly 0
        Assert-MockCalled New-Item -Exactly 0
    }

    It 'Directory does not exist, creates directory and file' {
        Mock Test-Path { $false }

        Initialize-QuickPath

        Assert-MockCalled New-Item -Exactly 1
        Assert-MockCalled Out-File -Exactly 1
    }

    It 'Directory exists but file does not, creates file' {
        Mock Test-Path { param($Path) if ($Path -like "*aliases.json") { return $false } else { return $true } }
        
        Initialize-QuickPath

        Assert-MockCalled New-Item -Exactly 0
        Assert-MockCalled Out-File -Exactly 1
    }

    It 'Loads commands into $script:COMMANDS' {
        
        Initialize-QuickPath

        $script:COMMANDS | Should -Not -Be $null
        $script:COMMANDS.Count | Should -BeGreaterThan 0
    }

    It 'Loads aliases into $script:ALIASES' {
        # Arrange: Mock Import-Aliases to return test data
        Mock Import-Aliases { 
            @([pscustomobject]@{ 
                    Aliases     = @('proj') 
                    WindowsPath = 'C:\Temp\Proj' 
                }) 
        }
            
        Initialize-QuickPath

        $script:ALIASES | Should -Not -Be $null
        $script:ALIASES.Count | Should -BeGreaterThan 0
    }
}
