. $PSScriptRoot\..\private\Path-Helper.ps1

class AliasPathMapping {
    [string[]] $Aliases
    [string] $WindowsPath
    [string] $LinuxPath
    [string] $Solution

    AliasPathMapping() {}
    AliasPathMapping([string[]]$Aliases, [string]$WindowsPath, [string]$LinuxPath, [string]$Solution) {
        $this.Aliases = $Aliases
        $this.WindowsPath = $WindowsPath
        $this.LinuxPath = $LinuxPath
        $this.Solution = $Solution
    }

    static [AliasPathMapping] FromObject([PSCustomObject]$object) {
        if ($null -eq $object) {
            return $null
        }

        $deserializedAliases = $object.aliases
        $deserializedWindowsPath = FromSourcePath -SourcePath $object.windowsPath 
        $deserializedLinuxPath = $object.linuxPath
        $deserializedSolution = FromAliasPath -Path $object.solution -AliasPath $deserializedWindowsPath

        return [AliasPathMapping]::new(
            $deserializedAliases,
            $deserializedWindowsPath,
            $deserializedLinuxPath,
            $deserializedSolution
        )
    }

    static [AliasPathMapping] FromJson([string]$Json) {
        $jsonObject = $json | ConvertFrom-Json

        if ($null -eq $jsonObject) {
            return $null
        }

        return [AliasPathMapping]::FromObject([PSCustomObject]$jsonObject)
    }

    static [AliasPathMapping[]] FromJsonArray([string]$json) {
        $jsonArray = $json | ConvertFrom-Json    

        if ($null -eq $jsonArray) {
            return $null
        }

        $result = @()

        foreach ($object in $jsonArray) {
            $result += [AliasPathMapping]::FromObject([PSCustomObject]$object)
        }

        return $result
    }

    static [PSCustomObject] ToSerializableObject([AliasPathMapping] $aliasPathMapping) {
        $serializedWindowsPath = ToSourcePath -Path $aliasPathMapping.WindowsPath
        $serializedSolutionPath = ToAliasPath -Path $aliasPathMapping.Solution -AliasPath $aliasPathMapping.WindowsPath
    
        return [PSCustomObject]@{
            aliases     = $aliasPathMapping.Aliases
            windowsPath = $serializedWindowsPath
            linuxPath   = $aliasPathMapping.LinuxPath
            solution    = $serializedSolutionPath    
        }
    }

    static [string] ToJson([AliasPathMapping[]] $aliasPathMappings) {
        $result = @()

        foreach ($aliasPathMapping in $aliasPathMappings) {
            
            $result += [AliasPathMapping]::ToSerializableObject($aliasPathMapping)
        }

        return $result | ConvertTo-Json
    }

    [string] ToJson() {
        return [AliasPathMapping]::ToSerializableObject($this) | ConvertTo-Json
    }
}