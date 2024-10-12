Import-Module "$PSScriptRoot\..\quickpath.psd1" -Force

Write-Host "$PSScriptRoot"
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