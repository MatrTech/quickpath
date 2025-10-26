function Get-MyModuleVersion {
    try {
        # Prefer the loaded module’s version
        $m = Get-Module -Name quickpath -ErrorAction SilentlyContinue
        if ($m) { 
            Write-Host $m.Version.ToString() 
            return
        }

        # Fallback: use the module that defines qp (works even if imported by manifest)
        $qpCmd = Get-Command -Name qp -ErrorAction SilentlyContinue
        if ($qpCmd -and $qpCmd.Module) { 
            Write-Host $qpCmd.Module.Version.ToString()
            return 
        }

        # Last resort: read from the manifest next to the module base
        $moduleBase = $ExecutionContext.SessionState.Module.ModuleBase
        $manifest = Join-Path $moduleBase 'quickpath.psd1'
        if (Test-Path $manifest) {
            $data = Test-ModuleManifest -Path $manifest -ErrorAction Stop
            Write-Host $data.Version.ToString()
            return
        }
    }
    catch {
        Write-Error "Could not determine module version: $($_.Exception.Message)"
    }
}