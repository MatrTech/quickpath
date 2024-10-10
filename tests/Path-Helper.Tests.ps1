Describe 'Path logic' {
    BeforeAll {
        . $PSScriptRoot\..\private\Path-Helper.ps1
        $script:SOME_VALID_PATH = "some\valid\path"
    }
    Context 'ToSourcePath' {
        BeforeEach {
            $script:SOURCE_FOLDER = "C:\temp\source\folder"
        }

        It 'Given $null returns $null' {
            ToSourcePath -Path $null 
            | Should -Be $null
        }  

        It 'Given [string]::Empty returns $null' {
            ToSourcePath -Path ${ [string]::Empty } 
            | Should -Be $null
        }  

        It "SOURCE_FOLDER missing, Returns given path" {
            $some_valid_path = "$script:SOURCE_FOLDER\$script:SOME_VALID_PATH"
            $script:SOURCE_FOLDER = $null
            ToSourcePath -Path $some_valid_path 
            | Should -Be $some_valid_path
        }

        It "SOURCE_FOLDER and path set, Replaces SOURCE_FOLDER with template" {
            $some_valid_path = "$script:SOURCE_FOLDER\$script:SOME_VALID_PATH"
            ToSourcePath -Path $some_valid_path 
            | Should -Be "$script:SOURCE_FOLDER_TEMPLATE\$script:SOME_VALID_PATH"
        }
    }

    Context 'FromSourcePath' {
        BeforeEach {
            $script:SOURCE_FOLDER = "C:\temp\source\folder"
        }

        It 'Given $null returns $null' {
            FromSourcePath -SourcePath $null 
            | Should -Be $null
        }

        It 'Given [string]::Empty returns $null' {
            FromSourcePath -SourcePath ${ string::Empty } 
            | Should -Be $null
        }

        It "SOURCE_FOLDER missing, SOURCE_FOLDER_TEMPLATE does not get replaced" {
            $script:SOURCE_FOLDER = $null
            $some_valid_path = "$script:SOURCE_FOLDER_TEMPLATE\$script:SOME_VALID_PATH"
            FromSourcePath -SourcePath $some_valid_path 
            | Should -Be $some_valid_path
        }

        It "SOURCE_FOLDER set, Replaces SOURCE_FOLDER_TEMPLATE with SOURCE_FOLDER" {
            $some_valid_path = "$script:SOURCE_FOLDER_TEMPLATE\$script:SOME_VALID_PATH"
            FromSourcePath -SourcePath $some_valid_path 
            | Should -Be "$script:SOURCE_FOLDER\$script:SOME_VALID_PATH"
        }
    }

    Context 'ToAliasPath' {
        It 'Given path is $null, returns $null' {
            ToAliasPath -Path $null -AliasPath $null
            | Should -Be $null
        }

        It 'Given path is [string]::Empty, returns $null' {
            ToAliasPath -Path ${ [string]::Empty } -AliasPath $null
            | Should -Be $null
        }

        It 'Given AliasPath is $null, returns Path' {
            ToAliasPath -Path $script:SOME_VALID_PATH -AliasPath $null 
            | Should -Be $script:SOME_VALID_PATH
        }

        It 'Given AliasPath is valid, replaces aliaspath with template' {
            $some_alias_root = "some\alias\root"
            $some_alias_path = "$some_alias_root\$script:SOME_VALID_PATH"
            ToAliasPath -Path $some_alias_path -AliasPath $some_alias_root
            | Should -Be "$script:ALIAS_PATH_TEMPLATE\$script:SOME_VALID_PATH"
        }
    }

    Context 'FromAliasPath' {
        It 'Path is $null, returns $null' {
            FromAliasPath -Path $null -AliasPath $null 
            | Should -Be $null
        }

        It 'Path is [string]::Empty, returns $null' {
            FromAliasPath -Path ${ [string]::Empty } -AliasPath $null
            | Should -Be $null
        }

        It 'AliasPath $null, returns $Path' {
            FromAliasPath -Path $script:SOME_VALID_PATH -AliasPath $null
            | Should -Be $script:SOME_VALID_PATH
        }

        It 'Valid AliasPath with template, should replace alias template with AliasPath' {
            $templatedAliasPath = "$script:ALIAS_PATH_TEMPLATE\$script:SOME_VALID_PATH"
            $aliasRootPath = "some\alias\root\folder"
            FromAliasPath -Path $templatedAliasPath -AliasPath $aliasRootPath
            | Should -Be "$aliasRootPath\$script:SOME_VALID_PATH"
        }
    }
}