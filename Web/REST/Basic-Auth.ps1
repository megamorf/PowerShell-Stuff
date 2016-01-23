$username = "alternateusername"
$password = "alternatepassword"
 
$basicAuth = ("{0}:{1}" -f $username,$password)
$basicAuth = [System.Text.Encoding]::UTF8.GetBytes($basicAuth)
$basicAuth = [System.Convert]::ToBase64String($basicAuth)
$headers = @{Authorization=("Basic {0}" -f $basicAuth)}
 
$result = Invoke-RestMethod -Uri https://gianmariaricci.visualstudio.com/defaultcollection/_apis/wit/workitems/100?api-version=1.0  -headers $headers -Method Get
