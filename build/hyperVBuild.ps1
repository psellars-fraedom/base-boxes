param (
  [string]$Action="default",
  [string]$version
)
$here = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$psakeDir = (dir $env:ChocolateyInstall\lib\psake*)
if ($psakeDir.length -gt 0) {
  $psakeDir = $psakeDir[-1]
}
."$psakeDir\tools\psake.ps1" "$here/psakeHyperVBuild.ps1" $Action -ScriptPath $psakeDir\tools -parameters $PSBoundParameters
