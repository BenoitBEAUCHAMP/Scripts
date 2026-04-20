Function Remove-WDOTWindowsMediaPlayer
{
    [CmdletBinding(SupportsShouldProcess)]
    Param ()

    Begin
    {
        Write-Verbose "Entering Function '$($MyInvocation.MyCommand.Name)'"
    }

    Process
    {
        try
        {
            Write-EventLog -EventId 10 -Message "[Windows Optimize] Disable / Remove Windows Media Player" -LogName 'WDOT' -Source 'WindowsMediaPlayer' -EntryType Information
            Write-Host "[Windows Optimize] Disable / Remove Windows Media Player" -ForegroundColor Cyan
            if ($PSCmdlet.ShouldProcess('WindowsMediaPlayer','Disable feature')) {
             try {
              $null = Disable-WindowsOptionalFeature -Online -FeatureName WindowsMediaPlayer -NoRestart -ErrorAction Stop
             } catch {
              Write-Warning -Message "Failed to disable WindowsMediaPlayer feature because $($_.Exception.Message)"
             }
            }
            Get-WindowsPackage -Online -PackageName "*Windows-mediaplayer*" |
            ForEach-Object {
                Write-EventLog -EventId 10 -Message "Removing $($_.PackageName)" -LogName 'WDOT' -Source 'WindowsMediaPlayer' -EntryType Information
                $p = $_
                if ($PSCmdlet.ShouldProcess("$($_.PackageName)",'Remove package')) {
                 try {
                  $null = Remove-WindowsPackage -PackageName $_.PackageName -Online -ErrorAction Stop -NoRestart
                 } catch {
                  Write-Warning -Message "Failed to remove package $($p.PackageName) because $($_.Exception.Message)"
                 }
                }
            }
        }
        catch
        {
            Write-EventLog -EventId 110 -Message "Disabling / Removing Windows Media Player - $($_.Exception.Message)" -LogName 'WDOT' -Source 'WindowsMediaPlayer' -EntryType Error
        }
    }

    End
    {
        Write-Verbose "Exiting Function '$($MyInvocation.MyCommand.Name)'"
    }
}