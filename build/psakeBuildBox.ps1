# Base box psake build script
#
# 

Properties {
  $version = $null
  $box = $baseBox
  $baseDir = $psake.build_script_dir
}

FormatTaskName (("-"*25) + "[{0}]" + ("-"*25))

Task default -Depends BuildBox, PackageHyperVBox, VagrantBoxImport
Task ci -Depends BuildBox, PackageHyperVBox 

Task Init {
  Write-Host ""
  Assert ($box -ne $null) "Missing information about the base box to build. Please ensure you pass this information"
  Write-Host "Building $box"
  $versionFile = Join-Path (Split-Path $baseDir -parent) VERSION
  Assert (Test-Path $versionFile) "Missing VERSION file. Please ensure the VERSION file exists" 
  $script:version = Get-Content $versionFile 
  Assert ($script:version -ne $null) "Version should be set. Please ensure the version is set in the VERSION file"
  Write-Host "Operating on $box version $script:version"
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

Task BuildBox -Depends CheckSyntax {
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

Task PackageHyperVBox -Depends Init {
  $virtualBoxOutputDir = Join-Path (Split-Path $baseDir -parent) "output-virtualbox-iso"
  $virtualBoxOutputDiskFile = Join-Path $virtualBoxOutputDir ($box + "-disk1.vmdk")
  Assert (Test-Path $virtualBoxOutputDiskFile) "VirtualBox disk file does not exist. Please ensure you have built this box"
  Write-Host ""
  Write-Host "Packaging Hyper-V Box for $box version $script:version"
  Write-Host ""
  Exec {
    Invoke-psake psakeHyperVBuild.ps1
  }
}

Task GenerateBoxSHAs -Depends Init {
# TO-DO Add checks for file existence
  Write-Host ""
  Write-Host "Generating box SHAs..."
  $virtualBoxFile = Join-Path  (Split-Path $baseDir -parent) "box\virtualbox\$box-chef-$script:version.box"
  $hyperVBoxFile = Join-Path (Split-Path $baseDir -parent) "box\hyper-v\$box-chef-$script:version.box"
  $hashXMLFile = "generatedHash.xml"
  Exec {
    Write-Host "Generating VirtualBox SHA..."
    cmd /c fciv -add $virtualBoxFile -xml $hashXMLFile -sha1
    Write-Host "Generating Hyper-V SHA..."
    cmd /c fciv -add $hyperVBoxFile -xml $hashXMLFile -sha1
    $hashXML = [xml](Get-Content $hashXMLFile)
    $virtualBoxXML = $hashXML.FCIV.FILE_ENTRY | ? {$_.name -eq $virtualBoxFile} | Select SHA1
    $hyperVBoxXML = $hashXML.FCIV.FILE_ENTRY | ? {$_.name -eq $hyperVBoxFile} | Select SHA1
    $script:virtualBoxSHA = $virtualBoxXML.SHA1
    $script:hyperVBoxSHA = $hyperVBoxXML.SHA1
    Write-Host "SHAs..."
    Write-Host "VirtualBox  SHA: $script:virtualBoxSHA"
    Write-Host "Hyper-V Box SHA: $script:hyperVBoxSHA"
    Remove-Item $hashXMLFile
  }
  Write-Host ""
}

Task VagrantBoxImport -Depends GenerateBoxSHAs {
  $metadataFile = Join-Path (Split-Path $baseDir -parent) "test\metadata.json"
  $jsonContent = ConvertFrom-Json -InputObject (Gc $metadataFile -Raw)
  $providers = $jsonContent.versions.providers
  $providers[0].checksum = $script:virtualBoxSHA
  $providers[1].checksum = $script:hyperVBoxSHA
  $providers
  $jsonContent | ConvertTo-Json -depth 4 | Set-Content $metadataFile
  Write-Host ""
  Write-Host "Importing $box version $script:version into the local Vagrant instance"
  Write-Host ""
  Exec {
    Write-Host "Importing box for VirtualBox provider..."
    cmd /c vagrant box add --force --provider virtualbox $metadataFile 
    Write-Host "Importing box for Hyper-V provider..."
    cmd /c vagrant box add --force --provider hyperv $metadataFile
    cmd /c vagrant box list -i
  }
}
