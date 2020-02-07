function SendErrorMail{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]
        $Line
    )
    # If we ain't going to send out infomail, then simply return
    If(!($MyCfg.SMTP.SendErrorMail))
    {
        return
    }
    try
    {
        # Get mail body from filesystem
        $body = Get-Content -Path $PSScriptRoot\..\config\$($MyCfg.SMTP.ErrorMailTemplate) -Raw -Encoding UTF8; # Get HTML text as one line
        # Get Log file name
        $logDir = "$PSScriptRoot\..\logs"
        $logFile = "$logDir\$($MyCfg.Logs.logFile)"
        # Build-up hash table with arguments
        $arguments = @{
            To = $($MyCfg.SMTP.EmailToCommaSeperated)
            From = $($MyCfg.SMTP.EmailFrom)
            Subject = $($MyCfg.SMTP.ErrorEmailSubject)
            Port = $($MyCfg.SMTP.SMTPPort)
            SmtpServer = $($MyCfg.SMTP.SMTPHost)
            Encoding = "UTF8"
            UseSSL = $($MyCfg.SMTP.SMTPHostUseSSL)
            Priority = "High"
            ErrorVariable = "Err"
            ErrorAction = "SilentlyContinue"
            Attachments = $logFile
        }
        # Send mail, and do inplace replacement of params
        # Note: Send-MailMessage fejl fanges IKKE af Try/Catch, så vi må rejse den selv        
        Send-MailMessage @arguments -BodyAsHtml ($body -f  $Line)        
        if($Err)
        {
            throw $Err        
        }

    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var '$msg'"  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null          
    }             
}

function SendInfoMail{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true)]
        [string]
        $startTime,
        [Parameter(Mandatory=$true)]
        [string]
        $endTime,
        [Parameter(Mandatory=$true)]
        [System.Collections.Generic.List[string]]
        $temalag
    )
    # If we ain't going to send out infomail, then simply return
    If(!($MyCfg.SMTP.SendInfoMail))
    {
        return
    }
    try
    {
        # Get mail body from filesystem
        $body = Get-Content -Path $PSScriptRoot\..\config\$($MyCfg.SMTP.InfoMailTemplate) -Raw -Encoding UTF8; # Get HTML text as one line
        # Build-up hash table with arguments
        $arguments = @{
            To = $($MyCfg.SMTP.EmailToCommaSeperated)
            From = $($MyCfg.SMTP.EmailFrom)
            Subject = $($MyCfg.SMTP.EmailSubject)
            Port = $($MyCfg.SMTP.SMTPPort)
            SmtpServer = $($MyCfg.SMTP.SMTPHost)
            Encoding = "UTF8"
            UseSSL = $($MyCfg.SMTP.SMTPHostUseSSL)
            Priority = "Normal"
            ErrorVariable = "Err"
            ErrorAction = "SilentlyContinue"
        }
        # Convert list into a string, with - as a separator
        $temalagAsStr =  [string]::join(" - ", $temalag)
        # Send mail, and do inplace replacement of params
        # Note: Send-MailMessage fejl fanges IKKE af Try/Catch, så vi må rejse den selv        
        Send-MailMessage @arguments -BodyAsHtml ($body -f  $startTime, $endTime, $temalagAsStr)
        if($Err)
        {
            throw $Err        
        }

    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var '$msg'"  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null          
    }             
}

function TestMail
{
    try
    {
        $retVal = $true

        # Get mail body from filesystem
        $body = "This is a test mail" # Get HTML text as one line
        # Build-up hash table with arguments
        $arguments = @{
            To = $($MyCfg.SMTP.EmailToCommaSeperated)
            From = $($MyCfg.SMTP.EmailFrom)
            Subject = $($MyCfg.SMTP.EmailSubject)
            Port = $($MyCfg.SMTP.SMTPPort)
            SmtpServer = $($MyCfg.SMTP.SMTPHost)
            Encoding = "UTF8"
            UseSSL = $($MyCfg.SMTP.SMTPHostUseSSL)
            Priority = "Normal"
            ErrorVariable = "Err"
            ErrorAction = "SilentlyContinue"
        }        
        # Send mail, and do inplace replacement of params
        # Note: Send-MailMessage fejl fanges IKKE af Try/Catch, så vi må rejse den selv        
        Send-MailMessage @arguments -BodyAsHtml ($body)
        if($Err)
        {
            throw $Err            
        }
        return $retVal
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var '$msg'"  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null  
        return $false        
    }      
}

Export-ModuleMember -Function "SendInfoMail"
Export-ModuleMember -Function "SendErrorMail"
Export-ModuleMember -Function "TestMail"