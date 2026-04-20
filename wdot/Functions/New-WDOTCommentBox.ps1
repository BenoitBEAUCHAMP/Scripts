function New-WDOTCommentBox {
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.String])]
    Param(
    [Parameter()]
    [string]$titleText
    )
    Begin {
     $lines = $titleText.Split("`n")
     $output = "$("#"*70)`n"
     $output += "#$(" "*68)#`n"
    }
    Process {
     foreach ($line in $lines)
     {
        if ($line.Length -gt 65)
        {
            $line = $line.Substring(0, 66)
        }
        $line = $line.Trim()
        $lspaces = ([math]::Floor((68 - $line.trim().Length) / 2))
        $rspaces = (68 - $lspaces - $line.Length)
        $output += "#$(" "*$lspaces)$($line.trim())$(" "*$rspaces)#`n"

     }
    }
    End {
     $output += "#$(" "*68)#`n"
     $output += "$("#"*70)`n"
     if ($PSCmdlet.ShouldProcess($output,'return output')) {
      return $output
     }
    }
}