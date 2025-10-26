
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
}
