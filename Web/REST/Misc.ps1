# accessing properties with dots in their names
$result = Invoke-RestMethod -Uri https://gianmariaricci.visualstudio.com/defaultcollection/_apis/wit/workitems/100?api-version=1.0  -headers $headers -Method Get
$closedBy = $result.fields.'Microsoft.VSTS.Common.ClosedBy'
Write-Output "Work Item was closed by: $closedBy"
