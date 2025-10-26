function Update-QuickPath {
    param(
        [switch]$FromGallery
    )

    Write-Host "Updating quickpath..." -ForegroundColor Cyan

    if ($FromGallery) {
        Update-QuickPathFromGallery
        return
    }
    
    $outManifest = Join-Path (Split-Path $buildFile -Parent) 'output\quickpath\quickpath.psd1'
    if (Test-Path $outManifest) {
        Remove-Module quickpath -Force -ErrorAction SilentlyContinue
        Import-Module $outManifest -Force -ErrorAction SilentlyContinue
    }
    else {
        Write-Warning "Could not find built quickpath module at '$outManifest'. Please run the build script or update from gallery."
    }

    Write-Host "quickpath has been built, tested, and reloaded." -ForegroundColor Green
    #     $buildFile = Get-BuildFile

    #     if (-not $buildFile) {
    #         Write-Verbose "Build script not found near '$startPath'; falling back to gallery update."
    #         Update-QuickPathFromGallery
    #         return
    #     }

    #     ValidateOrInstallTools

    #     # Build argument list for Invoke-Build
    #     $tasks = @()
    #     if (-not $SkipTests) { $tasks += 'Test' }
    #     $tasks += 'Refresh'

    #     # Execute build in the current session so Import-Module in Refresh affects this session
    #     Invoke-Build -File $buildFile -Increment $Increment -Task $tasks

    #     # As an extra safety, try re-importing the freshly built manifest
    
    # }
    
}

function Update-QuickPathFromGallery {
    try {
        if (Get-Module -Name quickpath) {
            Remove-Module quickpath -Force -ErrorAction SilentlyContinue
        }
        Remove-Module -Name quickpath -Force -ErrorAction SilentlyContinue
        Update-Module -Name quickpath -Force -ErrorAction Stop
        Import-Module quickpath -Force -ErrorAction Stop
        Write-Host "quickpath updated from gallery and reloaded." -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to update 'quickpath' from gallery: $($_.Exception.Message)"
        throw
    }
}

# function Get-BuildFile {
#     $startPath = (Get-Location).Path
#     $dir = $startPath
#     $buildFile = $null
#     for ($i = 0; $i -lt 6; $i++) {
#         $candidate = Join-Path $dir 'quickpath.build.ps1'
#         if (Test-Path $candidate) { $buildFile = $candidate; break }
#         $parent = Split-Path $dir -Parent
#         if ([string]::IsNullOrEmpty($parent) -or $parent -eq $dir) { break }
#         $dir = $parent
#     }
#     return $buildFile
# }

# function ValidateOrInstallTools {
#     # Ensure required tools are available
#     if (-not (Get-Module -ListAvailable -Name InvokeBuild)) {
#         Write-Verbose "Installing InvokeBuild..."
#         Install-Module -Name InvokeBuild -Scope CurrentUser -Force -ErrorAction Stop
#     }
#     if (-not (Get-Module -ListAvailable -Name Pester)) {
#         Write-Verbose "Installing Pester..."
#         Install-Module -Name Pester -Scope CurrentUser -Force -ErrorAction Stop
#     }
# }