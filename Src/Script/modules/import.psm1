function ImportTemaLag(){
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [System.Data.DataRow]
        $Row
    )   
    # Directory to extract to
    $ExtractDir = "$PSScriptRoot\..\$($MyCfg.IMPORT.ExtractDir)"
    If(!(test-path $ExtractDir))
    {
        Write-Log -Message "Missing: $ExtractDir so I'll create it" -Level "Debug" | Out-Null
        New-Item -ItemType Directory -Force -Path $ExtractDir| Out-Null
    }
    # Get filename to download as    
    $outputFile = Split-Path $Row[2] -leaf
    $outputFile = "$ExtractDir\$outputfile"
    # Download the file if needed    
    if ($($Row[2]).StartsWith("fil:"))
    {
        $outputFile = $($Row[2]).Substring(4)        
        Write-Log -Message "Local path detected as: $outputFile"  -Level "Info" | Out-Null        
        $outpath = [System.IO.Path]::GetDirectoryName($outputFile)      
    }
    else
    {        
        Write-Log -Message "Internet link detected as  $($Row[2])" -Level "Info" | Out-Null       
        DownloadTemaLag -Url $($Row[2]) -OutputFile $outputFile -SourceUsr $($Row[6]) -ID $($Row[0])
        Unzip -zipfile $outputFile
        $ExtractDir = "$PSScriptRoot\..\$($MyCfg.IMPORT.ExtractDir)"
        $outpath = $ExtractDir + "\" + [io.path]::GetFileNameWithoutExtension($outputFile)
    }
    if (Test-Path $outpath)
    {            
        $returnVal = (TemaToDB -Folder $outpath -Row $Row)        
        if (!$returnVal)
        {                        
            $fejlTekst = "Downloaded fil: '{0}' for temalag: '{1}' indeholdte ingen filer" -f $Row[3], $Row[1]
            LogEntryToDatabase -TEMAMETADATAID $Row[0] -FEJLKODE -1 -FEJLTEKST $fejlTekst
        }
        else
        {     
            if ($MyCfg.IMPORT.Cleanup)
            {
                # We need to cleanup ExtractDir
                Write-Log -Message "Deleting $outputFile" -Level "Warn" | Out-Null
                Remove-Item -Path $outputFile
                Remove-Item -Recurse -Force $outpath
                $fejlTekst = "Downloaded fil: '{0}' for temalag: '{1}' slettet fra Temp dir" -f $Row[3], $Row[1]
                LogEntryToDatabase -TEMAMETADATAID $Row[0] -FEJLKODE 0 -FEJLTEKST $fejlTekst
            }
        }
    }
    else
    {
        Write-Log -Message "Kunne ikke finde $outpath" -Level "Warn"|Out-Null
        $temalag.Remove($Row[1])
    }
}


function Unzip
{
    param([string]$zipfile)
    $ExtractDir = "$PSScriptRoot\..\$($MyCfg.IMPORT.ExtractDir)"
    $outpath = $ExtractDir + "\" + [io.path]::GetFileNameWithoutExtension($zipfile)
    Write-Log -Message "Extracting $zipfile to $outpath" -Level "Debug"| Out-Null
    Expand-Archive $zipfile -DestinationPath $outpath -Force
    
}

function DownloadTemaLag(){
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $Url,
        [Parameter(Mandatory=$True)]
        [String]
        $OutputFile,
        [Parameter(Mandatory=$False)]
        [String]
        $SourceUsr,
        [Parameter(Mandatory=$True)]
        [String]
        $ID
    )
    Write-Log -Message "Downloading: $Url to $OutputFile and authenticate as user: $SourceUsr" -Level "Debug" | Out-Null
    # If SourceUsr is specified, we need to authenticate
    if ($SourceUsr)
    {
        # Get Pwd from database as a secure string
        $password = (GetPwd -ID $ID)
        $Cred = New-Object System.Management.Automation.PSCredential($SourceUsr, $password)    
            # Download the file
        try
        {
            Invoke-WebRequest -Uri $Url -OutFile $OutputFile -Credential $Cred
            Write-Log -Message "File downloaded" -Level "Debug" | Out-Null        
        }
        catch [Exception]{
            Write-Log -Message "Fatal error downloading Temalag:  $_.Exception.Message" -Level "Fatal" | Out-Null
        }            
    }
    else
    {                
        # Download the file
        try
        {
            Invoke-WebRequest -Uri $Url -OutFile $OutputFile
            Write-Log -Message "File downloaded" -Level "Debug" | Out-Null        
        }
        catch [Exception]{
            Write-Log -Message "Fatal error downloading Temalag:  $_.Exception.Message" -Level "Fatal" | Out-Null
        }
    }
}
    

Export-ModuleMember -Function ImportTemaLag
