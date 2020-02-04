


function TestDB{        
    Write-Log -Message "Testing DB connection" -Level "INFO" | Out-Null
    try{        
        $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $($MyCfg.SQL.ConnectionString)    
        $sqlConnection.Open()
        $true
        Write-Log -Message "DB connection OK" -Level "INFO" | Out-Null
    } 
    catch [Exception]
    {
        Write-Log -Message "DB connection ERROR:  $_.Exception.Message" -Level "FATAL" | Out-Null
        $false
    }
    finally
    {
        $sqlConnection.Close()        
    }
}

function executeSP{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $SP
    )
    try{
        $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
        $SqlConnection.ConnectionString = $($MyCfg.SQL.ConnectionString) 
        $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
        $SqlCmd.CommandText = $SP
        $SqlCmd.Connection = $SqlConnection
        $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
        $SqlAdapter.SelectCommand = $SqlCmd
        $DataSet = New-Object System.Data.DataSet        
        $SqlAdapter.Fill($DataSet)   
        #$DataSet.Tables[0]                
        return, $DataSet
    }
    catch [Exception]
    {
        Write-Log -Message "Fatal error in executing SP named $SP : $_.Exception.Message" -Level "FATAL" | Out-Null
    }
    finally{
        $SqlConnection.Close()
    }
}

function GetTemaLagToUpdate()
{
    $ds = executeSP -SP dbo.spPSGetTemalagToUpdate        
    return, $ds
}

function GetSecurePwd{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $ID
    )
    try 
    {    
        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = $($MyCfg.SQL.ConnectionString)         
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $scon
        $cmd.CommandTimeout = 0
        $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
        $cmd.CommandText = "PROD.spGetSourcePwd"
        [guid]$Guid = [System.guid]::New($ID)
        $cmd.Parameters.AddWithValue("@TemaMetaDataID", $Guid)
        $paramReturn = $cmd.Parameters.Add("@pwd", "")        
        $paramReturn.Direction = [System.Data.ParameterDirection]::Output
        $paramReturn.Size = 1024
        try
        {
            $scon.Open()            
            $cmd.ExecuteNonQuery()            
        }
        catch [Exception]
        {
            $e = $_.Exception
            $line = $_.InvocationInfo.ScriptLineNumber
            $msg = $e.Message
            Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
            Write-Log -Message $e -Level "Fatal"|Out-Null            
        }
        finally
        {
            $scon.Dispose()
            $cmd.Dispose()
        }
        return $paramReturn.Value
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null        
    }  
}

function SetSecurePwd{
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
        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = $($MyCfg.SQL.ConnectionString)         
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $scon
        $cmd.CommandTimeout = 0
        $cmd.CommandType = [System.Data.CommandType]::StoredProcedure
        $cmd.CommandText = "PROD.spSetSourcePwd"
        [guid]$Guid = [System.guid]::New($ID)
        $cmd.Parameters.AddWithValue("@TemaMetaDataID", $Guid) |Out-Null  
        $cmd.Parameters.AddWithValue("@pwd", $pwd) | Out-Null
        try
        {
            $scon.Open()            
            $cmd.ExecuteNonQuery()            
        }
        catch [Exception]
        {
            $e = $_.Exception
            $line = $_.InvocationInfo.ScriptLineNumber
            $msg = $e.Message
            Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
            Write-Log -Message $e -Level "Fatal"|Out-Null            
        }
        finally
        {
            $scon.Dispose()
            $cmd.Dispose()
        }
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null        
    }  
}

function MoveToProdScheme{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $TableName
    )


    $scon = New-Object System.Data.SqlClient.SqlConnection
    $scon.ConnectionString = $($MyCfg.SQL.ConnectionString) 
    
    $cmd = New-Object System.Data.SqlClient.SqlCommand
    $cmd.Connection = $scon
    $cmd.CommandTimeout = 0         

    $cmd.CommandText = "EXEC dbo.spPSMoveTabelToProd @TableName"
    $cmd.Parameters.AddWithValue("@TableName", $TableName)|Out-Null    
    [bool] $success = $false
    try
    {
        $scon.Open()
        $cmd.ExecuteNonQuery() | Out-Null
        $success = $True
    }
    catch [Exception]
    {
        Write-Log -Message $_.Exception.Message -Level "Fatal" | Out-Null        
    }
    finally
    {
        $scon.Dispose()
        $cmd.Dispose()        
    }
    return $success
}

function Update_TMD_WithUpdateTime{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $ID
    )
    try 
    {    
        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = $($MyCfg.SQL.ConnectionString)         
        $cmd = New-Object System.Data.SqlClient.SqlCommand
        $cmd.Connection = $scon
        $cmd.CommandTimeout = 0
        $cmd.CommandText = "EXEC dbo.spPSUpdate_TMD_WithUpdateTime @ID"
        [guid]$Guid = [System.guid]::New($ID)
        $cmd.Parameters.AddWithValue("@ID", $Guid)|Out-Null        
        try
        {
            $scon.Open()
            $cmd.ExecuteNonQuery() | Out-Null
        }
        catch [Exception]
        {
            $e = $_.Exception
            $line = $_.InvocationInfo.ScriptLineNumber
            $msg = $e.Message
            Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
            Write-Log -Message $e -Level "Fatal"|Out-Null            
        }
        finally
        {
            $scon.Dispose()
            $cmd.Dispose()
        }
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null        
    }    

}

function LogEntryToDatabase{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]    
        [string]    
        $TEMAMETADATAID,
        [Parameter(Mandatory=$True)]
        [int32]
        $FEJLKODE,
        [Parameter(Mandatory=$True)]  
        [string]      
        $FEJLTEKST        
    )
    $OPDATERETAF = "PowerShell"
    $scon = New-Object System.Data.SqlClient.SqlConnection
    $scon.ConnectionString = $($MyCfg.SQL.ConnectionString)     
    $cmd = New-Object System.Data.SqlClient.SqlCommand
    $cmd.Connection = $scon
    $cmd.CommandTimeout = 0

    [guid]$Guid = [System.guid]::New($TEMAMETADATAID)
    $cmd.Parameters.AddWithValue("@TEMAMETADATAID", $Guid)|Out-Null
    $cmd.Parameters.AddWithValue("@FEJLKODE", $FEJLKODE)|Out-Null
    $cmd.Parameters.AddWithValue("@FEJLTEKST", $FEJLTEKST)|Out-Null
    $cmd.Parameters.AddWithValue("@OPDATERETAF", $OPDATERETAF)|Out-Null    
    try 
    {
        $cmd.CommandText = "EXEC dbo.spPSLogEntry @TEMAMETADATAID, @FEJLKODE, @FEJLTEKST, @OPDATERETAF"
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null      
    }
    try
    {
        $scon.Open()
        $cmd.ExecuteNonQuery() | Out-Null
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var `"$msg`""  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null      
    }
    finally
    {
        $scon.Dispose()
        $cmd.Dispose()
    }
}

Export-ModuleMember -Function TestDB
Export-ModuleMember -Function GetTemaLagToUpdate
Export-ModuleMember -Function MoveToProdScheme
Export-ModuleMember -Function Update_TMD_WithUpdateTime
Export-ModuleMember -Function LogEntryToDatabase
Export-ModuleMember -Function GetSecurePwd
Export-ModuleMember -Function SetSecurePwd