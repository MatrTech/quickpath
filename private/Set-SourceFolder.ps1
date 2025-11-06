function Set-SourceFolder {
    param([string]$new_source_folder)

    if ([string]::IsNullOrWhiteSpace($new_source_folder)) {
        $new_source_folder = Read-Host -Prompt 'Enter your source folder location'
    }

    if (!(Test-Path $new_source_folder)) {
        throw "provided path: $new_source_folder not valid"
    }
    
    [Environment]::SetEnvironmentVariable('SOURCE_FOLDER', $new_source_folder, 'User')

    $script:SOURCE_FOLDER = $new_source_folder
}