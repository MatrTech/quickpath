Remove-Module "quickpath" -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../quickpath.psd1" -Force

InModuleScope quickpath {
    Describe 'Help Functionality Tests' {
        BeforeEach {
            Mock Get-Script-Path { return "/tmp/test-aliases.json" }
            Mock Import-Aliases { return @() }
            Mock Test-Path { return $false }
        }

        Context 'Command Help' {
            It 'Command with subcommands shows help without error' {
                { qp alias help } | Should -Not -Throw
            }

            It 'Subcommand shows help without error' {
                { qp alias add help } | Should -Not -Throw
            }

            It 'Simple command shows help without error' {
                Mock Get-MyModuleVersion { return "1.0.0" }
                { qp version help } | Should -Not -Throw
            }

            It 'Todo subcommand shows help without error' {
                { qp todo help } | Should -Not -Throw
            }

            It 'Todo add subcommand shows help without error' {
                { qp todo add help } | Should -Not -Throw
            }

            It 'Todo remove subcommand shows help without error' {
                { qp todo remove help } | Should -Not -Throw
            }

            It 'Todo list subcommand shows help without error' {
                { qp todo list help } | Should -Not -Throw
            }

            It 'Alias remove subcommand shows help without error' {
                { qp alias remove help } | Should -Not -Throw
            }

            It 'Alias list subcommand shows help without error' {
                { qp alias list help } | Should -Not -Throw
            }
        }

        Context 'Command Functions Exist' {
            It 'List-Alias function exists' {
                Get-Command -Name List-Alias -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }

            It 'List-Todo function exists' {
                Get-Command -Name List-Todo -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }

            It 'Remove-Todo function exists' {
                Get-Command -Name Remove-Todo -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }

            It 'Show-Version function exists' {
                Get-Command -Name Show-Version -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }

            It 'Invoke-Update function exists' {
                Get-Command -Name Invoke-Update -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }

            It 'Show-Help function exists' {
                Get-Command -Name Show-Help -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Command Execution' {
            It 'List-Alias executes without error' {
                Mock Write-Host {}
                { List-Alias } | Should -Not -Throw
            }

            It 'List-Todo executes without error' {
                Mock Write-Host {}
                { List-Todo } | Should -Not -Throw
            }

            It 'Remove-Todo executes without error' {
                Mock Write-Host {}
                { Remove-Todo -todo "test" } | Should -Not -Throw
            }

            It 'Show-Version executes without error' {
                Mock Write-Host {}
                Mock Get-MyModuleVersion { return "1.0.0" }
                { Show-Version } | Should -Not -Throw
            }

            It 'Show-Help executes without error' {
                Mock Write-Host {}
                Mock Get-DynamicHelp { return "Help text" }
                { Show-Help } | Should -Not -Throw
            }
        }
    }
}
