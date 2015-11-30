#requires -Version 2
function Set-LocalUser
{
    <#
    .Synopsis
     Modifies a local user.

    .DESCRIPTION
     The Set-LocalUser cmdlet modifies the properties of a
     local user. You can modify commonly used property values 
     by using the cmdlet parameters. 

    .PARAMETER ChangePasswordAtLogon
     Specifies whether a password must be changed during the 
     next logon attempt. Possible values for this parameter include:
        $false or 0
        $true or 1

    .PARAMETER Description
     Specifies a description of the object. This parameter sets the 
     value of the Description property for the user.

     The following example shows how to set this parameter to a sample 
     description.
        -Description "Description of the object"

    .PARAMETER DisplayName
     Specifies the display name of the object. This parameter sets the 
     DisplayName property of the object.

     The following example shows how to set this parameter.
        -DisplayName "Sara Davis Laptop"

    .PARAMETER Enabled
     Specifies if an account is enabled. An enabled account requires a 
     password. This parameter sets the Enabled property for an account 
     object. This parameter also sets the AccountDisabled flag.
     Possible values for this parameter include:
        $false or 0
        $true or 1

     The following example shows how to set this parameter to disable the 
     account.
        -Enabled:$false

    .PARAMETER Identity
     The cmdlet searches the computer via ADSI to find the object. 
     
     This example shows how to set this parameter to a user object 
     instance named "helpdesk".
        -Identity helpdesk

    .PARAMETER PasswordNeverExpires
     Specifies whether the password of an account can expire. This 
     parameter sets the PasswordNeverExpires property of an account object. 
     This parameter also sets the DONT_EXPIRE_PASSWD flag. 
     
     Possible values for this parameter include:
        $false or 0
        $true or 1

     The following example shows how to set this parameter so that the password 
     can expire.
        -PasswordNeverExpires:$false


    .PARAMETER CannotChangePassword
     Specifies whether the account password can be changed. This 
     parameter sets the CannotChangePassword property of an account. 
     
     Possible values for this parameter include:
        $false or 0
        $true or 1

     The following example shows how to set this parameter so that the account 
     password can be changed.
        -CannotChangePassword:$false

    .PARAMETER Password
     Specifies the password to use to perform the password reset on the user. 
     To specify this parameter, you have to provide a SecureString object. 

     The following example shows how to create a password as secure string.
        $SecStringPW = ConvertTo-SecureString -String "MyPassword" -AsPlainText -Force

    .EXAMPLE
     Set-LocalUser -Identity Administrator -Enabled:$false
     Disables the Administrator user on the local computer.

    .EXAMPLE
     Set-LocalUser -Identity Helpdesk -Computername srvwts001 -Password (ConvertTo-SecureString -String "MyPassword" -AsPlainText -Force) -Verbose
     Changes the password of the Helpdesk user on the remote 
     computer srvwts001.

    .EXAMPLE
     Set-LocalUser -Identity wadmin -Description "Custom Admin Account" -PasswordNeverExpires -Password $SecStringPW
     Changes the description, sets the user's password and 
     prevents it from expiring.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullorEmpty()]
        [Alias('Username')]
        [string] $Identity,

        [Parameter(Mandatory=$false,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [ValidateNotNullorEmpty()]
        [Alias('__Server','IPAddress','CN','dnshostname')]
        [string[]] $ComputerName = $env:COMPUTERNAME,

        [Parameter(Mandatory=$false)]
        [string] $Description,

        [Parameter(Mandatory=$false)]
        [ValidateNotNullorEmpty()]
        [Alias('FullName')]
        [string] $DisplayName,

        [Parameter(Mandatory=$false)]
        [System.Security.SecureString] $Password,

        [switch] $ChangePasswordAtLogon,
        [switch] $CannotChangePassword,
        [switch] $PasswordNeverExpires,
        [switch] $Enabled,
        [switch] $Unlock,
        [switch] $ResetAllFlags
    )
	    
    PROCESS 
    {
        foreach($Computer in $ComputerName)
        {
            $F = "[$($myinvocation.mycommand)] :: [$Computer]" 
            
            try 
            {
                if ($Password) 
                {
                    $pass = [Runtime.InteropServices.marshal]::PtrToStringAuto([Runtime.InteropServices.marshal]::SecureStringToBSTR($Password))
                }
		
                $AccountOptions = @{
                    ACCOUNTDISABLE     = 2
                    LOCKOUT            = 16
                    PASSWD_CANT_CHANGE = 64
                    NORMAL_ACCOUNT     = 512
                    DONT_EXPIRE_PASSWD = 65536
                }
		
                $user = [ADSI] "WinNT://$Computer/$Identity"
		
                if ($Description) 
                {
                    Write-Verbose "$F Setting Description of [$Identity] to [$Description]..."
                    $user.Description = $Description
                }
		
                if ($DisplayName) 
                {
                    Write-Verbose "$F Setting DisplayName of [$Identity] to [$DisplayName]..."
                    $user.FullName = $DisplayName
                }
		
                if ($pass) 
                {
                    Write-Verbose "$F Setting Password of [$Identity]..."
                    $user.psbase.invoke('SetPassword', $pass)
                    $user.psbase.CommitChanges()
                }
		
                if ($ResetAllFlags) 
                {
                    Write-Verbose "$F Resetting settings of [$Identity] to default values..."
                    $user.UserFlags = $user.UserFlags.Value -band $AccountOptions.NORMAL_ACCOUNT
                }
                else 
                {
                    # Disables "User cannot change password" and "Password never expires"
                    if ($ChangePasswordAtLogon) 
                    {
                        Write-Verbose "$F Forcing [$Identity] to change password at next logon"
                        $user.UserFlags = $AccountOptions.PASSWD_CANT_CHANGE -band $AccountOptions.DONT_EXPIRE_PASSWD
                        $user.PasswordExpired = 1
                    }
                    else 
                    {
                        if ($CannotChangePassword) 
                        {
                            Write-Verbose "$F Setting CannotChangePassword flag of [$Identity] to [$true]..."
                            $user.PasswordExpired = 0
                            $user.UserFlags = $user.UserFlags.Value -bor $AccountOptions.PASSWD_CANT_CHANGE
                        } 
                        if ($PasswordNeverExpires) 
                        {
                            Write-Verbose "$F Setting PasswordNeverExpires flag of [$Identity] to [$true]..."
                            $user.UserFlags = $user.UserFlags.Value -bor $AccountOptions.DONT_EXPIRE_PASSWD
                        }	
                    }

                    if($PSBoundParameters.ContainsKey('Enabled'))
                    {
                        if ($Enabled) 
                        {
                            Write-Verbose "$F Enabling [$Identity]..."
                            $user.InvokeSet('AccountDisabled', 'False')
                        }
                        else          
                        {
                            Write-Verbose "$F Disabling [$Identity]..."
                            $user.InvokeSet('AccountDisabled', 'True')
                        }
                    }
			
                    if ($Unlock) 
                    {
                        Write-Verbose "$F Unlocking [$Identity]..."
                        $user.IsAccountLocked = $false
                    }
                }
                Write-Verbose "$F Committing changes..."
                $user.SetInfo()
            }
            catch 
            {               
                throw 'Failed to set local user account properties. The error was: "{0}" and occurred in line "{1}".' -f $_,$_.InvocationInfo.ScriptLineNumber
            }
        }
    }
}