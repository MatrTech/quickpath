
Context 'Update-QuickPath' {
    BeforeAll {
        . $PSScriptRoot\..\private\Update-QuickPath.ps1
    }
    It 'Should call Update-Module and Import-Module' {
        Mock Update-Module
        Mock Import-Module
        Mock Write-Host
        Update-QuickPath

        Assert-MockCalled -CommandName Update-Module -Times 1 -Exactly -Scope It -ParameterFilter { 
            $Name -eq 'quickpath' -and $Force -eq $true -and $ErrorAction -eq 'Stop'
        }

        Assert-MockCalled -CommandName Import-Module -Times 1 -Exactly -Scope It -ParameterFilter { 
            $Name -eq 'quickpath' -and $Force -eq $true -and $ErrorAction -eq 'Stop'
        }

        Assert-MockCalled -CommandName Write-Host -Times 1 -Exactly -Scope It -ParameterFilter { 
            $Object -eq "quickpath updated from gallery and reloaded." -and $ForegroundColor -eq 'Green'
        }
    }
    It 'Should handle errors from Update-Module' {
        Mock Update-Module { throw [System.Exception]::new("Update failed") }
        Mock Write-Error
        { Update-QuickPath } | Should -Throw

        Assert-MockCalled -CommandName Write-Error -Times 1 -Exactly -Scope It 
    }
}
