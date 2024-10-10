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
            $script:JSON_FILE_PATH = "aliases-test.json"
            $script:JSON_CONTENT = Get-Content -Path ".\aliases-test.json" | ConvertFrom-Json

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
            $result = Import-Aliases | ConvertTo-Json
    
            $result | Should -BeExactly $expected
        }
    }
}