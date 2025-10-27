function Update-QuickPath {
    param(
        [switch]$FromGallery
    )

    Write-Host "Updating quickpath..." -ForegroundColor Cyan

    if ($FromGallery) {
        Update-QuickPathFromGallery
        return
    }
    
    Update-QuickPathFromBuild
}

function Update-QuickPathFromGallery {
    try {
        if (Get-Module quickpath) {
            Remove-Module quickpath -Force -ErrorAction SilentlyContinue
        }
        Update-Module -Name quickpath -Force -ErrorAction Stop
        Import-Module quickpath -Force -ErrorAction Stop
        Write-Host "quickpath updated from gallery and reloaded." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update 'quickpath' from gallery: $($_.Exception.Message)"
        throw
    }
}

function Update-QuickPathFromBuild {
    try {
        $quickPathManifest = Join-Path -Path $PSScriptRoot -ChildPath "..\output\quickpath\quickpath.psd1"
        if ( -not (Test-Path $quickPathManifest)) {
            Write-Warning "Built quickpath module not found at '$quickPathManifest'. Please run 'Invoke-Build Build' first."
            return
        }

        if (Get-Module quickpath) {
            Remove-Module quickpath -Force -ErrorAction SilentlyContinue
        }
        
        Import-Module $quickPathManifest -Force -ErrorAction Stop
        Write-Host "quickpath has been built, tested, and reloaded." -ForegroundColor Green
    }
    catch {
        Write-Error "An error occurred while updating from build: $($_.Exception.Message)"
        throw
    }
}
