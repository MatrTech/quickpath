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

            $env:LOCALAPPDATA = "$PSScriptRoot"

            Mock New-Item
            Mock Test-Path { return $true }
        }
        It 'Json file missing, create one' {
            Mock Test-Path { return $false }
            Mock Out-File
            
            Import-Aliases

            Assert-MockCalled -CommandName Out-File -Times 1 -Exactly -Scope It -ParameterFilter { 
                $Path -eq $script:JSON_FILE_PATH
            }
        }
        It 'Json file exists, dont create one' {
            Mock Get-Content { return $script:JSON_CONTENT }
            
            Import-Aliases

            Assert-MockCalled -CommandName New-Item -Times 0 -Exactly -Scope It -ParameterFilter { 
                $Path -eq $script:JSON_FILE_PATH
            }

            Assert-MockCalled -CommandName Get-Content -Times 1 -Exactly -Scope It -ParameterFilter { 
                $Path -eq $script:JSON_FILE_PATH
            }
        }
        It 'Empty JSON file, returns empty list' {
            Mock Get-Content { return '' }

            Import-Aliases 
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
            Import-Aliases 
            | ConvertTo-Json
            | Should -BeExactly $expected
        }
        It 'Json parse throws error, returns empty list and writes warning' {
            Mock Get-Content { return 'invalid json' }
            Mock Write-Warning

            Import-Aliases 
            | Should -BeNullOrEmpty

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -Scope It
            
        }
    }
    context 'Get-Script-Path' {
        It 'Creates directory if not exist' {
            Mock Test-Path { return $false }
            Mock New-Item

            Get-Script-Path 

            Assert-MockCalled -CommandName New-Item -Times 1 -Exactly -Scope It -ParameterFilter { 
                $Path -eq (Join-Path $env:LOCALAPPDATA 'quickpath') -and $ItemType -eq 'Directory'
            }
        }
        It 'Creates file if not exist' {
            Mock Test-Path {
                param($Path)
                if ($Path -eq (Join-Path $env:LOCALAPPDATA 'quickpath')) {
                    return $true
                }
                return $false
            }
            Mock Out-File

            Get-Script-Path 

            Assert-MockCalled -CommandName Out-File -Times 1 -Exactly -Scope It -ParameterFilter { 
                $Path -eq (Join-Path (Join-Path $env:LOCALAPPDATA 'quickpath') 'aliases.json')
            }
        }
        It 'Returns correct file path' {
            $expectedPath = Join-Path (Join-Path $env:LOCALAPPDATA 'quickpath') 'aliases.json'

            $result = Get-Script-Path 

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

            Resolve-FullPath $inputPath 
            | Should -Be $expectedPath
        }
        It 'Already rooted path, returns full path' {
            $inputPath = 'C:\some\path'
            $expectedPath = [System.IO.Path]::GetFullPath($inputPath)

            Resolve-FullPath $inputPath 
            | Should -Be $expectedPath
        }
        It 'Relative path, returns full path' {
            $inputPath = 'some\relative\path'
            $expectedPath = [System.IO.Path]::GetFullPath($inputPath)

            Resolve-FullPath $inputPath 
            | Should -Be $expectedPath
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
            $existingAlias = [AliasPathMapping]::new("alias1", "C:\existing\path", $null, $null)
            $script:ALIASES = @($existingAlias)
            
            Add-AliasFromPath "alias1" "C:\new\path"

            $script:ALIASES.Count | Should -Be 1
            $script:ALIASES[0].WindowsPath | Should -Be (Resolve-FullPath "C:\new\path")
        }
        It 'Alias does not exist, adds new alias' {
            Mock Test-Path { return $true }
            $script:ALIASES = @()

            Add-AliasFromPath "alias2" "C:\some\path"

            $script:ALIASES.Count | Should -Be 1
            $script:ALIASES[0].Aliases | Should -Contain "alias2"
            $script:ALIASES[0].WindowsPath | Should -Be (Resolve-FullPath "C:\some\path")
        }
    }
}