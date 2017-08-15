Add-Type -Path "$PSScriptRoot\vendor\System.Data.SQLite.dll"
. ("$PSScriptRoot\data\config.ps1")

function GetWhatPulseDbDataSet($query)
{
	$dbConnection = New-Object -TypeName System.Data.SQLite.SQLiteConnection
	$dbConnection.ConnectionString = "Data Source=$ENV:LOCALAPPDATA\whatpulse\whatpulse.db"
	$dbConnection.Open()

	$command = $dbConnection.CreateCommand()
	$command.CommandText = $query
	$dataAdapter = New-Object -TypeName System.Data.SQLite.SQLiteDataAdapter $command
	$dataSet = New-Object System.Data.DataSet
	[void]$dataAdapter.Fill($dataSet)

	$dbConnection.Close()
	return $dataSet
}

function DateTimeToInfluxDbTimestamp([DateTime]$date)
{
	$unixEpoch = Get-Date -Date "01/01/1970"
	[long]$ns = (New-TimeSpan -Start $unixEpoch -End $date.ToUniversalTime()).TotalMilliseconds * 1000000L
	return $ns.ToString()
}

function InfluxDbEscapeTagValue([String]$value)
{
	return $value.Replace(" ", "\ ").Replace(",", "\,").Replace("=", "\=")
}

function InfluxDbWrite($data)
{
	Invoke-RestMethod -UseBasicParsing -Uri $INFLUXDB_WRITE_URI -Body $data -method Post *>$null
}

function ShowProgress($actionType, $destinationCount, $currentCount)
{
	if ($destinationCount -gt 0)
	{
		Write-Progress -Activity "whatpulse2influxdb-$actionType" -Status "$currentCount / $destinationCount" -PercentComplete (($currentCount / $destinationCount) * 100)
	}
}

function PrepareSqlFile($sqlFileName)
{
	$syncStart = (Get-Date).AddYears(-10).ToString("yyyy-MM-dd")
	if (Test-Path "$PSScriptRoot\data\NextSyncStart_$ENV:COMPUTERNAME.txt")
	{
		$syncStart = (Get-Content "$PSScriptRoot\data\NextSyncStart_$ENV:COMPUTERNAME.txt" -Raw)
	}

	return (Get-Content "$PSScriptRoot\$sqlFileName.sql" -Raw).Replace("SYNCSTART", $syncStart)
}


try
{

$mouseClicksDataSet = GetWhatPulseDbDataSet -query (PrepareSqlFile -sqlFileName "mouseclicks")
$i = 1
foreach($row in $mouseClicksDataSet.Tables.Rows)
{
	$timestamp = [datetime]$row.day
	$timestamp = $timestamp.AddHours($row.hour)
	$timestampNs = (DateTimeToInfluxDbTimestamp -date $timestamp)
	$app = (InfluxDbEscapeTagValue -value $row.app)
	$appPath = (InfluxDbEscapeTagValue -value $row.path)
	$mouseButton = $row.button
	$mouseClicksCount = $row.count

	ShowProgress -actionType "mouseclicks" -destinationCount $mouseClicksDataSet.Tables.Rows.Count -currentCount $i
	$data = "mouseclicks,host=$ENV:COMPUTERNAME,mouse_button=$mouseButton,app=$app,app_path=$appPath count=$mouseClicksCount $timestampNs"
	InfluxDbWrite -data $data

	$i++
}

$keyPressesDataSet = GetWhatPulseDbDataSet -query (PrepareSqlFile -sqlFileName "keypresses")
$i = 1
foreach($row in $keyPressesDataSet.Tables.Rows)
{
	$timestamp = [datetime]$row.day
	$timestamp = $timestamp.AddHours($row.hour)
	$timestampNs = (DateTimeToInfluxDbTimestamp -date $timestamp)
	$app = (InfluxDbEscapeTagValue -value $row.app)
	$appPath = (InfluxDbEscapeTagValue -value $row.path)
	$key = $row.key
	$keyPressesCount = $row.count

	ShowProgress -actionType "keypresses" -destinationCount $keyPressesDataSet.Tables.Rows.Count -currentCount $i
	$data = "keypresses,host=$ENV:COMPUTERNAME,key=$key,app=$app,app_path=$appPath count=$keyPressesCount $timestampNs"
	InfluxDbWrite -data $data

	$i++
}

$appUsageDataSet = GetWhatPulseDbDataSet -query (PrepareSqlFile -sqlFileName "appusage")
$i = 1
foreach($row in $appUsageDataSet.Tables.Rows)
{
	$timestamp = [datetime]$row.day
	$timestamp = $timestamp.AddHours($row.hour)
	$timestampNs = (DateTimeToInfluxDbTimestamp -date $timestamp)
	$app = (InfluxDbEscapeTagValue -value $row.app)
	$appPath = (InfluxDbEscapeTagValue -value $row.path)
	$secondsActive = $row.seconds_active

	ShowProgress -actionType "appusage" -destinationCount $appUsageDataSet.Tables.Rows.Count -currentCount $i
	$data = "appusage,host=$ENV:COMPUTERNAME,app=$app,app_path=$appPath seconds_active=$secondsActive $timestampNs"
	InfluxDbWrite -data $data

	$i++
}

#$mousePointsDataSet = GetWhatPulseDbDataSet -query (PrepareSqlFile -sqlFileName "mousepoints")
#$i = 1
#foreach($row in $mousePointsDataSet.Tables.Rows)
#{
#	$timestamp = [datetime]$row.day
#	$timestamp = $timestamp.AddSeconds($i)
#	$timestampNs = (DateTimeToInfluxDbTimestamp -date $timestamp)
#	$mousePointX = $row.x
#	$mousePointY = $row.y
#
#	ShowProgress -actionType "mousepoints" -destinationCount $mousePointsDataSet.Tables.Rows.Count -currentCount $i
#	$data = "mousepoints,host=$ENV:COMPUTERNAME x=$mousePointX,y=$mousePointY $timestampNs"
#	InfluxDbWrite -data $data
#
#	$i++
#}

$bootTimesDataSet = GetWhatPulseDbDataSet -query (PrepareSqlFile -sqlFileName "boottimes")
$i = 1
foreach($row in $bootTimesDataSet.Tables.Rows)
{
	$timestamp = [datetime]$row.boot_time
	$timestampNs = (DateTimeToInfluxDbTimestamp -date $timestamp)

	ShowProgress -actionType "boottimes" -destinationCount $bootTimesDataSet.Tables.Rows.Count -currentCount $i
	$data = "boottimes,host=$ENV:COMPUTERNAME boot=1 $timestampNs"
	InfluxDbWrite -data $data

	$i++
}

(Get-Date).AddDays(-1).ToString("yyyy-MM-dd") > "$PSScriptRoot\data\NextSyncStart_$ENV:COMPUTERNAME.txt"

}
catch
{
	Write-Error $_.Exception.ToString()
	Read-Host -Prompt "Check error and press any key to exit..."
}
