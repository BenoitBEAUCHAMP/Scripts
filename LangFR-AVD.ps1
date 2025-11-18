$Build = [System.Environment]::OSVersion.Version.Build
if ($Build -lt 26100) {
    Write-Host "Windows 11 <= 23H2 detected. Running Legacy configuration." -ForegroundColor Green
    $Mode = "Legacy"
}
else {
    Write-Host "Windows 11 24H2+ detected. Running Modern configuration." -ForegroundColor Yellow
    $Mode = "Modern"
}

if ($Mode -eq "Legacy") {
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
}
if ($Mode -eq "Modern") {

    $Language = "fr-FR"
    $GeoId = 84
    $TimeZone = "Romance Standard Time"

    # New mandatory parameter for 24H2+
    Install-Language -Language $Language -CopyToSystem -Force

    # Remove US language
    Uninstall-Language "en-US"
    Start-Sleep -Seconds 60

    # New recommended Microsoft method (24H2+)
    Set-WinSystemLocale -SystemLocale $Language
    Set-WinHomeLocation -GeoId $GeoId
    Set-TimeZone -Id $TimeZone

    # Apply full language pack to shell + login UI
    Dism /Online /Set-Lang:$Language
    Dism /Online /Set-SKUIntlDefaults:$Language

    # Override UI language properly
    Set-WinUILanguageOverride -Language $Language

    # User language list
    $LangList = New-WinUserLanguageList $Language
    Set-WinUserLanguageList $LangList -Force

    # Culture
    Set-Culture $Language

    # Reboot required twice in 24H2+
    Restart-Computer -Force
}
