#variables
$regionalsettingsURL = "https://raw.githubusercontent.com/BenoitBEAUCHAMP/Scripts/refs/heads/main/FRRegion.xml"
$RegionalSettings = "C:\Region.xml"
$Language = "fr-FR"
$GeoId = "84"
$TimeZone = "Romance Standard Time"

#LanguagePack Suisse
Install-Language $Language

#downdload regional settings file
$webclient = New-Object System.Net.WebClient
$webclient.DownloadFile($regionalsettingsURL,$RegionalSettings)

#LanguagePack USA
unInstall-Language "en-US"
Start-sleep -Seconds 120

# Set languages/culture. Not needed perse.
Set-WinSystemLocale $Language
Set-WinUserLanguageList -LanguageList $Language -Force
Set-Culture -CultureInfo $Language
Set-WinHomeLocation -GeoId $GeoId 
Set-TimeZone -id $TimeZone

# Set Locale, language etc. 
& $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""

# restart virtual machine to apply regional settings to current user. 
Start-sleep -Seconds 40
Restart-Computer
