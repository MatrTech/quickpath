param(
    [string]$Increment = "Patch", # Can be "Patch", "Minor", or "Major"
    [string]$Output = "Normal"
)

function Update-Version {
    $psd1Path = 'quickpath.psd1'
    
    if (-not (Test-Path $psd1Path)) {
        throw "Manifest file not found at $psd1Path"
    }

    # Load the .psd1 manifest file
    $moduleManifest = Import-PowerShellDataFile -Path $psd1Path

    # Extract the current version
    $versionString = $moduleManifest.ModuleVersion
    $version = [Version]$versionString

    # Increment the version based on the input
    switch ($Increment) {
        "major" { $newVersion = [Version]::new(($version.Major + 1), 0, 0) }
        "minor" { $newVersion = [Version]::new($version.Major, ($version.Minor + 1), 0) }
        default { $newVersion = [Version]::new($version.Major, $version.Minor, ($version.Build + 1)) }
    }

    Write-Host "Updating module version from $versionString to $newVersion"

    # Replace the version in the manifest file
    (Get-Content $psd1Path) -replace "ModuleVersion\s*=\s*'[^']+'", "ModuleVersion = '$newVersion'" |
    Set-Content $psd1Path
}

task Clean {
    Write-Host 'Cleaning output...'
    Remove-Item -Force -Recurse -Path './output' -ErrorAction Ignore
}

task Build -Jobs Clean, {
    Write-Host 'Building module...'
    
    # Update-Version

    New-Item -Path './output/quickpath' -ItemType Directory -Force | Out-Null
    Copy-Item -Path './quickpath.psd1' -Destination './output/quickpath/'
    Copy-Item -Path './quickpath.psm1' -Destination './output/quickpath/'
    Copy-Item -Path './quickpath.nuspec' -Destination './output/quickpath/'

    New-Item -Path './output/quickpath/private' -ItemType Directory -Force | Out-Null
    New-Item -Path './output/quickpath/classes' -ItemType Directory -Force | Out-Null
    Copy-Item -Path './private/*' -Destination './output/quickpath/private/'
    Copy-Item -Path './classes/*' -Destination './output/quickpath/classes/'
}

task Test {
    Write-Host 'Running tests...'
    $config = New-PesterConfiguration
    $config.Run.Path = "."
    $config.CodeCoverage.Enabled = $true
    $config.CodeCoverage.OutputPath = "coverage.xml"
    $config.CodeCoverage.OutputFormat = "JaCoCo"
    $config.Output.Verbosity = $Output
    Invoke-Pester -Configuration $config

    $testResults = Invoke-Pester -Output "None" -PassThru

    if ($testResults.FailedCount -gt 0) {
        Write-Error "Pester tests failed!"
        Exit 1
    }
}

task Package -Jobs Build, {
    Write-Host 'Packaging module...'
    Compress-Archive -Path './output/quickpath/*' -DestinationPath './output/quickpath.zip'
}

task Publish -Jobs Package, {
    Write-Host 'Publish module...'

    $apiKey = $env:NUGET_API_KEY
    if (-not $apiKey) {
        throw "NuGet API Key is not set. Please set the NUGET_API_KEY environment variable."
    }

    Publish-Module -Path '.\output\quickpath' -NuGetApiKey $apiKey
}

task Refresh -Jobs Build, {
    Write-Host 'Refreshing module...'

    Import-Module './output/quickpath/quickpath.psd1' -Force
}

task . Clean, Build, Test, Package