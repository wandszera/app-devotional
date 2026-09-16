param(
    [ValidateSet('status', 'validate', 'dispatch')]
    [string]$Action = 'status',
    [string]$TaskPath = ''
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$configPath = Join-Path $repoRoot '.agentops\config.json'
$statePath = Join-Path $repoRoot '.agentops\state.json'
$schemaPath = Join-Path $repoRoot '.agentops\task.schema.json'
$config = Get-Content -Raw -LiteralPath $configPath | ConvertFrom-Json
$state = Get-Content -Raw -LiteralPath $statePath | ConvertFrom-Json

function Resolve-AgyCommand {
    $command = Get-Command agy -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $localBinary = Join-Path $env:LOCALAPPDATA 'agy\bin\agy.exe'
    if (Test-Path -LiteralPath $localBinary) { return $localBinary }

    return $null
}

function Show-Status {
    [pscustomobject]@{
        status = $state.status
        executionEnabled = $config.executionEnabled
        orchestrationStarted = $state.orchestrationStarted
        baseBranch = $state.baseBranch
        baseCommit = $state.baseCommit
        dirtyBaseline = $state.dirtyBaseline
        currentTask = $state.currentTask
        antigravityCli = [bool](Resolve-AgyCommand)
        readyTasks = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot $config.paths.ready) -Filter '*.json' -File -ErrorAction SilentlyContinue).Count
    } | Format-List
}

function Assert-Configuration {
    $errors = [System.Collections.Generic.List[string]]::new()
    if ($config.schemaVersion -ne 1) { $errors.Add('config.json: schemaVersion deve ser 1.') }
    if ($state.schemaVersion -ne 1) { $errors.Add('state.json: schemaVersion deve ser 1.') }
    if (-not (Test-Path -LiteralPath $schemaPath)) { $errors.Add('task.schema.json ausente.') }
    foreach ($property in @('backlog', 'ready', 'running', 'review', 'blocked', 'done', 'handoffs', 'runtime')) {
        $relative = $config.paths.$property
        if (-not $relative) { $errors.Add("config.json: caminho '$property' ausente."); continue }
        if ($property -ne 'runtime' -and -not (Test-Path -LiteralPath (Join-Path $repoRoot $relative))) {
            $errors.Add("Diretorio ausente: $relative")
        }
    }
    if ($errors.Count -gt 0) {
        $errors | ForEach-Object { Write-Error $_ }
        throw 'Configuracao AgentOps invalida.'
    }
    Write-Output 'Configuracao AgentOps valida.'
}

function Invoke-Dispatch {
    if (-not $config.executionEnabled -or $state.status -ne 'running') {
        throw 'Execucao bloqueada: habilite executionEnabled e defina state.status como running somente apos autorizacao do usuario.'
    }
    if (-not $TaskPath) { throw 'Informe -TaskPath para uma tarefa em .agentops/tasks/ready/.' }

    $resolvedTask = (Resolve-Path -LiteralPath $TaskPath).Path
    $readyRoot = (Resolve-Path -LiteralPath (Join-Path $repoRoot $config.paths.ready)).Path
    if (-not $resolvedTask.StartsWith($readyRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'A tarefa precisa estar em .agentops/tasks/ready/.'
    }

    $task = Get-Content -Raw -LiteralPath $resolvedTask | ConvertFrom-Json
    if ($task.status -ne 'ready') { throw 'A tarefa precisa ter status ready.' }
    if ($task.complexity -notin @('simple', 'complex')) { throw 'complexity deve ser simple ou complex.' }
    $agyCommand = Resolve-AgyCommand
    if (-not $agyCommand) { throw 'Antigravity CLI (agy) nao encontrado.' }

    $worktree = (Resolve-Path -LiteralPath $task.worktreePath).Path
    $gitRoot = (& git -C $worktree rev-parse --show-toplevel 2>$null).Trim()
    if (-not $gitRoot -or $gitRoot -ne $worktree) { throw 'worktreePath precisa apontar para a raiz de um worktree Git.' }
    if (& git -C $worktree status --porcelain) { throw 'O worktree da tarefa deve estar limpo antes do despacho.' }

    $route = $config.executor.($task.complexity)
    $runtimeRoot = Join-Path $repoRoot $config.paths.runtime
    New-Item -ItemType Directory -Force -Path $runtimeRoot | Out-Null
    $resultPath = Join-Path $runtimeRoot ($task.id + '.result.json')
    $prompt = @"
Execute exatamente a tarefa descrita em $resolvedTask.
Leia primeiro AGENTS.md e respeite todas as travas, caminhos permitidos, criterios de aceite e verificacoes.
Ao concluir, crie o handoff em .agentops/handoffs/$($task.id).md e pare.
"@

    Push-Location $worktree
    try {
        & $agyCommand -p $prompt --agent $route.agent --model $route.model --effort $route.reasoningEffort --output-format json --sandbox --print-timeout $route.timeout | Set-Content -LiteralPath $resultPath -Encoding utf8
        if ($LASTEXITCODE -ne 0) { throw "Antigravity terminou com codigo $LASTEXITCODE. Veja $resultPath" }
    }
    finally {
        Pop-Location
    }
    Write-Output "Resultado salvo em $resultPath"
}

switch ($Action) {
    'status' { Show-Status }
    'validate' { Assert-Configuration; Show-Status }
    'dispatch' { Assert-Configuration; Invoke-Dispatch }
}
