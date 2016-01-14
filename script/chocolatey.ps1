$chocoExePath = 'C:\ProgramData\Chocolatey\bin'

if ($($env:Path).ToLower().Contains($($chocoExePath).ToLower())) {
	echo "Chocolatey found in PATH, skipping install..."
	Exit
}
