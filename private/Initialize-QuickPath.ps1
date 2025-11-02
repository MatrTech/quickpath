. $PSScriptRoot\..\private\Alias-Helper.ps1
. $PSScriptRoot\..\private\Get-Commands.ps1

function Initialize-QuickPath {
    $aliasFilePath = Get-AliasFilePath
    $aliasDirectory = Split-Path $aliasFilePath -Parent
         
    if (Test-Path $aliasFilePath) {
        return
    }
    
    if (-not (Test-Path $aliasDirectory)) {
        New-Item -Path $aliasDirectory -ItemType Directory -Force | Out-Null
    }
            
    if (-not (Test-Path $aliasFilePath)) {
        '[]' | Out-File -FilePath $aliasFilePath -Encoding UTF8
    }

    $script:JSON_FILE_PATH = $aliasFilePath
    $script:ALIASES = Import-Aliases $aliasFilePath
    $script:COMMANDS = Get-Commands
}