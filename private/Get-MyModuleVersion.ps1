function Get-MyModuleVersion {
    # Get all installed versions of the module
    $moduleName = $MyInvocation.MyCommand.Module.Name
    $modules = Get-Module -Name $moduleName -ListAvailable

    if ($modules) {
        # Filter to only include modules from the current module path, to avoid listing multiple versions in different paths
        $currentPath = (Get-Module -Name $moduleName).ModuleBase

        $modules = $modules | Where-Object { $_.ModuleBase -eq $currentPath }
        
        # Sort by version and select the latest one
        $latestModule = $modules | Sort-Object Version -Descending | Select-Object -First 1
        return $latestModule.Version
    } else {
        throw "Module 'YourModuleName' is not installed."
    }
}

