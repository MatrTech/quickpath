$modulePath = "$PSScriptRoot/../quickpath.psd1"
Import-Module $modulePath -Force

Write-Host "ROOT FOLDER: $PSScriptRoot"
InModuleScope quickpath {
    Describe 'quickpath' {
        BeforeEach {
            Mock Test-Path { return $true }
            Mock Set-Location
            Mock Import-Aliases -Verifiable
        }
        It 'Failing test' {
            $result = $true
            $result | Should -Be  $true
        }
    }
}