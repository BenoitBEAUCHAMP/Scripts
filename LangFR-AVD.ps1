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
  $LangISO   = "FRA"
  $CountryCode = "33"
  $GeoId = "84"
  $TimeZone = "Romance Standard Time"
  $Locale = "0000040C"
  $CurrencySymbol = "€"
  $MeasureSystem = "0"    # 0 = métrique
  $DateShort = "dd/MM/yyyy"
  $DateLong  = "dddd d MMMM yyyy"
  $TimeShort = "HH:mm"
  $TimeLong  = "HH:mm:ss"
  $YearMonth = "MMMM yyyy"
  $idigits = "2"

  
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
  $LangList[0].Handwriting = "fr-FR"
  Set-WinUserLanguageList $LangList -Force
  # --- 2. Exporter les clés HKCU nécessaires ---
  $TempDir  = "C:\Temp\LangPack"
  $TempIntl = Join-Path $TempDir "Intl.reg"
  $TempKbd  = Join-Path $TempDir "Keyboard.reg"
  New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
  reg export "HKCU\Control Panel\International" $TempIntl /y > $null 2>&1
  reg export "HKCU\Keyboard Layout" $TempKbd /y > $null 2>&1
  # --- 3. Appliquer au profil par défaut (nouveaux utilisateurs) ---
  $DefaultNtUser = "C:\Users\Default\NTUSER.DAT"
  $MountPoint = "HKU\TempDefault"
  reg load HKU\TempDefault $DefaultNtUser > $null 2>&1
  # Importer les clés exportées
  reg import $TempIntl /reg:HKU\TempDefault > $null 2>&1
  reg import $TempKbd /reg:HKU\TempDefault > $null 2>&1
  # Créer les clés manquantes
  reg add "HKU\TempDefault\Control Panel\International\Geo" /f
  reg add "HKU\TempDefault\Control Panel\International\User Profile" /f
  reg add "HKU\TempDefault\Control Panel\International" /f
  # Ajouter les valeurs pour Geo et Languages
  reg add "HKU\TempDefault\Control Panel\International\Geo" /v Name /t REG_SZ /d FR /f
  reg add "HKU\TempDefault\Control Panel\International\Geo" /v Nation /t REG_SZ /d $GeoId /f
  reg add "HKU\TempDefault\Control Panel\International\User Profile" /v Languages /t REG_MULTI_SZ /d $Language /f
  # --- Ajouter les valeurs du format régional complet ---
  # Supprimer sous-clé en-US si existante
    if (Test-Path "Registry::HKU\TempDefault\Control Panel\International\User Profile\en-US") {
        Remove-Item "Registry::HKU\TempDefault\Control Panel\International\User Profile\en-US" -Recurse -Force
    }
    # Créer fr-FR
    if (!(Test-Path "Registry::HKU\TempDefault\Control Panel\International\User Profile\fr-FR")) {
        New-Item -Path "Registry::HKU\TempDefault\Control Panel\International\User Profile\fr-FR" -Force
    }
    # Insérer les deux valeurs obligatoires
    reg add "HKU\TempDefault\Control Panel\International\User Profile\fr-FR" /v "040C:0000040C" /t REG_DWORD /d 1 /f
    reg add "HKU\TempDefault\Control Panel\International\User Profile\fr-FR" /v CachedLanguageName /t REG_SZ /d "@Winlangdb.dll,-1165" /f
  reg add "HKU\TempDefault\Control Panel\International" /v iCountry /t REG_SZ /d $CountryCode /f
  reg add "HKU\TempDefault\Control Panel\International" /v iCurrDigits /t REG_SZ /d $idigits /f
  reg add "HKU\TempDefault\Control Panel\International" /v Locale /t REG_SZ /d $Locale /f
  reg add "HKU\TempDefault\Control Panel\International" /v LocaleName /t REG_SZ /d $Language /f
  reg add "HKU\TempDefault\Control Panel\International" /v sLanguage /t REG_SZ /d $LangISO /f
  reg add "HKU\TempDefault\Control Panel\International" /v sShortDate /t REG_SZ /d $DateShort /f
  reg add "HKU\TempDefault\Control Panel\International" /v sShortTime /t REG_SZ /d $TimeShort /f
  reg add "HKU\TempDefault\Control Panel\International" /v sLongDate /t REG_SZ /d $DateLong /f
  reg add "HKU\TempDefault\Control Panel\International" /v sTimeFormat /t REG_SZ /d $TimeLong /f
  reg add "HKU\TempDefault\Control Panel\International" /v sYearMonth /t REG_SZ /d $YearMonth /f
  reg add "HKU\TempDefault\Control Panel\International" /v sCurrency /t REG_SZ /d $CurrencySymbol /f
  reg add "HKU\TempDefault\Control Panel\International" /v iMeasure /t REG_SZ /d $MeasureSystem /f

  reg unload HKU\TempDefault > $null 2>&1
  # --- 4. Nettoyage ---
  Remove-Item $TempDir -Recurse -Force
}
  # restart virtual machine to apply regional settings to current user. 
  Start-sleep -Seconds 40
