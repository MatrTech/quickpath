
Context 'Update-QuickPath' {
    BeforeAll {
        . $PSScriptRoot\..\private\Update-QuickPath.ps1
    }
    BeforeEach {
        Mock Remove-Module
        Mock Update-Module
        Mock Import-Module
    }
    It 'Should be updated from gallery when FromGallery is set' {
        Mock Update-QuickPathFromGallery
        Update-QuickPath -FromGallery

        Assert-MockCalled -CommandName Update-QuickPathFromGallery -Times 1 -Exactly -Scope It 
    }
    It 'Should handle errors from Update-Module' {
        Mock Update-Module { throw [System.Exception]::new("Update failed") }
        Mock Write-Error
        { Update-QuickPath -FromGallery } | Should -Throw

        Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It 
    }
    It 'Should be updated from build when FromGallery is not set' {
        Mock Update-QuickPathFromBuild
        Update-QuickPath

        Assert-MockCalled -CommandName Update-QuickPathFromBuild -Times 1 -Exactly -Scope It 
    }
    It 'Should handle missing built module in Update-QuickPathFromBuild' {
        Mock Test-Path { $false }
        Mock Write-Warning
        Update-QuickPathFromBuild

        Assert-MockCalled -CommandName Write-Warning -Times 1 -Exactly -Scope It 
    }
    It 'Should handle errors during build update' {
        Mock Test-Path { $true }
        Mock Import-Module { throw [System.Exception]::new("Import failed") }
        Mock Write-Error
        { Update-QuickPathFromBuild } | Should -Throw

        Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It 
    }
    It 'Should remove existing module before updating from gallery' {
        Mock Get-Module { @{ Name = "quickpath" } }
        Update-QuickPath -FromGallery

        Assert-MockCalled -CommandName Remove-Module -ParameterFilter { $Name -eq "quickpath" } -Times 1 -Exactly -Scope It 
    }
    It 'Should remove existing module before updating from build' {
        Mock Get-Module { @{ Name = "quickpath" } }
        Mock Test-Path { $true }
        Update-QuickPathFromBuild

        Assert-MockCalled -CommandName Remove-Module -ParameterFilter { $Name -eq "quickpath" } -Times 1 -Exactly -Scope It 
    }
}
