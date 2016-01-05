$Volume = Get-Volume -UniqueId '\\?\Volume{945e4499-0000-0000-0000-100000000000}\'

if($Volume)
{
    if($Volume.HealthStatus -ne 'Healthy')
    {
        Write-Warning "HDD should not be used anymore!"
    }

    $backupCommand = "start backup -backupTarget:{0}: -include:C:,D: -allCritical -vssfull -quiet" -f $Volume.DriveLetter

    $start = Get-Date
    start-process 'wbadmin.exe' -ArgumentList $backupCommand -NoNewWindow -PassThru -Wait 
    $end = Get-Date

    $backupDuration = New-TimeSpan -Start $start -End $end
    Write-Host ("Backup took {0:N2} minutes" -f $backupDuration.TotalMinutes)

    $BackupDir = "$($Volume.DriveLetter):\WindowsImageBackup"
    $TargetDir = ($BackupDir + '-' + $end.ToString('yyyy-MM-dd'))
    Move-Item $BackupDir -Destination $TargetDir
}
else
{
    Write-Error "HDD not connected or not recognized!"
}