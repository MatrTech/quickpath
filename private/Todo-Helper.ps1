function Add-Todo {
    param([string]$todo)
    Write-Host "Add todo: $todo"
}

function Remove-Todo {
    param([string]$todo)
    Write-Host "Remove todo: $todo"
}

function Show-Todo {
    Write-Host "List todos"
}