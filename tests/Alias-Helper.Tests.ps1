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
            $script:JSON_FILE_PATH = "$PSScriptRoot\aliases-test.json"
            $script:JSON_CONTENT = Get-Content -Path $script:JSON_FILE_PATH | ConvertFrom-Json

            $env:LOCALAPPDATA = "localappdata"

            Mock New-Item
            Mock Test-Path { return $true }
        }
        It 'Json file missing, create one' {
            Mock Test-Path { return $false }
            
            Import-Aliases

            Assert-MockCalled -CommandName New-Item -Times 1 -Exactly -Scope It -ParameterFilter { 
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
    }
    context 'Get-Script-Path' {
        It 'Creates directory and file if not exist' {
            Mock Test-Path { return $false }
            Mock New-Item

            Get-Script-Path 

            Assert-MockCalled -CommandName New-Item -Times 2 -Exactly -Scope It
            Assert-MockCalled -CommandName New-Item -Times 1 -Exactly -Scope It -ParameterFilter { 
                $Path -eq (Join-Path $env:LOCALAPPDATA 'quickpath') -and $ItemType -eq 'Directory'
            }
            Assert-MockCalled -CommandName New-Item -Times 1 -Exactly -Scope It -ParameterFilter { 
                $Path -eq (Join-Path (Join-Path $env:LOCALAPPDATA 'quickpath') 'aliases.json') -and $ItemType -eq 'File'
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
}