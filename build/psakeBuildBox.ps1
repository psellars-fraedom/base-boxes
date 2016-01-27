# Base box psake build script
#
# 

Properties {
  $version = $null
  $box = $baseBox
  $baseDir = $psake.build_script_dir
}

FormatTaskName (("-"*25) + "[{0}]" + ("-"*25))

Task default -Depends BuildBox 

Task Init {
  Write-Host ""
  Assert ($box -ne $null) "Missing information about the base box to build. Please ensure you pass this information"
  Write-Host "Building $box"
  $versionFile = Join-Path (Split-Path $baseDir -parent) VERSION
  Assert (Test-Path $versionFile) "Missing VERSION file. Please ensure the VERSION file exists" 
  $script:version = Get-Content $versionFile 
  Assert ($script:version -ne $null) "Version should be set. Please ensure the version is set in the VERSION file"
  Write-Host "Building version $script:version of the base box"
  Write-Host ""
}

Task CheckSyntax -Depends Init {
  $boxFile = "$box.json"
  $boxFileDir = Split-Path $baseDir -parent
  Assert (Test-Path (Join-Path $boxFileDir $boxFile)) "Box $box could not be found. Please ensure a Packer json file exists for this box"
  Write-Host ""
  Write-Host "Checking Packer syntax for $boxFile"
  Write-Host ""
  Set-Location $boxFileDir
  Exec {
    cmd /c packer validate -syntax-only $boxFile
    cmd /c packer validate $boxFile
  }
  Set-Location $PSScriptRoot
  Write-Host ""
}

Task BuildBox -Depends Init {
  $boxFile = "$box.json"
  $boxFileDir = Split-Path $baseDir -parent
  Write-Host ""
  Write-Host "Building $box version $script:version using Packer/VirtualBox"
  Write-Host ""
  Set-Location $boxFileDir
  Exec {
    cmd /c set PACKER_LOG=1 "&" packer build -force -machine-readable $boxFile 
  }
  Set-Location $PSScriptRoot
  Write-Host ""
}
