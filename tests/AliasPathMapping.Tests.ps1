Describe 'AliasPathMapping' {
    BeforeAll {
        . $PSScriptRoot\..\classes\AliasPathMapping.ps1
    }
    BeforeEach {
        $script:SOURCE_FOLDER = "C:\temp\source\folder"
        $script:SOURCE_FOLDER_TEMPLATE = "<SOURCE_FOLDER>"
        $script:ALIAS_PATH_TEMPLATE = "<ALIAS_PATH>"
        $script:SOME_VALID_PATH = "some\valid\path"
    }

    Context "Alias constructors" {
        It "Empty Constructor, fields not set" {
            $alias = [AliasPathMapping]::new()

            $alias | Should -Not -Be $null
            $alias.Aliases | Should -Be $null
            $alias.WindowsPath | Should -Be $null
            $alias.LinuxPath | Should -Be $null
            $alias.Solution | Should -Be $null
        }

        It "Parameterized constructor, should fill fields" {
            $aliases = @("hello", "world")

            $alias = [AliasPathMapping]::new($aliases, $script:SOME_VALID_PATH, $null, $null)
        
            $alias | Should -Not -Be $null
            $alias.Aliases | Should -Be $aliases
            $alias.WindowsPath | Should -Be $script:SOME_VALID_PATH
            $alias.LinuxPath | Should -BeNullOrEmpty
            $alias.Solution | Should -BeNullOrEmpty
        }
    }

    Context "FromJson" {
        It "Source folder template replacement" {
            $aliases = @("hello", "world")
            $json = '{"aliases": ["hello", "world"], "windowsPath": "<SOURCE_FOLDER>\\some\\valid\\path" }'

            $alias = [AliasPathMapping]::FromJson($json)

            $alias | Should -Not -Be $null
            $alias.Aliases | Should -Be $aliases
            $alias.WindowsPath | Should -Be "$script:SOURCE_FOLDER\$script:SOME_VALID_PATH"
            $alias.LinuxPath | Should -BeNullOrEmpty
            $alias.Solution | Should -BeNullOrEmpty
        }

        It "alias replacement test without windowspath" {
            $aliases = @("hello", "world")
            $json = '{"aliases": ["hello", "world"], "solution": "<ALIAS_PATH>\\some\\valid\\path" }'

            $alias = [AliasPathMapping]::FromJson($json)
        
            $alias | Should -Not -Be $null
            $alias.Aliases | Should -Be $aliases
            $alias.WindowsPath | Should -BeNullOrEmpty
            $alias.LinuxPath | Should -BeNullOrEmpty
            $alias.Solution | Should -Be "<ALIAS_PATH>\$script:SOME_VALID_PATH"
        }

        It "Alias replacement test with windowsPath, should replace" {
            $aliases = @("hello", "world")
            $json = '{"aliases": ["hello", "world"], "windowsPath": "<SOURCE_FOLDER>\\alias\\root", "solution": "<ALIAS_PATH>\\some\\valid\\path" }'

            $alias = [AliasPathMapping]::FromJson($json)
        
            $alias | Should -Not -Be $null
            $alias.Aliases | Should -Be $aliases
            $alias.WindowsPath | Should -Be "$script:SOURCE_FOLDER\alias\root"
            $alias.LinuxPath | Should -BeNullOrEmpty
            $alias.Solution | Should -Be "$script:SOURCE_FOLDER\alias\root\$script:SOME_VALID_PATH"
        }

        It 'Invalid Json should be return NullOrEmpty' {
            [AliasPathMapping]::FromJson('')
            | Should -BeNullOrEmpty
        }
    }

    Context "FromObject" {
        It 'Source null, returns null' {
            $alias = [AliasPathMapping]::FromJson([PSCustomObject]$null)
            $alias | Should -Be $null
        }
        It "Source folder template replacement" {
            $aliases = @("hello", "world")
            $object = @{
                aliases     = $aliases
                windowsPath = "$script:SOURCE_FOLDER_TEMPLATE\$script:SOME_VALID_PATH"
            }

            $alias = [AliasPathMapping]::FromObject([PSCustomObject]$object)

            $alias | Should -Not -Be $null
            $alias.Aliases | Should -Be $aliases
            $alias.WindowsPath | Should -Be "$script:SOURCE_FOLDER\$script:SOME_VALID_PATH"
            $alias.LinuxPath | Should -BeNullOrEmpty
            $alias.Solution | Should -BeNullOrEmpty
        }

        It "alias replacement test without windowspath" {
            $aliases = @("hello", "world")
            $object = @{
                aliases  = $aliases
                solution = "$script:ALIAS_PATH_TEMPLATE\$script:SOME_VALID_PATH" 
            }

            $alias = [AliasPathMapping]::FromObject([PSCustomObject]$object)
        
            $alias | Should -Not -Be $null
            $alias.Aliases | Should -Be $aliases
            $alias.WindowsPath | Should -BeNullOrEmpty
            $alias.LinuxPath | Should -BeNullOrEmpty
            $alias.Solution | Should -Be "$script:ALIAS_PATH_TEMPLATE\$script:SOME_VALID_PATH"
        }

        It "Alias replacement test with windowsPath, should replace" {
            $aliases = @("hello", "world")
            $object = @{
                aliases     = $aliases
                windowsPath = "$script:SOURCE_FOLDER_TEMPLATE\alias\root"
                solution    = "$script:ALIAS_PATH_TEMPLATE\$script:SOME_VALID_PATH" 
            }

            $alias = [AliasPathMapping]::FromObject([PSCustomObject]$object)
        
            $alias | Should -Not -Be $null
            $alias.Aliases | Should -Be $aliases
            $alias.WindowsPath | Should -Be "$script:SOURCE_FOLDER\alias\root"
            $alias.LinuxPath | Should -BeNullOrEmpty
            $alias.Solution | Should -Be "$script:SOURCE_FOLDER\alias\root\$script:SOME_VALID_PATH"
        }
    }

    Context 'FromJsonArray' {
        It 'Valid json array of 2 objects, should return 2 AliasPathMappings' {
            $json = @'
        [
            {
                "aliases": ["hello"],
                "windowsPath": "some\\valid\\path"
            }, 
            {
                "aliases": ["world"],
                "linuxPath": "/some/valid/path"
            }
        ]
'@
            $aliases = [AliasPathMapping]::FromJsonArray($json)
            $aliases.count | Should -Be 2
            $aliases[0].aliases | Should -Be @("hello")
            $aliases[0].windowsPath | Should -Be "some\valid\path"
            $aliases[1].aliases | Should -Be @("world")
        }

        It 'Empty json should be null or empty' {
            [AliasPathMapping]::FromJsonArray('')
            | Should -BeNullOrEmpty
        }
    }

    Context 'ToJson' {
        It 'Valid instance of class, returns json' {
            # Arrange
            $aliases = @("alias1", "alias2")
            $windowsPath = "$script:SOURCE_FOLDER\alias\root"
            $linuxPath = "/path/to/linux"
            $solution = "$script:SOURCE_FOLDER\alias\root\$script:SOME_VALID_PATH"
            $expectedJson = @'
            {
                "aliases":  [
                    "alias1",
                    "alias2"
                ],
                "windowsPath":  "<SOURCE_FOLDER>\\alias\\root",
                "linuxPath":  "/path/to/linux",
                "solution":  "<ALIAS_PATH>\\some\\valid\\path"
            }
'@
            $expectedJson = $expectedJson.Trim()

            $aliasPathMapping = [AliasPathMapping]::new($aliases, $windowsPath, $linuxPath, $solution)

            # Act
            $actualJson = $aliasPathMapping.ToJson()

            # Convert JSON strings to compare as strings
            $expectedJsonString = $expectedJson | ConvertFrom-Json | ConvertTo-Json

            # Assert
            $actualJson | Should -BeExactly $expectedJsonString
        }
    }

    Context 'ToJsonArray' {
        It 'Array of valid AliasPathMappings, maps to json' {
            # Arrange
            $aliases = @("alias1", "alias2")
            $windowsPath = "$script:SOURCE_FOLDER\alias\root"
            $linuxPath = "/path/to/linux"
            $solution = "$script:SOURCE_FOLDER\alias\root\$script:SOME_VALID_PATH"
            $expectedJson = @'
            [
                {
                    "aliases":  [
                        "alias1",
                        "alias2"
                    ],
                    "windowsPath":  "<SOURCE_FOLDER>\\alias\\root",
                    "linuxPath":  "/path/to/linux",
                    "solution":  "<ALIAS_PATH>\\some\\valid\\path"
                }, 
                {
                    "aliases":  [
                        "alias1",
                        "alias2"
                    ],
                    "windowsPath":  "<SOURCE_FOLDER>\\alias\\root",
                    "linuxPath":  "/path/to/linux",
                    "solution":  "<ALIAS_PATH>\\some\\valid\\path"
                }
            ]
'@
            $aliasPathMappings = @(
                [AliasPathMapping]::new($aliases, $windowsPath, $linuxPath, $solution), 
                [AliasPathMapping]::new($aliases, $windowsPath, $linuxPath, $solution)
            )

            # Act
            $actualJson = [AliasPathMapping]::ToJson($aliasPathMappings)

            # Convert JSON strings to compare as strings
            $expectedJsonString = $expectedJson | ConvertFrom-Json | ConvertTo-Json

            # Assert
            $actualJson | Should -BeExactly $expectedJsonString
        }
    }
}