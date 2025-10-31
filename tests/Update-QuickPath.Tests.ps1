
Context 'Update-QuickPath' {
    BeforeAll {
        . $PSScriptRoot\..\private\Update-QuickPath.ps1
    }
    BeforeEach {
        # Mock only external dependencies, not the functions we want to test
        Mock Remove-Module
        Mock Update-Module
        Mock Import-Module
        Mock Test-Path
        Mock Write-Error
        Mock Write-Warning
        Mock Write-Host
        Mock Get-Module
        Mock Join-Path
    }
    
    Context 'Main Update-QuickPath function' {
        It 'Should call Update-QuickPathFromGallery when FromGallery is set' {
            Mock Update-QuickPathFromGallery
            Update-QuickPath -FromGallery

            Assert-MockCalled -CommandName Update-QuickPathFromGallery -Times 1 -Exactly -Scope It 
        }
        
        It 'Should call Update-QuickPathFromBuild when FromGallery is not set' {
            Mock Update-QuickPathFromBuild
            Update-QuickPath

            Assert-MockCalled -CommandName Update-QuickPathFromBuild -Times 1 -Exactly -Scope It 
        }
    }
    
    Context 'Update-QuickPathFromGallery function' {
        It 'Should remove, update, and reload module from gallery' {
            Mock Get-Module { 
                @{ 
                    ModuleBase = "TestPath"
                    Version = [version]"1.0.0"
                } 
            }
            
            Update-QuickPathFromGallery

            Assert-MockCalled -CommandName Remove-Module -ParameterFilter { $Name -eq 'quickpath' } -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Update-Module -ParameterFilter { $Name -eq 'quickpath' } -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Get-Module -ParameterFilter { $Name -eq 'quickpath' -and $ListAvailable } -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Import-Module -ParameterFilter { $Name -eq 'quickpath' -and $RequiredVersion -eq '1.0.0' } -Times 1 -Exactly -Scope It
        }
        
        It 'Should handle errors when Update-Module fails' {
            Mock Update-Module { throw [System.Exception]::new("Update failed") }
            
            { Update-QuickPathFromGallery } | Should -Throw
            Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It
        }
        
        It 'Should handle errors when no module found after update' {
            Mock Get-Module { $null }
            
            { Update-QuickPathFromGallery } | Should -Throw "No installed version of quickpath found after update"
        }
    }
    
    Context 'Update-QuickPathFromBuild function' {
        It 'Should remove and reload module from build when manifest exists' {
            Mock Test-Path { $true }
            Mock Join-Path { "d:\Source\MatrTech\quickpath\output\quickpath\quickpath.psd1" }
            
            Update-QuickPathFromBuild

            Assert-MockCalled -CommandName Remove-Module -ParameterFilter { $Name -eq 'quickpath' } -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Import-Module -Times 1 -Exactly -Scope It
        }
        
        It 'Should warn when built module manifest is missing' {
            Mock Test-Path { $false }
            Mock Join-Path { "d:\Source\MatrTech\quickpath\output\quickpath\quickpath.psd1" }
            
            Update-QuickPathFromBuild

            Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -Scope It
            Assert-MockCalled -CommandName Import-Module -Times 0 -Exactly -Scope It
        }
        
        It 'Should handle errors during import' {
            Mock Test-Path { $true }
            Mock Join-Path { "d:\Source\MatrTech\quickpath\output\quickpath\quickpath.psd1" }
            Mock Import-Module { throw [System.Exception]::new("Import failed") }
            
            { Update-QuickPathFromBuild } | Should -Throw
            Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It
        }
    }
}
