$Build = [System.Environment]::OSVersion.Version.Build
$Mode = "Legacy"
if ($Build -lt 26100) {
    Write-Host "Windows 11 <= 23H2 detected. Running Legacy configuration." -ForegroundColor Green
    $Mode = "Legacy"
}
else {
    Write-Host "Windows 11 24H2+ detected. Running Modern configuration." -ForegroundColor Yellow
    $Mode = "Modern"
}

  #variables
  $regionalsettingsURL = "https://raw.githubusercontent.com/BenoitBEAUCHAMP/Scripts/refs/heads/main/FRRegion.xml"
  $RegionalSettings = "C:\Region.xml"
  $Language = "fr-FR"
  $GeoId = "84"
  $TimeZone = "Romance Standard Time"
  $Locale = "0000040C"   # FR keyboard
  
  #LanguagePack FR
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

if ($Mode -eq "Legacy") {
  # Set Locale, language etc. 
  & $env:SystemRoot\System32\control.exe "intl.cpl,,/f:`"$RegionalSettings`""
}
if ($Mode -eq "Modern") {
  $LangList = New-WinUserLanguageList $Language
  $LangList[0].InputMethodTips.Clear()
  $LangList[0].InputMethodTips.Add("040C:$Locale")
  Set-WinUserLanguageList $LangList -Force
  Set-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Control Panel\International" -Name "LocaleName" -Value $Language
  New-Item -Path "Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" -Force | Out-Null
  Set-ItemProperty -Path "Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" -Name "1" -Value $Locale
  Set-ItemProperty -Path "Registry::HKEY_USERS\S-1-5-18\Control Panel\International" -Name "LocaleName" -Value $Language
  New-Item -Path "Registry::HKEY_USERS\S-1-5-18\Keyboard Layout\Preload" -Force | Out-Null
  Set-ItemProperty -Path "Registry::HKEY_USERS\S-1-5-18\Keyboard Layout\Preload" -Name "1" -Value $Locale
}
  # restart virtual machine to apply regional settings to current user. 
  Start-sleep -Seconds 40
  Restart-Computer
