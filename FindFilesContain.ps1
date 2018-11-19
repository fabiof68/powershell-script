
#$logLevel = "DEBUG"


Function write-resultFile {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $logfile
    )

    If($logfile) {
        Add-Content $logfile -Value $Message
    }
    Else {
        Write-Output $Message
    }
}




Function Write-ResultFile {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $Message,

    [Parameter(Mandatory=$False)]
    [string]
    $logfile
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    If($logfile) {
        Add-Content $logfile -Value $Line
    }
    Else {
        Write-Output $Line
    }
}

function ReadHost_WithDefault {
[CmdletBinding()]
    Param(
    [Parameter(Mandatory=$True)]
    [string]
    $PromptMessage,
        
    [Parameter(Mandatory=$False)]
    [string]
    $DefaultValue
    )


   if ($DefaultValue) {
    $EnteredValue = Read-Host -Prompt ($PromptMessage + " <" + $DefaultValue +"> is default (Enter to accept it)") 
   }
  else 
  {
    $EnteredValue = Read-Host -Prompt ($PromptMessage)
  }
  if (-not $EnteredValue)
  {
    $EnteredValue=$DefaultValue
  }
  
  return $EnteredValue
}


try
{

$ForegroundColor = "Yellow"

Clear-Host
Write-Host "" -ForegroundColor $ForegroundColor
Write-Host "========================================" -ForegroundColor $ForegroundColor
Write-Host "   SEARCH FOLDER FOR SPECIFIC CONTENT   " -ForegroundColor $ForegroundColor
Write-Host "========================================" -ForegroundColor $ForegroundColor
Write-Host "" -ForegroundColor $ForegroundColor
Write-Host "This script is for finding files having "-ForegroundColor $ForegroundColor
Write-Host "specifc content.   " -ForegroundColor $ForegroundColor
Write-Host "" -ForegroundColor $ForegroundColor
Write-Host "Created by Fabio Francesconi " -ForegroundColor $ForegroundColor
write-host "email(fabio@francesconionline.net" -ForegroundColor $ForegroundColor
Write-Host "========================================" -ForegroundColor $ForegroundColor




$logfileName = ((Get-Date).toString("yyyyMMddTHHmmss") + "_FindFilesContain_Results.txt")
$DefaultLogFolder =(Get-Item -Path ".\").FullName
$logfolder = ReadHost_WithDefault ('1) Please Input The Full Path Of The Folder Where To Save The Log File ') $DefaultLogFolder

If ($logfolder[-1] -notmatch ‘\\’)
{
$logfolder+=’\’
}
#If the Log directory does not exist it will be created

If(!(test-path $logfolder))
{
      New-Item -ItemType Directory -Force -Path $logfolder
}

$logfile = $logfolder + $logfileName
$WriteNoMatchedFile = ReadHost_WithDefault ('2) ADD FILE WITH NO MATCH TO LOG FILE? (Type TRUE if desire)  ') $FALSE
if ($WriteNoMatchedFile.ToUpper( ) -eq "TRUE" )
{ $WriteNoMatchedFile=$TRUE }
else
{ $WriteNoMatchedFile=$FALSE }

write-ResultFile ("Write No Matched File=" +$WriteNoMatchedFile) $logfile

$SearchFolderLocation = ReadHost_WithDefault ('3) Please Input The Full Path Of The Folder To Be Search')
$PatternToSearch =  ReadHost_WithDefault ( '4) Please Input The Text Being Searched')
$numberOfFileToBeSearched= Get-ChildItem $SearchFolderLocation -Recurse -File | Measure-Object | %{$_.Count}
$FileMatchingPatternCount = 0
write-ResultFile ("The Directory " + $SearchFolderLocation +" and related subdirectory will be searched for file containing -->" + $PatternToSearch +"<--" ) $logfile
$Files = Get-ChildItem $SearchFolderLocation -Recurse -File
$i = 0
write-ResultFile ("The Number Of File Being Searched are: " + $($Files.Count)) $logfile

write-ResultFile ("FILE NAME|CREATION DATE|MATCH STATUS " ) $logfile
$Files | ForEach-Object {
    Write-Progress -Activity "Counting Files file $($_.name)" -CurrentOperation "Collecting From Log Files..." -Status "File $i of $($Files.Count)" -PercentComplete (($i / $Files.Count) * 100)  
    if (Select-String -Path $_.fullname -Pattern $PatternToSearch -SimpleMatch -quiet)
	{
	 write-ResultFile ($_.fullname + "|"+ ($_.CreationTime.toString("MM/dd/yyyy"))+ "|MATCH") $logfile
	 $FileMatchingPatternCount=$FileMatchingPatternCount + 1
	}
	else
	{
	    if ($WriteNoMatchedFile) {(write-ResultFile ($_.fullname + "|"+ ($_.CreationTime.toString("MM/dd/yyyy"))+ "|NO MATCH") $logfile)}
	}
	$i++
}
write-ResultFile ("The Number of File Containing the Pattern are " +  ($FileMatchingPatternCount-1)) $logfile
write-host "The result can be found in"  $logfile
}catch{
 Write-Host $_.Exception.Message -ForegroundColor Yellow
}

