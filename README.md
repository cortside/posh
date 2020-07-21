# posh
Powershell scripts

iex ('$module="k8s";$user="cortside";$repo="posh"'+(new-object net.webclient).DownloadString('https://raw.githubusercontent.com/PsModuleInstall/InstallFromGithub/master/install.ps1'))

Import-Module posh-k8s

