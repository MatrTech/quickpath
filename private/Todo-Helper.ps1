function Add-Todo {
    param([string]$todo)
    Write-Host "Add todo: $todo"
}

function Remove-Todo {
    param([string]$todo)
    Write-Host "TODO: remove item from todolist: qp todo remove x"
}

function List-Todo {
    Write-Host "TODO: Output todo list"
}