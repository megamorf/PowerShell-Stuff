## Find every account locked out in the domain that was locked out today
$users = Search-ADAccount -LockedOut -UsersOnly | Where-Object { [datetime]::FromFileTime((get-aduser $_ -Properties lockouttime).lockouttime).Date -eq (Get-Date).Date }
## Write the username to the console while unlocking each account in case you want to see your results
$users | ForEach-Object { $_.samAccountName; Unlock-AdAccount $_.samAccountName }