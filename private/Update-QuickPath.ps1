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
        
        # Remove the currently loaded module first
        Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
        
        # Update the module
        Update-Module -Name $moduleName -Force -ErrorAction Stop
        
        # Get the latest installed version path explicitly
        $latestModule = Get-Module -Name $moduleName -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
        if (-not $latestModule) {
            throw "No installed version of $moduleName found after update"
        }
        
        # Force a complete refresh by clearing any cached module information
        Get-Module -Name $moduleName -All | Remove-Module -Force -ErrorAction SilentlyContinue
        
        # Import the specific latest version by name and version, ensuring global scope
        Import-Module -Name $moduleName -RequiredVersion $latestModule.Version -Force -Global -ErrorAction Stop
        
        Write-Host "$moduleName updated from gallery (v$($latestModule.Version)) and reloaded." -ForegroundColor Green
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
        
        # Unload any existing module instance so the built manifest is imported fresh
        Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
        Import-Module $quickPathManifest -Force -ErrorAction Stop
        Write-Host "$moduleName has been built, tested, and reloaded." -ForegroundColor Green
    }
    catch {
        Write-Error "An error occurred while updating from build: $($_.Exception.Message)"
        throw
    }
}
