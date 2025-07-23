$system = Get-WmiObject Win32_OperatingSystem | Select-Object OSArchitecture
$mountResult = Mount-DiskImage -ImagePath "C:/temp/lang.iso" -StorageType ISO -PassThru
$driveLetter = ($mountResult | Get-Volume).DriveLetter
if (($system.OSArchitecture -eq "64 bits") -or ($system.OSArchitecture -eq "64-bits")) {
    Dism /online /Add-Package /PackagePath:${driveLetter}:/LanguagesAndOptionalFeatures/Microsoft-Windows-Server-Language-Pack_x64_fr-fr.cab
}
else {
    Write-Output "OS Sytem non pris en charge : pas 64bits"
}
Dismount-DiskImage -ImagePath "C:/temp/lang.iso"