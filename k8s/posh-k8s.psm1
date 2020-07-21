##
#	kube helper commands and functions for powershell
##

#$env:KUBECONFIG="H:\.kube\config.nonprod"
#$env:KUBECTL_NAMESPACE="development"

#alias knonprod='echo -ne "\e]11;#000000\a"; export KUBECONFIG="/home/dwitt/.kube/config.k8snonprod"; PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] (knonprod) \$ "'
#alias kazure='echo -ne "\e]11;#000000\a"; export KUBECONFIG="/home/dwitt/.kube/config.azure"; PS1="\[\e]0;\u@\h: \w\a\]${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] (k8sazure) \$ "'

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

Function kenv {
  Param(
	[string] $env,
	[string] $namespace
  )

	$env:KUBECTL_NAMESPACE=$namespace

  $env:KUBECONFIG="H:\.kube\config.$env"
  }
