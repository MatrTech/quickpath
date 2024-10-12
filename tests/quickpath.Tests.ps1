Remove-Module "quickpath" -ErrorAction SilentlyContinue
Import-Module "$PSScriptRoot/../quickpath.psd1" -Force


InModuleScope quickpath {
    Describe 'quickpath' {
        BeforeEach {
            Mock Test-Path { return $true }
            Mock Set-Location
            Mock Import-Aliases -Verifiable
        }
        context 'init' {  
            It "Import-Aliases Gets called" {
                { qp "some-valid-path" } | Should -Not -Throw
                
                Assert-MockCalled Import-Aliases -Exactly 1 -Scope It
            }
        }
        context 'NavigateByPath' {
            It "Valid alias, should not throw" {
                { qp "some-valid-alias" } | Should -Not -Throw

                Assert-MockCalled Set-Location -Exactly 1 -Scope It
            }
        }
    }
}