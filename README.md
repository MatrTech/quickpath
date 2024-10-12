qp or quickpath is a small cli project that I created in powershell and later also in bash to help me navigating my system more quickly. By using it instead of cd and accepting aliases to navigate based on those aliases.

![Codecov](https://app.codecov.io/gh/MatrTech/quickpath/branch/main/graph/badge.svg)


# Installation
```powershell
Install-Module quickpath
```

# Usage
```powershell
qp [commands] [sub-commands]|[arguments]
```

## Aliases
An alias is added by passing it to the `alias add` command and passing a json object to it like:
```powershell
qp alias add '{"aliases": ["<myalias>"], "windowsPath": "the\\path\\to\\my\\alias" }'
```

# Testing

For some of the logic I created unit tests. For powershell I use [Pester](https://pester.dev/docs/quick-start). Pester is installed using the following:
```powershell
Install-Module Pester -Force
```

And is the unit tests are run by using the following commands:
```powershell
Invoke-Pester
Invoke-Pester qp-path.Tests.ps1
Invoke-Pester -Output Detailed .\qp-path.Tests.ps1
```