$users = "gerben.kranenborg@us.fujitsu.com", "neal.wang@us.fujitsu.com", "mahesh.giri@in.fujitsu.com", "faisal.ansari@in.fujitsu.com"
$diskReport = "D:\Cordys\Production\webroot\shared\system\system\reports\DiskSpaceRpt.json";
$dbReport = "D:\Cordys\Production\webroot\shared\system\system\reports\DBSpaceRpt.json";
$datetimereport = "D:\Cordys\Production\webroot\shared\system\system\reports\DateTimeRpt.json";
$servicesreport = "D:\Cordys\Production\webroot\shared\system\system\reports\Services.json";
$redColor = "#FF0000"
$computer = "FSKS-Server"
$smtpServer = "127.0.0.1"

If (Test-Path $diskReport) 
    { 
        Remove-Item $diskReport 
    }
	
if (Test-Path $datetimereport)
	{
	Remove-Item $datetimereport
	}
	
if (Test-Path $dbReport)
	{
	Remove-Item $dbReport
	}
	
if (Test-Path $servicesreport)
	{
	Remove-Item $servicesreport
	}

$srvArray = ('OpenLDAP-slapd Production','Cordys Monitor Production','Jackrabbit','James 2.3.2','IISADMIN','MSSQLSERVER','MSSQLServerOLAPService','MsDtsServer100','ReportServer','SQLWriter','W3SVC')
$dataRow = "["
Add-Content -Encoding UTF8 $servicesreport $dataRow
foreach ($i in $srvArray)
 {

$colItems = Get-WmiObject -query "Select * From Win32_Service where name = '$i'"

   
    if ($colItems.state -ne "Running")
      {
            $dataRow = "{`"service`":`"$i`",`"status`":`"Stopped`"},"
	    Add-Content -Encoding UTF8 $servicesreport $dataRow;
      }
   else
       {
            $dataRow = "{`"service`":`"$i`",`"status`":`"Running`"},"
            Add-Content -Encoding UTF8 $servicesreport $dataRow; 
       }   
  }
$file = Get-Content $servicesreport
for($j = $file.count;$j -ge 0;$j--){if($file[$j] -match ","){$file[$j] = $file[$j] -replace "},", "}";break}}
Remove-Item $servicesreport
Add-Content -Encoding UTF8 $servicesreport $file
$dataRow = "]"
Add-Content -Encoding UTF8 $servicesreport $dataRow;

$dataRow = "["
Add-Content $datetimereport $dataRow	
$currenttime = Get-Date
$dataRow = "{`"datetime`":`"$currenttime`"}]"
Add-Content $datetimereport $dataRow

$databases = "Cordys.mdf", "Cordys_log.ldf", "CordysBusiness.mdf", "CordysBusiness_log.ldf"
$databasepath = "D:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA"
$dbdatarow = "["
Add-Content $dbReport $dbdatarow;
foreach($database in $databases)
	{
		$databasefullpath = join-path "$databasepath" "$database"
		$dbsize = Get-Item "$databasefullpath"
		$dbsizeGB = [Math]::Round($dbsize.Length / 1073741824, 2);
		$dbdatarow = "{`"DBname`":`"$database`",`"DBsize`":`"$dbsizeGB`"},"
		Add-Content $dbReport $dbdatarow;
	}
$file = Get-Content $dbReport
for($i = $file.count;$i -ge 0;$i--){if($file[$i] -match ","){$file[$i] = $file[$i] -replace "},", "}";break}}
Remove-Item $dbReport
Add-Content $dbReport $file
$dbdatarow = "]"
Add-Content $dbReport $dbdatarow;

$disks = Get-WmiObject -ComputerName $computer -Class Win32_LogicalDisk -Filter "DriveType = 3" 
$dataRow = "["
Add-Content $diskReport $dataRow;
foreach($disk in $disks) 
 {          
  $deviceID = $disk.DeviceID; 
  $volName = $disk.VolumeName; 
  [float]$size = $disk.Size; 
  [float]$freespace = $disk.FreeSpace;  
  $percentFree = [Math]::Round(($freespace / $size) * 100, 2); 
  $sizeGB = [Math]::Round($size / 1073741824, 2); 
  $freeSpaceGB = [Math]::Round($freespace / 1073741824, 2); 
  $usedSpaceGB = $sizeGB - $freeSpaceGB; 

  if($percentFree -lt 25) 
    { 
        $color = $redColor 
    } 
	   
 # Create table data rows  
    $dataRow = "{`"server`":`"$computer`",`"drive`":`"$deviceID`",`"size`":`"$sizeGB`",`"used`":`"$usedSpaceGB`",`"free`":`"$freeSpaceGB`",`"percent`":`"$percentFree`"},"
Add-Content $diskReport $datarow		
  if ($deviceID -eq "C:")
     {
	    if ($percentFree -lt 10)
		{
		  Send-MailMessage -To $users -Body 'The disk space on the FSKS production server for drive C: is low. Please check the server ASAP.' -Subject 'Disk Space ALERT FS Production Server' -from 'mail@bop.feinsuch.com' -smtpServer '127.0.0.1' 
		}
	  }
	   else {
        if ($percentFree -lt 20) 
        { 
          Send-MailMessage -To $users -Body 'The disk space on the FSKS production server for drive D: or E: is low. Please check the server ASAP.' -Subject 'Disk Space ALERT FS Production Server' -from 'mail@bop.feinsuch.com' -smtpServer '127.0.0.1' 
        } }
}
$file = Get-Content $diskReport
for($i = $file.count;$i -ge 0;$i--){if($file[$i] -match ","){$file[$i] = $file[$i] -replace "},", "}";break}}
Remove-Item $diskReport
Add-Content $diskReport $file
$dataRow = "]"
Add-Content $diskReport $dataRow;
