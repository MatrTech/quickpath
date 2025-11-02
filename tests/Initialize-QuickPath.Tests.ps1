BeforeAll {
    . "$PSScriptRoot\..\private\Initialize-QuickPath.ps1"
}

Describe "Initialize-QuickPath" {
    BeforeEach {
        # Common mocks to avoid external side effects during tests
        $testRoot = Join-Path -Path TestDrive: -ChildPath 'quickpath'
        $testFile = Join-Path -Path $testRoot -ChildPath 'aliases.json'

        Mock Get-AliasFilePath { $testFile }
        Mock Get-Commands { @() }     
        Mock Import-Aliases { @() }
    }

    It 'File exists, does not recreate' {
        # Arrange existing directory and file
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null
        '[]' | Out-File -FilePath $testFile -Encoding utf8
        $before = (Get-Item $testFile).LastWriteTimeUtc

        Initialize-QuickPath

        # File should remain untouched
        Test-Path $testRoot | Should -BeTrue
        Test-Path $testFile | Should -BeTrue
        (Get-Item $testFile).LastWriteTimeUtc | Should -Be $before
    }

    It 'Directory exists but file does not, creates file' {
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null

        Initialize-QuickPath

        Test-Path $testRoot | Should -BeTrue
        Test-Path $testFile | Should -BeTrue
    }

    It 'Directory does not exist, creates directory and file' {
        Initialize-QuickPath

        Test-Path $testRoot | Should -BeTrue
        Test-Path $testFile | Should -BeTrue
    }
}