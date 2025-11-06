function Show-ModuleVersion {
    try {
        $moduleName = "quickpath"
        $commandName = "qp"

        $module = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
        if ($module) { 
            Write-Host $module.Version 
            return
        }

        $module = Get-ModuleFromCommand($commandName)
        if ($module) {
            Write-Host $module.Version
            return
        }

        $module = Get-ModuleFromManifest($moduleName)
        if ($module) {
            Write-Host $module.Version
            return
        }
        Write-Error "Module version could not be found."
    }
    catch {
        Write-Error "Could not determine module version: $($_.Exception.Message)"
    }
}

function Get-ModuleFromCommand {
    param (
        [string]$commandName
    )

    $qpCommand = Get-Command -Name $commandName -ErrorAction SilentlyContinue
    if ($qpCommand -and $qpCommand.Module) { 
        return $qpCommand.Module
    }
    
    return $null
}

function Get-ModuleFromManifest {
    param(
        [string]$moduleName = "quickpath"
    )
    $manifest = "$PSScriptRoot\..\output\$moduleName\$moduleName.psd1"
    
    if (Test-Path $manifest) {
        $data = Test-ModuleManifest -Path $manifest -ErrorAction Stop
        return $data
    }

    return $null
}