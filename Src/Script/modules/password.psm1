function CreateAESKey{
    [CmdletBinding()]
    Param(
    )
    try 
    {   
        # If key file already exists, then skip
        if (Test-Path "$PSScriptRoot\..\config\aes.key")
        {
            Write-Log -Message "AES File already existed" -Level "Fatal"|Out-Null            
            return $false
        }
        else
        {
            # Create AES Key      
            $key = New-Object Byte[] 32
            [Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($key)
            $key | out-file $("$PSScriptRoot\..\config\aes.key")
            return $true
        }                                  
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null    
        return $false    
    }
}

function SetPwd{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $ID,
        [Parameter(Mandatory=$True)]
        [string]
        $Pwd
    )
    try 
    {        
        try 
        {
            # Get AES Key
            if (Test-Path "$PSScriptRoot\..\config\aes.key")
            {
                $key = Get-Content "$PSScriptRoot\..\config\aes.key"  
                $password = $Pwd | ConvertTo-SecureString -AsPlainText -Force
                $password = $password| ConvertFrom-SecureString -key $Key
                # Call database module to stamp into database
                SetSecurePwd -ID $ID -Pwd $password
            }
            else
            {
                Write-Log -Message "Make sure this isn't running on another PC as well, and if so, copy AES key from that" -Level Fatal|Out-Null
                Write-Log -Message "If not so, start this with '-mode CreateAESKey'" -Level Fatal|Out-Null
                throw [System.IO.FileNotFoundException] "$PSScriptRoot\..\config\aes.key not found."
                Exit-PSHostProcess
            }
        }
        catch [Exception]
        {
            $e = $_.Exception
            $line = $_.InvocationInfo.ScriptLineNumber
            $msg = $e.Message            
            Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
            # Exit everything here
            Exit 1            
        }
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message        
        Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
    }
}

function GetPwd{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $ID
    )
    try 
    {        
        try 
        {
            # Get AES Key
            if (Test-Path "$PSScriptRoot\..\config\aes.key")
            {
                $key = Get-Content "$PSScriptRoot\..\config\aes.key" 
                $Pwd = (GetSecurePwd -ID $ID)[2]
                $password = $Pwd | ConvertTo-SecureString -Key $key
                return $password                
            }
            else
            {
                Write-Log -Message "Make sure this isn't running on another PC as well, and if so, copy AES key from that" -Level Fatal|Out-Null
                Write-Log -Message "If not so, start this with '-mode CreateAESKey'" -Level Fatal|Out-Null
                throw [System.IO.FileNotFoundException] "$PSScriptRoot\..\config\aes.key not found."
                Exit-PSHostProcess
            }
        }
        catch [Exception]
        {
            $e = $_.Exception
            $line = $_.InvocationInfo.ScriptLineNumber
            $msg = $e.Message            
            Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
            # Exit everything here
            Exit 1            
        }
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message        
        Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
    }
}

Export-ModuleMember -Function "SetPwd"
Export-ModuleMember -Function "GetPwd"
Export-ModuleMember -Function "CreateAESKey"
