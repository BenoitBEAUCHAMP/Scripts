function Remove-WDOTRemoveLegacyIE
{
    [CmdletBinding(SupportsShouldProcess)]

    Param
    (

    )

    Begin
    {
        Write-Verbose "Entering Function '$($MyInvocation.MyCommand.Name)'"
    }
    Process
    {
        Write-EventLog -EventId 80 -Message "Remove Legacy Internet Explorer" -LogName 'WDOT' -Source 'AdvancedOptimizations' -EntryType Information
        Write-Host "[Windows Advanced Optimize] Remove Legacy Internet Explorer" -ForegroundColor Cyan
        Get-WindowsCapability -Online | Where-Object { $_.Name -Like "*Browser.Internet*" } |
        Foreach-Object {
         $c = $_
         if ($PSCmdlet.ShouldProcess($c.Name,'Remove Capability')) {
          try {
           $c | Remove-WindowsCapability -Online -ErrorAction Stop
          } catch {
           Write-Warning -Message "Failed to remove capability $($c.Name) because $($_.Exception.Message)"
          }
         }
        }
    }
    End
    {
        Write-Verbose "Exiting Function '$($MyInvocation.MyCommand.Name)'"
    }
}
