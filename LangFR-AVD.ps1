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
  # Locale
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Control Panel\International" -Name "LocaleName" -Value "fr-FR"
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Control Panel\International" -Name "Locale" -Value "0000040C"
  # Formats
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Control Panel\International" -Name "sShortDate" -Value "dd/MM/yyyy"
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Control Panel\International" -Name "sLongDate"  -Value "dddd d MMMM yyyy"
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Control Panel\International" -Name "sTimeFormat" -Value "HH:mm:ss"
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Control Panel\International" -Name "iFirstDayOfWeek" -Value "1"
  # Keyboard
  New-Item "Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" -Force | Out-Null
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Preload" -Name "1" -Value "0000040C"
  # Input method patches (Win11 24H2+ requirement)
  New-Item "Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Substitutes" -Force | Out-Null
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Keyboard Layout\Substitutes" -Name "00000409" -Value "0000040C"
  # UI Language
  New-Item "Registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop" -Force | Out-Null
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop" -Name "PreferredUILanguages" -Value "fr-FR"
  Set-ItemProperty "Registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop" -Name "PreferredUILanguagesPending" -Value "fr-FR"
  ## SYSTEM profile
  # Locale
  Set-ItemProperty "Registry::HKEY_USERS\S-1-5-18\Control Panel\International" -Name "LocaleName" -Value "fr-FR"
  Set-ItemProperty "Registry::HKEY_USERS\S-1-5-18\Control Panel\International" -Name "Locale" -Value "0000040C"
  # Keyboard
  New-Item "Registry::HKEY_USERS\S-1-5-18\Keyboard Layout\Preload" -Force | Out-Null
  Set-ItemProperty "Registry::HKEY_USERS\S-1-5-18\Keyboard Layout\Preload" -Name "1" -Value "0000040C"
  # Input method consistency (important for AVD)
  New-Item "Registry::HKEY_USERS\S-1-5-18\Keyboard Layout\Substitutes" -Force | Out-Null
  Set-ItemProperty "Registry::HKEY_USERS\S-1-5-18\Keyboard Layout\Substitutes" -Name "00000409" -Value "0000040C"
  # UI language
  New-Item "Registry::HKEY_USERS\S-1-5-18\Control Panel\Desktop" -Force | Out-Null
  Set-ItemProperty "Registry::HKEY_USERS\S-1-5-18\Control Panel\Desktop" -Name "PreferredUILanguages" -Value "fr-FR"
}
  # restart virtual machine to apply regional settings to current user. 
  Start-sleep -Seconds 40
  Restart-Computer
