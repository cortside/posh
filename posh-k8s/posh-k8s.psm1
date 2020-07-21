##
#	kube helper commands and functions for powershell
##

# env var for where the config file is
#$env:KUBECONFIG="H:\.kube\config.nonprod"

# env var for which namespace to default to
#$env:KUBECTL_NAMESPACE="development"

# set the kubectl env var
function kenv {
  Param(
	[string] $env,
	[string] $namespace
  )

	$env:KUBECTL_NAMESPACE=$namespace
	$env:KUBECONFIG="$($env:USERPROFILE)\.kube\config.$env"
}

# kubectl command with some arguments injected
function k { 
	if (Test-Path env:KUBECTL_NAMESPACE) {
		kubectl --insecure-skip-tls-verify=true --namespace=$env:KUBECTL_NAMESPACE @args 
	} else {
		kubectl --insecure-skip-tls-verify=true @args 
	}
}

function global:prompt
{
    if ($GitPromptSettings.DefaultPromptEnableTiming) {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
    }
    $origLastExitCode = $global:LASTEXITCODE

    # Display default prompt prefix if not empty.
    $defaultPromptPrefix = [string]$GitPromptSettings.DefaultPromptPrefix
    if ($defaultPromptPrefix) {
        $expandedDefaultPromptPrefix = $ExecutionContext.SessionState.InvokeCommand.ExpandString($defaultPromptPrefix)
        Write-Prompt $expandedDefaultPromptPrefix
    }

    # Write the abbreviated current path
    $currentPath = $ExecutionContext.SessionState.InvokeCommand.ExpandString($GitPromptSettings.DefaultPromptPath)
    Write-Prompt $currentPath

# inject the kube env into the prompt -- before the git info
$kubeenv = [System.IO.Path]::GetExtension($env:KUBECONFIG).Replace(".", "")
Write-Prompt " [" -ForegroundColor yellow
Write-Prompt "$kubeenv" -ForegroundColor blue
if (Test-Path env:KUBECTL_NAMESPACE) {
Write-Prompt "/" -ForegroundColor yellow
Write-Prompt "$env:KUBECTL_NAMESPACE" -ForegroundColor blue
}
Write-Prompt "]" -ForegroundColor yellow

    # Write the Git status summary information
    Write-VcsStatus

    # If stopped in the debugger, the prompt needs to indicate that in some fashion
    $hasInBreakpoint = [runspace]::DefaultRunspace.Debugger | Get-Member -Name InBreakpoint -MemberType property
    $debugMode = (Test-Path Variable:/PSDebugContext) -or ($hasInBreakpoint -and
[runspace]::DefaultRunspace.Debugger.InBreakpoint)
    $promptSuffix = if ($debugMode) { $GitPromptSettings.DefaultPromptDebugSuffix } else {
$GitPromptSettings.DefaultPromptSuffix }

    # If user specifies $null or empty string, set to ' ' to avoid "PS>" unexpectedly being displayed
    if (!$promptSuffix) {
        $promptSuffix = ' '
    }

    $expandedPromptSuffix = $ExecutionContext.SessionState.InvokeCommand.ExpandString($promptSuffix)

    # If prompt timing enabled, display elapsed milliseconds
    if ($GitPromptSettings.DefaultPromptEnableTiming) {
        $sw.Stop()
        $elapsed = $sw.ElapsedMilliseconds
        Write-Prompt " ${elapsed}ms"
    }

    $global:LASTEXITCODE = $origLastExitCode
    $expandedPromptSuffix
}
