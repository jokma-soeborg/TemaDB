function Write-Log{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $Message,

        [Parameter(Mandatory=$False)]
        [String]
        $Level = "DEBUG"
    )
    $callstack = Get-PSCallStack
    $CallLine = "[" + $callstack[1].Location + "]"
    

    # Create Log directory if it doesn't exists
    $logDir = "$PSScriptRoot\..\logs"
    If(!(test-path $logDir))
    {
        New-Item -ItemType Directory -Force -Path $logDir| Out-Null
    }
    $logFile = "$logDir\$($MyCfg.Logs.logFile)"    
    
    $Level = $Level.ToUpper()
    $levels = ("VERBOSE","DEBUG","INFO","WARN","ERROR","FATAL")
    $logLevelPos = [array]::IndexOf($levels, $MyCfg.Logs.logLevel)
    $levelPos = [array]::IndexOf($levels, $Level)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss:fff")    

    Reset-Log($logFile, $MyCfg.Logs.logSize, $MyCfg.Logs.logCount)    


    if ($logLevelPos -lt 0){
        Write-LogLine "$Stamp ERROR Wrong logLevel configuration [$logLevel]"
    }
    
    if ($levelPos -lt 0){
        Write-LogLine "$Stamp ERROR Wrong log level parameter [$Level]"
    }

    # if level parameter is wrong or configuration is wrong I still want to see the 
    # message in log
    if ($levelPos -lt $logLevelPos -and $levelPos -ge 0 -and $logLevelPos -ge 0){
        return
    }

    $Line = "$Stamp $Level $CallLine $Message"
    #Write-Host "$Stamp $Level $CallLine $Message"
    Write-LogLine $Line $exception     
}

Function Reset-Log 
{ 
    # function checks to see if file in question is larger than the paramater specified 
    # if it is it will roll a log and delete the oldes log if there are more than x logs. 
    param([string]$fileName, [int64]$filesize = 1mb , [int] $logcount = 5) 
     
    $logRollStatus = $true 
    if (-Not $filename)
    {
        $logRollStatus = $false
    }   
    elseif(test-path $filename) 
    { 
        $file = Get-ChildItem $filename 
        if((($file).length) -ige $filesize) #this starts the log roll 
        { 
            $fileDir = $file.Directory 
            #this gets the name of the file we started with 
            $fn = $file.name
            $files = Get-ChildItem $filedir | Where-Object{$_.name -like "$fn*"} | Sort-Object lastwritetime 
            #this gets the fullname of the file we started with 
            $filefullname = $file.fullname
            #$logcount +=1 #add one to the count as the base file is one more than the count 
            for ($i = ($files.count); $i -gt 0; $i--) 
            {  
                #[int]$fileNumber = ($f).name.Trim($file.name) #gets the current number of 
                # the file we are on 
                $files = Get-ChildItem $filedir | Where-Object{$_.name -like "$fn*"} | Sort-Object lastwritetime 
                $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq $i} 
                if ($operatingfile) 
                 {$operatingFilenumber = ($files | Where-Object{($_.name).trim($fn) -eq $i}).name.trim($fn)} 
                else 
                {$operatingFilenumber = $null} 
 
                if(($null -eq $operatingFilenumber) -and ($i -ne 1) -and ($i -lt $logcount)) 
                { 
                    $operatingFilenumber = $i 
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq ($i-1)} 
                    write-host "moving to $newfilename" 
                    move-item ($operatingFile.FullName) -Destination $newfilename -Force 
                } 
                elseif($i -ge $logcount) 
                { 
                    if($null -eq $operatingFilenumber) 
                    {  
                        $operatingFilenumber = $i - 1 
                        $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq $operatingFilenumber} 
                        
                    } 
                    write-host "deleting " ($operatingFile.FullName) 
                    remove-item ($operatingFile.FullName) -Force 
                } 
                elseif($i -eq 1) 
                { 
                    $operatingFilenumber = 1 
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    write-host "moving to $newfilename" 
                    move-item $filefullname -Destination $newfilename -Force 
                } 
                else 
                { 
                    $operatingFilenumber = $i +1  
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq ($i-1)} 
                    write-host "moving to $newfilename" 
                    move-item ($operatingFile.FullName) -Destination $newfilename -Force    
                } 
            } 
          } 
         else 
         { $logRollStatus = $false} 
    }
    else 
    { 
        $logrollStatus = $false 
    } 
    $LogRollStatus 
} 


Function Write-LogLine ($Line) {
    Add-Content $logFile -Value $Line
    if ($MyCfg.Logs.LogToConsole)
    {
        if ($Line -Match 'FATAL')
        {
            Write-Host $Line -ForegroundColor Red


        }
        else
        {
            Write-Host $Line       
        }        
    }
}

# to null to avoid output
$Null = @(
    Reset-Log -fileName $logFile -filesize $logSize -logcount $logCount
)

Export-ModuleMember -Function "Write-Log"