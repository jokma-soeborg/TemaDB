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
    # Download the file
    Write-Log -Message "Henter Temalag fra $($Row[2])" -Level "Info" | Out-Null
    DownloadTemaLag -Url $($Row[2]) -OutputFile $outputFile
    Unzip -zipfile $outputFile
    $ExtractDir = "$PSScriptRoot\..\$($MyCfg.IMPORT.ExtractDir)"
    $outpath = $ExtractDir + "\" + [io.path]::GetFileNameWithoutExtension($outputFile)
    $returnVal = TemaToDB -Folder $outpath -Row $Row
    if (!$returnVal)
    {
        $fejlTekst = "Downloaded fil: '{0}' for temalag: '{1}' indeholdte ingen filer" -f $Row[3], $Row[1]
        LogEntryToDatabase -TEMAMETADATAID $Row[0] -FEJLKODE -1 -FEJLTEKST $fejlTekst
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
        $OutputFile
    )
    Write-Log -Message "Downloading: $Url to $OutputFile" -Level "Debug" | Out-Null
    # Download the file
    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutputFile        
        Write-Log -Message "File downloaded" -Level "Debug" | Out-Null        
    }
    catch [Exception]{
        Write-Log -Message "Fatal error downloading Temalag:  $_.Exception.Message" -Level "Fatal" | Out-Null
    }
}
    

Export-ModuleMember -Function ImportTemaLag