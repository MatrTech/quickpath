Describe "Get-ModuleVersion" {
    BeforeAll {
        . $PSScriptRoot\..\private\Get-MyModuleVersion.ps1
    }
    It "Get Loaded Module version" {
        $expectedVersion = "1.2.3"
        Mock Get-Module {
            [PSCustomObject]@{
                Version = [version]$expectedVersion
            }
        }  
        
        $actualVersion = Get-MyModuleVersion

        $actualVersion | Should -Be $expectedVersion
    }
    It "Get Module version from command" {
        $expectedVersion = "2.3.4"
        Mock Get-Module {
            return $null
        }
        Mock Get-Command {
            [PSCustomObject]@{
                Module = [PSCustomObject]@{
                    Version = [version]$expectedVersion
                }
            }
        }

        $actualVersion = Get-MyModuleVersion

        $actualVersion | Should -Be $expectedVersion
    }
    It "Get Module version from manifest" {
        $expectedVersion = "3.4.5"
        Mock Get-Module {
            return $null
        }
        Mock Get-Command {
            return $null
        }
        Mock Test-ModuleManifest {
            [PSCustomObject]@{
                Version = [version]$expectedVersion
            }
        }
       
        $actualVersion = Get-MyModuleVersion

        $actualVersion | Should -Be $expectedVersion
    }
    It 'Failed to find module version, writes error' {
        Mock Get-Module {
            return $null
        }
        Mock Get-Command {
            return $null
        }
        Mock Test-ModuleManifest {
            return $null
        }
        Mock Write-Error {}

        Get-MyModuleVersion

        Assert-MockCalled Write-Error -Exactly 1
    }
}