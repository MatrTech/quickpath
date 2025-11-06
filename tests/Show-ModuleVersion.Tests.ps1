Describe "Show-ModuleVersion" {
    BeforeAll {
        . $PSScriptRoot\..\private\Show-ModuleVersion.ps1
    }
    BeforeEach {
        Mock Get-Module {}  
        Mock Get-Command {}
        Mock Test-ModuleManifest {}
        Mock Write-Host {}
        Mock Test-Path { $false }
        Mock Write-Error {}
    }
    It "Show Loaded Module version" {
        $expectedVersion = "1.2.3"
        Mock Get-Module {
            [PSCustomObject]@{
                Version = [version]$expectedVersion
            }
        }  
        
        Show-ModuleVersion
        
        Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq $expectedVersion }
    }
    It "Show Module version from command" {
        $expectedVersion = "2.3.4"
        Mock Get-Command {
            [PSCustomObject]@{
                Module = [PSCustomObject]@{
                    Version = [version]$expectedVersion
                }
            }
        }

        Show-ModuleVersion

        Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq $expectedVersion }
    }
    It "Get Module version from manifest" {
        $expectedVersion = "3.4.5"
        Mock Test-ModuleManifest {
            [PSCustomObject]@{
                Version = [version]$expectedVersion
            }
        }
        Mock Test-Path { $true }

        Show-ModuleVersion

        Assert-MockCalled Write-Host -Exactly 1 -ParameterFilter { $Object -eq $expectedVersion }
    }
    It 'Failed to find module version, writes error' {
        Show-ModuleVersion

        Assert-MockCalled Write-Error -Exactly 1
    }
    It 'Catches exception and writes error' {
        Mock Get-Module {
            throw "Some error"
        }

        Show-ModuleVersion

        Assert-MockCalled Write-Error -Exactly 1
    }
}