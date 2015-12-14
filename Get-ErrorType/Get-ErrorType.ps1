Function Get-ErrorType
{
<#
.Synopsis
   Returns error information
.DESCRIPTION
   Returns information that can be used in 
   try-catch blocks to handle specific errors
.EXAMPLE
   Get-ErrorType
.EXAMPLE
   Get-ErrorType $myerrorvariable
.EXAMPLE
   Get-ErrorType | select errormessage,errortype | fl
.EXAMPLE
   $myerrorvariable | Get-ErrorType | fl
.INPUTS
   [pscustomobject[]]
.OUTPUTS
   [pscustomobject[]]
#>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        $InputObject = $error
    )
    
    foreach($e in $InputObject)
    {
         New-object psobject -Property @{
            ErrorType = $e.Exception.GetType().FullName
            ErrorMessage = $e.Exception.Message
            ErrorCategory = $e.FullyQualifiedErrorId
         }
    }
}

