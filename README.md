qp or quickpath is a small cli project that I created in powershell and later also in bash to help me navigating my system more quickly. By using it instead of cd and accepting aliases to navigate based on those aliases.

[![codecov](https://codecov.io/gh/MatrTech/quickpath/graph/badge.svg?token=SC8QPSOCO9)](https://codecov.io/gh/MatrTech/quickpath)


# Installation
```pwsh
Install-Module quickpath
```

# Usage
```pwsh
qp [commands] [sub-commands]|[arguments]
```

## Aliases
An alias is added by passing it to the `alias add` command and passing a json object to it like:
```pwsh
qp alias add '{"aliases": ["<myalias>"], "windowsPath": "the\\path\\to\\my\\alias" }'
```

```pwsh
qp alias add [alias] [path]
```

# Testing

For some of the logic I created unit tests. For powershell I use [Pester](https://pester.dev/docs/quick-start). Pester is installed using the following:
```pwsh
Install-Module Pester -Force
```

And is the unit tests are run by using the following commands:
```pwsh
Invoke-Pester
Invoke-Pester qp-path.Tests.ps1
Invoke-Pester -Output Detailed .\qp-path.Tests.ps1
```