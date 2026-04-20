# =======================
# AVD Optimization Script
# =======================
#-- Chemin Shared Profils pour exclusion Defender
$CheminFsLogix = "\\storageaccount.file.core.windows.net\fslogix\"

#-- Dossiers à exclure de Defender
$paths = @(
"C:\Program Files\FSLogix\",
"C:\ProgramData\FSLogix\",
"C:\Program Files (x86)\Microsoft\Edge\",
"C:\Program Files\Microsoft\Edge\",
"C:\Program Files (x86)\Microsoft\EdgeWebView\",
"C:\Program Files\Microsoft Office\",
"C:\Program Files (x86)\Microsoft Office\"
)

#--- Check Droits Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Ce script doit être exécuté en mode ADMINISTRATEUR !" -ForegroundColor Red
    Write-Host "Clic droit sur PowerShell → 'Exécuter en tant qu’administrateur'" -ForegroundColor Yellow
    pause
    exit
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd C:\wdot

#-- Lancement Optimisation via WDOT
.\Windows_Optimization.ps1 -ConfigProfile "Production-VDI-W11_25H2" -Optimizations @("Services", "AppxPackages", "ScheduledTasks", "NetworkOptimizations") -AdvancedOptimizations @("Edge", "RemoveLegacyIE") -AcceptEULA #-Restart

#--- un petit coup de remove-ghosts - ca fait pas de mal ! Potentiellement ajouter une tâche planifiée -> 1 fois par mois afin d'avoir un environnement clean car peut entrainer du CPU sur WMI Provider Host (service Réseau)
.\removeGhosts.ps1 -Force

#-- Ajout des exclusions Defender
foreach ($p in $paths) {
    Add-MpPreference -ExclusionPath $p
}
Add-MpPreference -ExclusionExtension ".vhd"
Add-MpPreference -ExclusionExtension ".vhdx"
Add-MpPreference -ExclusionPath $CheminFsLogix
Add-MpPreference -ExclusionPath "C:\Users\*\AppData\Local\Temp\"
Add-MpPreference -ExclusionPath "C:\Temp\"

#-- redémarrage AVD
Write-Host ""
Write-Host "---"
Write-Host "Un redémarrage est nécessaire pour la prise en compte de l'optimisation !" -ForegroundColor Yellow
$reboot = Read-Host "-> Voulez-vous redémarrer maintenant ? (Y/N)"
if ($reboot -eq "Y") {
    Write-Host "Redémarrage dans 15 secondes..." -ForegroundColor Yellow
    shutdown /r /t 15
}
else {
    Write-Host "Pensez à redémarrer manuellement pour appliquer les changements." -ForegroundColor Yellow
}