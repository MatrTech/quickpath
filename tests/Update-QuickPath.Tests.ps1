
Context 'Update-QuickPath' {
    BeforeAll {
        . $PSScriptRoot\..\private\Update-QuickPath.ps1
    }
    BeforeEach {
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
    It 'Should reload module after updating from gallery' {
        Update-QuickPath -FromGallery

        Assert-MockCalled -CommandName Update-Module -ParameterFilter { $Name -eq "quickpath" } -Times 1 -Exactly -Scope It 
        Assert-MockCalled -CommandName Import-Module -ParameterFilter { $Name -eq "quickpath" } -Times 1 -Exactly -Scope It 
    }
    It 'Should reload module after updating from build' {
        Mock Test-Path { $true }
        Update-QuickPathFromBuild

        Assert-MockCalled -CommandName Import-Module -Times 1 -Exactly -Scope It 
    }
}
