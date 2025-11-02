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

    It 'Loads commands into $script:COMMANDS' {
        Mock Get-Commands { @([pscustomobject]@{ Name = 'test' }) }
        Initialize-QuickPath

        $script:COMMANDS | Should -Not -Be $null
        $script:COMMANDS.Count | Should -BeGreaterThan 0
    }

    It 'Loads aliases into $script:ALIASES' {
        # Arrange: write a minimal valid JSON with one alias mapping
        New-Item -Path $testRoot -ItemType Directory -Force | Out-Null
        $json = @'
[
  {"aliases": ["proj"], "windowsPath": "C:\\Temp\\Proj" }
]
'@
        $json | Out-File -FilePath $testFile -Encoding utf8

        Initialize-QuickPath

        $aliases = Get-Aliases
        $aliases | Should -Not -Be $null
        $aliases.Count | Should -Be 1
        $aliases[0].Aliases | Should -Contain 'proj'
    }
}