$script:SOURCE_FOLDER_TEMPLATE = "<SOURCE_FOLDER>"
$script:ALIAS_PATH_TEMPLATE = "<ALIAS_PATH>"
$script:SOURCE_FOLDER = [Environment]::GetEnvironmentVariable('SOURCE_FOLDER', 'User')

function ToSourcePath {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Path
    ) 

    if ([string]::IsNullOrEmpty($Path)) {
        return $null;
    }

    if ([string]::IsNullOrEmpty($script:SOURCE_FOLDER)) {
        return [string]$Path
    }

    return [string]$Path.Replace($script:SOURCE_FOLDER, $script:SOURCE_FOLDER_TEMPLATE)
}

function FromSourcePath {
    Param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $SourcePath)

    if ([string]::IsNullOrEmpty($SourcePath)) {
        return $null
    }

    if ([string]::IsNullOrEmpty($script:SOURCE_FOLDER)) {
        return [string]$SourcePath
    }
    
    return [string]$SourcePath.Replace("$script:SOURCE_FOLDER_TEMPLATE", "$script:SOURCE_FOLDER");
}

function ToAliasPath {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Path, 
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$AliasPath) 

    if ([string]::IsNullOrEmpty($Path)) {
        return $null
    }

    if ([string]::IsNullOrEmpty($AliasPath)) {
        return [string]$Path
    }

    return [string]$Path.Replace($AliasPath, $script:ALIAS_PATH_TEMPLATE)
}

function FromAliasPath {
    param([Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Path, 
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $AliasPath) 

    if ([string]::IsNullOrEmpty($Path)) {
        return $null
    }

    if ([string]::IsNullOrEmpty($AliasPath)) {
        return [string]$Path
    }
    
    return [string]$Path.Replace($script:ALIAS_PATH_TEMPLATE, $AliasPath)
}
