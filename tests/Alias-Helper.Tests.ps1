Describe 'Alias-Helper' {
    BeforeAll {
        . $PSScriptRoot\..\private\Alias-Helper.ps1
    }
    context 'Import-Aliases' {
        BeforeEach {
            $script:SOURCE_FOLDER = "C:\temp\source\folder"
            $script:SOURCE_FOLDER_TEMPLATE = "<SOURCE_FOLDER>"
            $script:ALIAS_PATH_TEMPLATE = "<ALIAS_PATH>"
            $script:SOME_VALID_PATH = "some\valid\path"
            $script:JSON_FILE_PATH = "$PSScriptRoot\quickpath\aliases-test.json"
            $script:JSON_CONTENT = Get-Content -Path $script:JSON_FILE_PATH | ConvertFrom-Json

            $aliasFilePath = "$PSScriptRoot\quickpath\aliases-test.json"
            $script:JSON_CONTENT = Get-Content -Path $aliasFilePath | ConvertFrom-Json

            $env:LOCALAPPDATA = "$PSScriptRoot"

            Mock New-Item
            Mock Test-Path { return $true }
        }
        It 'Json file missing, create one' {
            Mock Test-Path { return $false }
            Mock Out-File

            Import-Aliases $aliasFilePath

            Assert-MockCalled -CommandName Out-File -Times 1 -Exactly -Scope It -ParameterFilter { 
                $Path -eq $aliasFilePath
            }
        }
        It 'Json file exists, dont create one' {
            Mock Get-Content { return $script:JSON_CONTENT }
            
            Import-Aliases $aliasFilePath

            Assert-MockCalled -CommandName New-Item -Times 0 -Exactly -Scope It -ParameterFilter { 
                $Path -eq $aliasFilePath
            }

            Assert-MockCalled -CommandName Get-Content -Times 1 -Exactly -Scope It -ParameterFilter { 
                $Path -eq $aliasFilePath
            }
        }
        It 'Empty JSON file, returns empty list' {
            Mock Get-Content { return '' }

            Import-Aliases $aliasFilePath
            | Should -BeNullOrEmpty
        }
        It 'should correctly import routes from JSON file' {
            # Define the expected objects
            $expected = @(
                [AliasPathMapping]@{
                    Aliases     = @('alias1', 'alias2')
                    WindowsPath = 'C:\temp\source\folder\alias\root'
                    LinuxPath   = '/path/to/linux'
                    Solution    = 'C:\temp\source\folder\alias\root\some\valid\path'
                },
                [AliasPathMapping]@{
                    Aliases     = @('alias1', 'alias2')
                    WindowsPath = 'C:\temp\source\folder\alias\root'
                    LinuxPath   = '/path/to/linux'
                    Solution    = 'C:\temp\source\folder\alias\root\some\valid\path'
                }
            ) | ConvertTo-Json
    
            # Call the function and capture the result
            Import-Aliases $aliasFilePath
            | ConvertTo-Json
            | Should -BeExactly $expected
        }
        It 'Json parse throws error, returns empty list and writes warning' {
            Mock Get-Content { return 'invalid json' }
            Mock Write-Warning

            Import-Aliases $aliasFilePath
            | Should -BeNullOrEmpty

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -Scope It
            
        }
    }
    context 'Get-AliasFilePath' {
        It 'Returns correct file path' {
            $expectedPath = Join-Path (Join-Path $env:LOCALAPPDATA 'quickpath') 'aliases.json'

            $result = Get-AliasFilePath

            $result | Should -Be $expectedPath
        }
    }
    context 'Get-Alias' {
        It 'No aliases defined, returns $null' {
            Get-Alias "some-alias-name" 
            | Should -Be $null
        }
        It 'Aliases defined, not found, returns $null' {
            $script:ALIASES = @([AliasPathMapping]::new("alias1", $null, $null, $null))
            Get-Alias "some-unknown-alias"
            | Should -Be $null
        }
        It 'Aliases defined, known alias, does not return $null' {
            $alias = "alias1"
            $script:ALIASES = @([AliasPathMapping]::new($alias, $null, $null, $null))
            Get-Alias $alias
            | Should -Not -Be $null
        }
    }
    context 'Resolve-FullPath' {
        It 'Null path, returns $null or empty' {
            Resolve-FullPath $null 
            | Should -BeNullOrEmpty
        }
        It 'Empty path, returns empty string' {
            Resolve-FullPath '' 
            | Should -BeNullOrEmpty
        }
        It 'Path starting with ~, expands to user home' {
            $inputPath = '~\some\path'
            $expectedPath = Join-Path $HOME 'some\path'

            $result = Resolve-FullPath $inputPath
            $resultNormalized = $result -replace '\\', '/'
            $expectedNormalized = $expectedPath -replace '\\', '/'

            $resultNormalized | Should -Be $expectedNormalized
        }
        It 'Already rooted path, returns full path' {
            $inputPath = 'C:\some\path'
            $expectedPath = [System.IO.Path]::GetFullPath($inputPath)

            $result = Resolve-FullPath $inputPath
            $resultNormalized = $result -replace '\\', '/'
            $expectedNormalized = $expectedPath -replace '\\', '/'

            $resultNormalized | Should -Be $expectedNormalized
        }
        It 'Relative path, returns full path' {
            $inputPath = 'some\relative\path'
            $expectedPath = [System.IO.Path]::GetFullPath($inputPath)

            $result = Resolve-FullPath $inputPath
            $resultNormalized = $result -replace '\\', '/'
            $expectedNormalized = $expectedPath -replace '\\', '/'

            $resultNormalized | Should -Be $expectedNormalized
        }
    }
    context 'Add-AliasFromPath' {
        It 'Full path does not exist, writes error' {
            Mock Test-Path { return $false }
            Mock Write-Error

            Add-AliasFromPath "non\existent\path" @("alias1")

            Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It
        }
        It 'Alias exists, updates existing alias' {
            Mock Test-Path { return $true }

            $existingPath = Join-Path $PSScriptRoot 'existing' 'path'
            $newPath = Join-Path $PSScriptRoot 'new' 'path'

            $existingAlias = [AliasPathMapping]::new('alias1', (Resolve-FullPath $existingPath), $null, $null)
            $script:ALIASES = @($existingAlias)
            
            Add-AliasFromPath 'alias1' $newPath

            $script:ALIASES.Count | Should -Be 1
            $script:ALIASES[0].WindowsPath | Should -Be (Resolve-FullPath $newPath)
        }
        It 'Alias does not exist, adds new alias' {
            Mock Test-Path { return $true }
            $script:ALIASES = @()

            Add-AliasFromPath "alias2" "C:\some\path"

            $script:ALIASES.Count | Should -Be 1
            $script:ALIASES[0].Aliases | Should -Contain "alias2"

            $actualPath = $script:ALIASES[0].WindowsPath -replace '\\', '/'
            $expectedPath = (Resolve-FullPath "C:\some\path") -replace '\\', '/'
            $actualPath | Should -Be $expectedPath
        }
    }
    context 'Add-Alias' {
        It 'argument2 provided, calls Add-AliasFromPath' {
            Mock Add-AliasFromPath
            Mock Out-File

            Add-Alias "alias1" "C:\some\path"

            Assert-MockCalled -CommandName Add-AliasFromPath -Times 1 -Exactly -Scope It -ParameterFilter { 
                $alias -eq "alias1" -and $path -eq "C:\some\path"
            }
        }
        It 'argument2 not provided, calls Add-AliasFromJson' {
            Mock Add-AliasFromJson
            Mock Out-File
            Add-Alias '{"Aliases":["alias1"],"WindowsPath":"C:\\some\\path"}'

            Assert-MockCalled -CommandName Add-AliasFromJson -Times 1 -Exactly -Scope It -ParameterFilter { 
                $jsonString -eq '{"Aliases":["alias1"],"WindowsPath":"C:\\some\\path"}'
            }
        }
    }
    context 'Add-AliasFromJson' {
        It 'FromJson returns $null, writes error' {
            Mock ConvertFrom-Json { return $null }
            Mock Write-Error

            Add-AliasFromJson "invalid json"

            Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It
        }
        It 'Alias count is 0, writes error' {
            $jsonString = '{"Aliases":[],"WindowsPath":"C:\\some\\path"}'
            Mock ConvertFrom-Json { return $jsonString }
            Mock Write-Error

            Add-AliasFromJson $jsonString

            Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It
        }
        It 'Valid JSON, adds new alias' {
            $jsonString = '{"Aliases":["alias1"],"WindowsPath":"C:\\some\\path"}'
            Mock ConvertFrom-Json {
                $aliasPath = [AliasPathMapping]::new()
                $aliasPath.Aliases = @("alias1")
                $aliasPath.WindowsPath = "C:\some\path"
                return $aliasPath
            }

            $script:ALIASES = @()

            Add-AliasFromJson $jsonString

            $script:ALIASES.Count | Should -Be 1
            $script:ALIASES[0].Aliases | Should -Contain "alias1"

            $actualPath = $script:ALIASES[0].WindowsPath -replace '\\', '/'
            $expectedPath = ('C:\some\path' -replace '\\', '/')
            $actualPath | Should -Be $expectedPath
        }
        It 'Valid JSON, alias exists, updates existing alias' {
            $jsonString = '{"Aliases":["alias1"],"WindowsPath":"C:\\new\\path"}'
            Mock ConvertFrom-Json {
                $aliasPath = [AliasPathMapping]::new()
                $aliasPath.Aliases = @("alias1")
                $aliasPath.WindowsPath = "C:\new\path"
                return $aliasPath
            }

            $existingPath = Join-Path $PSScriptRoot 'existing' 'path'
            $existingAlias = [AliasPathMapping]::new('alias1', (Resolve-FullPath $existingPath), $null, $null)
            $script:ALIASES = @($existingAlias)

            Add-AliasFromJson $jsonString

            $script:ALIASES.Count | Should -Be 1
            $script:ALIASES[0].Aliases | Should -Contain "alias1"

            $actualPath = $script:ALIASES[0].WindowsPath -replace '\\', '/'
            $expectedPath = ('C:\new\path' -replace '\\', '/')
            $actualPath | Should -Be $expectedPath
        }
    }
    context 'Remove-Alias' {
        It 'Alias does not exist, does nothing' {
            Mock Out-File
            $script:ALIASES = @([AliasPathMapping]::new("alias1", "C:\some\path", $null, $null))

            Remove-Alias "nonexistent-alias"

            $script:ALIASES.Count | Should -Be 1
            Assert-MockCalled -CommandName Out-File -Times 0 -Exactly -Scope It
        }
        It 'Alias exists, removes it' {
            Mock Out-File
            $script:ALIASES = @([AliasPathMapping]::new("alias1", "C:\some\path", $null, $null))

            Remove-Alias "alias1"

            $script:ALIASES.Count | Should -Be 0
            Assert-MockCalled -CommandName Out-File -Times 1 -Exactly -Scope It
        }
    }
}