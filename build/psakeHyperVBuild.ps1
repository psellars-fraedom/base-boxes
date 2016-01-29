$psake.use_exit_on_error = $true
Properties {
   $version 
   $box = $baseBox
   $baseDir = $psake.build_script_dir
   $repoBaseDir = Split-Path $baseDir -parent
}

Task default -Depends PackageHyperV 

Task Init {
  $versionFile = Join-Path $repoBaseDir VERSION
  Assert (Test-Path $versionFile) "Missing VERSION file. Please ensure the VERSION file exists"
  $script:version = Get-Content $versionFile
  Assert ($script:version -ne $null) "Version should be set. Please ensure the version is set in the VERSION file"
  Write-Host "Operating on $box version $script:version"
}

Task PrepareHyperV -Depends Init {
  $vmPath = "$repoBaseDir\output-hyper-v\Virtual Machines\vm.xml"
  [xml]$vmXml = Get-Content $vmPath
  $vmXml.configuration.properties.name.'#text' = '81Update'
  $vmXml.Save($vmPath)

  $vboxDisk = Resolve-Path("$repoBaseDir\output-virtualbox-iso\*.vmdk")
  $hyperVDir = "$repoBaseDir\output-hyper-v\Virtual Hard Disks"
  if(!(Test-Path $hyperVDir)) { mkdir $hyperVDir }
  $hyperVDisk = Join-Path $hypervDir 'disk.vhd'
  if(Test-Path $hyperVDisk) { Remove-Item $hyperVDisk -Force }
  $hyperVVagrantFile = "$repoBaseDir\output-hyper-v\Vagrantfile"
  if(Test-Path %hyperVVagrantFile) { Remove-Item $hyperVVagrantFile -Force }
  Copy-Item (Join-Path $repoBaseDir template\vagrantfile-win81x64-enterprise.tpl) $hyperVVagrantFile
}

Task ConvertToVHD -Depends PrepareHyperV {
  $vboxDisk = Resolve-Path "$repoBaseDir\output-virtualbox-iso\*.vmdk"
  $hyperVDir = "$repoBaseDir\output-hyper-v\Virtual Hard Disks"
  $hyperVDisk = Join-Path $hyperVDir 'disk.vhd'
  ."$env:ProgramFiles\oracle\VirtualBox\VBoxManage.exe" clonehd $vboxDisk $hyperVDisk --format vhd
}

Task PackageHyperV -Depends ConvertToVHD {
  ."$env:chocolateyInstall\tools\7za.exe" a -ttar (Join-Path $repoBaseDir "box\hyper-v-tar\$box-chef-$script:version.tar") (Join-Path $repoBaseDir "output-hyper-v\*")
  ."$env:chocolateyInstall\tools\7za.exe" a -tgzip (Join-Path $repoBaseDir "box\hyper-v\$box-chef-$script:version.box") (Join-Path $repoBaseDir "box\hyper-v-tar\$box-chef-$script:version.tar")
}
