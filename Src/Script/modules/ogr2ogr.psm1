function TemaToDB{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $Folder,
        [Parameter(Mandatory=$True)]
        [System.Data.DataRow]
        $Row
    )   
    [bool] $success = $false     
    $fileNames = Get-ChildItem -Path $Folder -File -Recurse -Include *.tab,*.shp
    if (!$fileNames)
    {
        Write-Log -Message "$Folder indeholdte ingen filer"  -Level "Fatal"|Out-Null 
        return $success   
    }
    else
    {            
        foreach ($fileName in $fileNames)
        {
            $success = SendtoOGR -fileName $fileName -Row $Row   
            # Special case for kommunegrænser
            if ($fileName -match "KOMMUNE.shp")
            {
               break                
            }         
        }
        return $success        
    } 
}

function SendtoOGR{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $fileName,
        [Parameter(Mandatory=$True)]
        [System.Data.DataRow]
        $Row
    )

    # Get Table name
    $fileTable = [io.path]::GetFileNameWithoutExtension($fileName)
    $table = $Row[3]
    $GeomName = $Row[5]
    if ( $table -eq "Kommune")
    {
        if ($fileTable.ToLower() -ne  $table.ToLower())
        {
            Write-Log -Message "Theme: $table skipped, since not matching filename: $fileTable " -Level "Debug" | Out-Null
            return $false
        }
    }

    $SRid = $($MyCfg.GDAL.ForcedSRid)

    #Build launch string
    $binFolder = ("$PSScriptRoot\..\$($MyCfg.GDAL.NameOfOGR2OGRFolder)\bin").Replace("modules\..\","")    
    $exeFile = "$binFolder\gdal\apps\ogr2ogr.exe"    
    $params = "-progress -overwrite -t_srs EPSG:$SRid -preserve_fid -nln `"TEMP.$table`" -lco `"GEOM_TYPE=geometry`" -lco `"GEOM_NAME=$GeomName`" -lco `"OVERWRITE=YES`""
    
    # Set path
    $oldPath = $Env:Path
    $tmpPath = ";$binFolder;$binFolder\gdal\python\osgeo;$binFolder\proj6\apps;$binFolder\gdal\apps;$binFolder\ms\apps;$binFolder\gdal\csharp;$binFolder\ms\csharp;$binFolder\curl;"		

    $Env:Path += $tmpPath
    $Env:GDAL_DATA = "$binFolder\gdal-data"
    $Env:GDAL_DRIVER_PATH = "$binFolder\gdal\plugins"
    $Env:PROJ_LIB = "$binFolder\proj6\share" 

    #Arguments for OGR2OGR
    $Args = @"
    $params -f "MSSQLSpatial"
    $($MyCfg.GDAL.ConnectionStr)
    "$fileName"
"@

    [bool] $success = $false
    Write-Log -Message "Path to ogr2ogr: $exeFile" -Level "Verbose" | Out-Null
    Write-Log -Message "Arguments for ogr2ogr: $Args" -Level "Verbose" | Out-Null
    try 
    {
        Write-Log -Message "Importerer tabellen TEMP.$table til SQL Serveren" -Level "Info"| Out-Null
        $retval = (Start-Process -FilePath $exeFile -PassThru -Wait -NoNewWindow -ArgumentList $Args).ExitCode
       # $retval = 0
       # Write-Log "Ged123"
        if ($retval -ne 0)
        {
            Write-Log -Message "Fatal fejl da vi koerte OGR2OGR havde fejlkoden: $retval" -Level "Fatal"
            LogEntryToDatabase -TEMAMETADATAID $guid -FEJLKODE 1 -FEJLTEKST $retval
        }
        else
        {
            # It was a success, so needs to update log table as well as TemaMetaData  
            Write-Log -Message "Success med import af $table" -Level "Info"| Out-Null
            if (MoveToProdScheme -TableName $table)
            {
                Update_TMD_WithUpdateTime -ID $Row[0]
                LogEntryToDatabase -TEMAMETADATAID $Row[0] -FEJLKODE 0 -FEJLTEKST "$table importeret ok"
                $success = $True
            }
            else
            {
                LogEntryToDatabase -TEMAMETADATAID $Row[0] -FEJLKODE 1 -FEJLTEKST "$table ikke flyttet til Prod skema"    
            }
            
        }
    }
    catch [Exception]
    {
        $e = $_.Exception
        $line = $_.InvocationInfo.ScriptLineNumber
        $msg = $e.Message
        Write-Log -Message "Exception paa linie $line var $msg"  -Level "Fatal"|Out-Null
        Write-Log -Message $e -Level "Fatal"|Out-Null  
        LogEntryToDatabase -TEMAMETADATAID $guid -FEJLKODE 1 -FEJLTEKST $retval      
    }    
    # Reset path to old path
    $Env:Path = $oldPath   
    return $success
}


Export-ModuleMember -Function TemaToDB