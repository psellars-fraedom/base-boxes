$psake.use_exit_on_error = $true
properties {
  $baseDir = $psake.build_script_dir
}

Task default -depends prepare-hyperv, convert-tohvd, package-hyperv

task prepare-hyperv {
  $vmPath = "$baseDir\hyper-v-output\Virtual Machines\vm.xml"
  [xml]$vmXml = Get-Content $vmPath
  $vmXml.configuration.properties.name.'#text' = '81Update'
  $vmXml.Save($vmPath)

  $vboxDisk = Resolve-Path("$baseDir\output-virtualbox-iso\*.vmdk")
  $hyperVDir = "$baseDir\hyper-v-output\Virtual Hard Disks"
  if(!(Test-Path $hyperVDir)) { mkdir $hyperVDir }
  $hyperVDisk = Join-Path $hypervDir 'disk.vhd'
  if(Test-Path $hyperVDisk) { Remove-Item $hyperVDisk -Force }
  $hyperVVagrantFile = "$baseDir\hyper-v-output\Vagrantfile"
  if(Test-Path %hyperVVagrantFile) { Remove-Item $hyperVVagrantFile -Force }
  Copy-Item (Join-Path $baseDir template\vagrantfile-win81x64-enterprise.tpl) $hyperVVagrantFile
}

task convert-tohvd {
  $vboxDisk = Resolve-Path "$baseDir\output-virtualbox-iso\*.vmdk"
  $hyperVDir = "$baseDir\hyper-v-output\Virtual Hard Disks"
  $hyperVDisk = Join-Path $hyperVDir 'disk.vhd'
  ."$env:ProgramFiles\oracle\VirtualBox\VBoxManage.exe" clonehd $vboxDisk $hyperVDisk --format vhd
}

task package-hyperv {
  ."$env:chocolateyInstall\tools\7za.exe" a -ttar (Join-Path $baseDir "package-hyper-v.tar") (Join-Path $baseDir "hyper-v-output\*")
  ."$env:chocolateyInstall\tools\7za.exe" a -tgzip (Join-Path $baseDir "package-hyper-v-0.1.0.box") (Join-Path $baseDir "package-hyper-v.tar")
}
