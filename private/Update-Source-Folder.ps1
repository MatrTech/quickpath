function SetSourceFolder([string]$newSourceFolder) {
    if ([string]::IsNullOrWhiteSpace($newSourceFolder)) {
        $newSourceFolder = Read-Host -Prompt 'Enter your source folder location'
    }

    if ((Test-Path $newSourceFolder) -eq $true) {
        throw "Invalid source folder"
    }
    
    [Environment]::SetEnvironmentVariable('SOURCE_FOLDER', $newSourceFolder, 'User')

    $newSourceFolder
}

function GetSourceFolder {
    if ([string]::IsNullOrWhiteSpace($script:SOURCE_FOLDER)) {
        $script:SOURCE_FOLDER = SetSourceFolder('')
    }

    $script:SOURCE_FOLDER
}

# Idea: Add a way to define multiple alias folders
# function SetAliasFolder([string]$aliasFolderName, [string]$path) {
    
# }
