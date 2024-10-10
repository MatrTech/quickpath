qp or quickpath is a small cli project that I created in powershell and later also in bash to help me navigating my system more quickly. By using it instead of cd and accepting aliases to navigate based on those aliases.

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