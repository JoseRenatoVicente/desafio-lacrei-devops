param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("prod", "staging", "shared")]
    [string]$Environment
)

function Invoke-Terraform {
    param(
        [string]$Command,
        [string]$VarFile
    )
    
    $tfCommand = "terraform $Command -var-file=`"$VarFile`""
    Write-Host "Executando: $tfCommand"
    
    & terraform $Command -var-file="$VarFile"
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Erro ao executar terraform $Command"
        exit 1
    }
}


# Definir paths e workspaces conforme ambiente
if ($Environment -eq "shared") {
    $tfDir = "shared"
    $varFile = "../terraform.tfvars.shared"
    $workspace = "default"
} elseif ($Environment -eq "staging") {
    $tfDir = "."
    $varFile = "terraform.tfvars.staging"
    $workspace = "staging"
} else {
    $tfDir = "."
    $varFile = "terraform.tfvars"
    $workspace = "default"
}

Write-Host "=== Deploy para ambiente: $Environment ===" -ForegroundColor Green
Write-Host "Workspace: $workspace" -ForegroundColor Yellow
Write-Host "Arquivo de variáveis: $varFile" -ForegroundColor Yellow
Write-Host "Diretório Terraform: $tfDir" -ForegroundColor Yellow

Push-Location $tfDir

Write-Host "Inicializando Terraform..." -ForegroundColor Cyan
terraform init

if ($Environment -eq "staging") {
    Write-Host "Criando workspace staging..." -ForegroundColor Cyan
    terraform workspace new $workspace 2>$null
}

Write-Host "Selecionando workspace: $workspace" -ForegroundColor Cyan
terraform workspace select $workspace

Write-Host "Verificando estado atual..." -ForegroundColor Cyan
$currentState = terraform state list
if ($currentState) {
    Write-Host "Recursos no estado atual:" -ForegroundColor Yellow
    $currentState | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
} else {
    Write-Host "Estado vazio - primeiro deploy" -ForegroundColor Green
}

Write-Host "Executando terraform plan..." -ForegroundColor Cyan
Invoke-Terraform -Command "plan" -VarFile $varFile

Pop-Location

$confirm = Read-Host "Deseja aplicar as alterações? (S/N)"
if ($confirm -eq "S" -or $confirm -eq "s") {
    Push-Location $tfDir
    Write-Host "Aplicando alterações no ambiente $Environment..." -ForegroundColor Green
    Invoke-Terraform -Command "apply" -VarFile $varFile
    
    Write-Host "=== Deploy concluído! ===" -ForegroundColor Green
    Write-Host "Workspace atual: $workspace" -ForegroundColor Yellow
    
    Write-Host "Executando terraform output..." -ForegroundColor Cyan
    terraform output
    Pop-Location
} else {
    Write-Host "Deploy cancelado pelo usuário" -ForegroundColor Yellow
}
