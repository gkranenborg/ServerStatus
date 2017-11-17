
#This Script is used for monitoring the Critical PROD services like SQL, IIS, CORDYS
If (Test-Path D:\Cordys\Production\webroot\shared\system\system\reports\Services.json) 
    { 
        Remove-Item D:\Cordys\Production\webroot\shared\system\system\reports\Services.json 
    }
$srvArray = ('OpenLDAP-slapd Production','Cordys Monitor Production','Jackrabbit','James 2.3.2','IISADMIN','MSSQLSERVER','MSSQLServerOLAPService','MsDtsServer100','ReportServer','SQLWriter','W3SVC')
$dataRow = "["
Add-Content -Encoding UTF8 D:\Cordys\Production\webroot\shared\system\system\reports\Services.json $dataRow
foreach ($i in $srvArray)
 {

$colItems = Get-WmiObject -query "Select * From Win32_Service where name = '$i'"

   
    if ($colItems.state -ne "Running")
      {
            $dataRow = "{`"service`":`"$i`",`"status`":`"Stopped`"},"
	    Add-Content -Encoding UTF8 D:\Cordys\Production\webroot\shared\system\system\reports\Services.json $dataRow;
      }
   else
       {
            $dataRow = "{`"service`":`"$i`",`"status`":`"Running`"},"
            Add-Content -Encoding UTF8 D:\Cordys\Production\webroot\shared\system\system\reports\Services.json $dataRow; 
       }   
  }
$file = Get-Content D:\Cordys\Production\webroot\shared\system\system\reports\Services.json
for($j = $file.count;$j -ge 0;$j--){if($file[$j] -match ","){$file[$j] = $file[$j] -replace "},", "}";break}}
Remove-Item D:\Cordys\Production\webroot\shared\system\system\reports\Services.json
Add-Content -Encoding UTF8 D:\Cordys\Production\webroot\shared\system\system\reports\Services.json $file
$dataRow = "]"
Add-Content -Encoding UTF8 D:\Cordys\Production\webroot\shared\system\system\reports\Services.json $dataRow;
                              


       
           
                
                 



