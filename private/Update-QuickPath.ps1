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
        $moduleName = "quickpath"
        Update-Module -Name $moduleName -Force -ErrorAction Stop
        Import-Module $moduleName -Force -ErrorAction Stop
        Write-Host "$moduleName updated from gallery and reloaded." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update '$moduleName' from gallery: $($_.Exception.Message)"
        throw
    }
}

function Update-QuickPathFromBuild {
    try {
        $moduleName = "quickpath"
        $quickPathManifest = Join-Path -Path $PSScriptRoot -ChildPath "..\output\quickpath\quickpath.psd1"
        if ( -not (Test-Path $quickPathManifest)) {
            Write-Warning "Built quickpath module not found at '$quickPathManifest'. Please run 'Invoke-Build Build' first."
            return
        }
        
        Import-Module $quickPathManifest -Force -ErrorAction Stop
        Write-Host "$moduleName has been built, tested, and reloaded." -ForegroundColor Green
    }
    catch {
        Write-Error "An error occurred while updating from build: $($_.Exception.Message)"
        throw
    }
}
