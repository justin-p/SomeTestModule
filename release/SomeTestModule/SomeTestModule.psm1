## Pre-Loaded Module code ##

<#
 Put all code that must be run prior to function dot sourcing here.

 This is a good place for module variables as well. The only rule is that no 
 variable should rely upon any of the functions in your module as they 
 will not have been loaded yet. Also, this file cannot be completely
 empty. Even leaving this comment is good enough.
#>

## PRIVATE MODULE FUNCTIONS AND DATA ##

Function Add-UPNSuffixToAD {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $Identity,
        $Server,
        $UPNSuffix
    )
    Try {
        if ($server) {
            Set-ADForest -Identity $Identity -UPNSuffixes @{Add=$($UPNSuffix)} -Server $server
        } Else  {
            Set-ADForest -Identity $Identity -UPNSuffixes @{Add=$($UPNSuffix)}
        }
    } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }
}

Function ConvertTo-IPaddress {
    [CmdletBinding()]
    Param (
        $InputObject
    )
    Try {
        $OutputObject = @()
        ForEach ($IP in $InputObject) {
            $OutputObject += New-IPAddressObject -IPaddress $([IPAddress]$IP) -ErrorAction Stop
            Write-Verbose "ConvertTo-IPaddress - Converted $IP to an IPAddress Object"
        }
        Return $OutputObject
    } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }
}

function Get-CallerPreference {
    <#
    .Synopsis
       Fetches "Preference" variable values from the caller's scope.
    .DESCRIPTION
       Script module functions do not automatically inherit their caller's variables, but they can be
       obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
       for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
       and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
    .PARAMETER Cmdlet
       The $PSCmdlet object from a script module Advanced Function.
    .PARAMETER SessionState
       The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
       Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
       script module.
    .PARAMETER Name
       Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
       Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
       This parameter may also specify names of variables that are not in the about_Preference_Variables
       help file, and the function will retrieve and set those as well.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Imports the default PowerShell preference variables from the caller into the local scope.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

       Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
    .EXAMPLE
       'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Same as Example 2, but sends variable names to the Name parameter via pipeline input.
    .INPUTS
       String
    .OUTPUTS
       None.  This function does not produce pipeline output.
    .LINK
       about_Preference_Variables
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]$SessionState,

        [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
        [string[]]$Name
    )

    begin {
        $filterHash = @{}
    }
    
    process {
        if ($null -ne $Name)
        {
            foreach ($string in $Name)
            {
                $filterHash[$string] = $true
            }
        }
    }

    end {
        # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

        $vars = @{
            'ErrorView' = $null
            'FormatEnumerationLimit' = $null
            'LogCommandHealthEvent' = $null
            'LogCommandLifecycleEvent' = $null
            'LogEngineHealthEvent' = $null
            'LogEngineLifecycleEvent' = $null
            'LogProviderHealthEvent' = $null
            'LogProviderLifecycleEvent' = $null
            'MaximumAliasCount' = $null
            'MaximumDriveCount' = $null
            'MaximumErrorCount' = $null
            'MaximumFunctionCount' = $null
            'MaximumHistoryCount' = $null
            'MaximumVariableCount' = $null
            'OFS' = $null
            'OutputEncoding' = $null
            'ProgressPreference' = $null
            'PSDefaultParameterValues' = $null
            'PSEmailServer' = $null
            'PSModuleAutoLoadingPreference' = $null
            'PSSessionApplicationName' = $null
            'PSSessionConfigurationName' = $null
            'PSSessionOption' = $null

            'ErrorActionPreference' = 'ErrorAction'
            'DebugPreference' = 'Debug'
            'ConfirmPreference' = 'Confirm'
            'WhatIfPreference' = 'WhatIf'
            'VerbosePreference' = 'Verbose'
            'WarningPreference' = 'WarningAction'
        }

        foreach ($entry in $vars.GetEnumerator()) {
            if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
                ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name))) {
                
                $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
                if ($null -ne $variable) {
                    if ($SessionState -eq $ExecutionContext.SessionState) {
                        Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                    }
                    else {
                        $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filtered') {
            foreach ($varName in $filterHash.Keys) {
                if (-not $vars.ContainsKey($varName)) {
                    $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                    if ($null -ne $variable)
                    {
                        if ($SessionState -eq $ExecutionContext.SessionState)
                        {
                            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                        }
                        else
                        {
                            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                        }
                    }
                }
            }
        }
    }
}

Function Get-GPOUsingDisplayName {
    Param (
        $GPODisplayName
    )
    $GPOSearcher = New-Object DirectoryServices.DirectorySearcher -Property @{
        Filter = '(objectClass=groupPolicyContainer)'
        PageSize = 100
    }
   # Write-Verbose 'ReturnDNofGPODisplayName - Setting $GPOSearcher.SearchRoot to use domain controller where GPO was created.'
   # $Entry = [adsi]"LDAP://$($DomainController)/$($ADPath)"
   # $GPOSearcher = [adsisearcher]$Entry
    $GPOSearcher.FindAll() | ForEach-Object {
        New-Object -TypeName PSCustomObject -Property @{
            'DisplayName' = $_.properties.displayname -join ''
            'CommonName' = $_.properties.cn -join ''
            'FilePath' = $_.properties.gpcfilesyspath -join ''
            'DistinguishedName' = $_.properties.distinguishedname -join ''
            'CN' = $_.properties.cn -join ''
        } | Select-Object -Property DisplayName,CommonName,FilePath,DistinguishedName,CN | Where-Object  {$_.DisplayName -eq $($GPODisplayName)}
    }
}

Function Get-StringLenght {
  Param (
        [string]$string
  )
  Write-Verbose "Get-StringLenght - String lentgh is $($string.Length)"
  Return $string.Length
}

Function Get-UPNSuffixesFromAD {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        $Identity,
        $Server
    )
    Try {
        if ($server) {
            Return (Get-ADForest -Identity $Identity -Server $Server).UPNSuffixes
        } Else  {
            Return (Get-ADForest -Identity $Identity).UPNSuffixes
        }
    } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }
}

Function New-InputBox {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Just an Test Module")]
    Param (
        [String]$Title = 'Something',
        [String]$Msg = 'You should enter something'
    )
    [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $Output  = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title)
    Return $Output
}

Function New-IPAddressObject {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Just an Test Module")]
    Param(
        [IPAddress]$IPAddress
    )
    Return (New-Object PsObject -Property @{IPAddress = $IPAddress;})
}

Function New-OrganizationalUnitFromDN {
    # source https://serverfault.com/questions/624279/how-can-i-create-organizational-units-recursively-on-powershell
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [string]$DN,
        [string]$Server
    )
    Write-Debug "New-OrganizationalUnitFromDN - A regex to split the DN, taking escaped commas into account"
    $DNRegex = '(?<![\\]),'
    Write-Debug "New-OrganizationalUnitFromDN - Array to hold each component"
    [String[]]$MissingOUs = @()
    Write-Debug "New-OrganizationalUnitFromDN - We'll need to traverse the path, level by level, let's figure out the number of possible levels"
    $Depth = ($DN -split $DNRegex).Count
    Write-Debug "New-OrganizationalUnitFromDN - Step through each possible parent OU"
    For($i = 1;$i -le $Depth;$i++) {
        $NextOU = ($DN -split $DNRegex,$i)[-1]
        If($NextOU.IndexOf("OU=") -ne 0 -or [ADSI]::Exists("LDAP://$NextOU")) {
            Break
        } Else {
            Write-Verbose "New-OrganizationalUnitFromDN - $($NextOU) OU does not exist, remember this For later"
            $MissingOUs += $NextOU
        }
    }
    Write-Debug "New-OrganizationalUnitFromDN - Reverse the order of missing OUs, we want to create the top-most needed level first"
    [array]::Reverse($MissingOUs)
    Write-Debug "New-OrganizationalUnitFromDN - Prepare common Parameters to be passed to New-ADOrganizationalUnit"
    $PSBoundParameters.Remove('DN')
    Write-Debug "New-OrganizationalUnitFromDN - Now create the missing part of the tree, including the desired OU"
    ForEach($OU in $MissingOUs) {
        $newOUName = (($OU -split $DNRegex,2)[0] -split "=")[1]
        $newOUPath = ($OU -split $DNRegex,2)[1]
        If ($PSCmdlet.ShouldProcess("Creating OU $($NewOUName) on path $($newOUpPath)")) {
            New-ADOrganizationalUnit -Name $newOUName -Path $newOUPath @PSBoundParameters
        }
    }
}

Function New-TempFolderPath {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Just an Test Module")]
    Param()
    Return (Join-Path $env:TEMP (([System.Guid]::NewGuid() -split "-")[0]).ToString())
}

Function Remove-EmtpyProperties {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Just an Test Module")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="Just an Test Module")]
    Param(
        [Parameter(ValueFromPipeline=$True)]
        $InputObject
    )
    Process {
        Write-Verbose "Remove-EmtpyProperties - Removing EmtpyProperties on `$InputObject"
        Write-Debug "Remove-EmtpyProperties - Iterate over objects"
        $InputObject | ForEach-Object {
            Write-Debug "Remove-EmtpyProperties - Get array of names of object properties that can be cast to boolean TRUE"
            # PSObject.Properties - https://msdn.microsoft.com/en-us/library/system.management.automation.psobject.properties.aspx
            $NonEmptyProperties = $_.psobject.Properties | Where-Object {$_.Value} | Select-Object -ExpandProperty Name
            Write-Debug "Remove-EmtpyProperties - Return only non-empty properties"
            $_ | Select-Object -Property $NonEmptyProperties
        }
    }
}

Function Remove-UPNSuffixFromAD {
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [Parameter(Mandatory=$true)]
        $Identity,
        $Server,
        $UPNSuffix
    )
    Try {
        If ($PSCmdlet.ShouldProcess("Removing UPNSuffix $($UPNSuffix) on path $($Identity)")) {
            if ($server) {
                Set-ADForest -Identity $Identity -UPNSuffixes @{Remove=$($UPNSuffix)} -Server $server
            } Else  {
                Set-ADForest -Identity $Identity -UPNSuffixes @{Remove=$($UPNSuffix)}
            }
        }
   } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
   }
}

Function Sync-DNObjectOnAllDomainControllers  {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification="Just an Test Module")]
    Param (
        $InputObject,
        $SourceDomainController = $((Get-DomainController).dnshostname[0])
    )
    Write-Verbose "Sync-DNObjectOnAllDomainControllers - Syncing $InputObject"
    Try {
        Get-ADGroupMember 'Domain Controllers' | ForEach-Object {
            If ($InputObject.GetType().Name -eq "PSCustomObject") {
                Write-Debug "Sync-DNObjectOnAllDomainControllers - $($InputObject) type matched to PSCustomObject"
                If (!([string]::IsNullOrEmpty($InputObject))) {
                    Try {
                        [void](Sync-ADObject -object $InputObject -Source $SourceDomainController -Destination $_.Name)
                        [void](Get-ADObject -Identity $InputObject -Server $_.Name -ErrorAction Stop)
                    } Catch {
                        $PSCmdlet.ThrowTerminatingError($PSitem)
                    }
                }
            } ElseIf ($InputObject.GetType().Name -eq "Object[]") {
                Write-Debug "Sync-DNObjectOnAllDomainControllers - $($InputObject) type matched to Object[]. Starting ForEach."
                ForEach ($Value in $InputObject) {
                    If (!([string]::IsNullOrEmpty($Value))) {
                        Try {
                            [void](Sync-ADObject -object $Value -Source $SourceDomainController -Destination $_.Name)
                            [void](Get-ADObject -Identity $Value -Server $_.Name -ErrorAction Stop)
                        } Catch {
                            $PSCmdlet.ThrowTerminatingError($PSitem)
                       }
                    }
                }
            } ElseIf ($InputObject.GetType().Name -eq "String") {
                Write-Debug "Sync-DNObjectOnAllDomainControllers - $($InputObject) type matched to String"
                If (!([string]::IsNullOrEmpty($InputObject))) {
                    Try {
                        [void](Sync-ADObject -object $InputObject -Source $SourceDomainController -Destination $_.Name)
                        [void](Get-ADObject -Identity $InputObject -Server $_.Name -ErrorAction Stop)
                    } Catch {
                        $PSCmdlet.ThrowTerminatingError($PSitem)
                    }
                }
            }
        }
    } Catch {
        $PSCmdlet.ThrowTerminatingError($PSitem)
    }
}
#e

Function Test-IfADDSRSATIsInstalledOnRemotePC {
    Param (
        $ComputerName = $FileServerToRemoteTo
    )
    Write-Verbose "CheckIfADDSRSATIsInstalledOnFS - Checking If RSAT-AD-Tools is installed on $($FileServerToRemoteTo)."
    If ((ServerManager\Get-WindowsFeature -Name RSAT-AD-Tools -ComputerName $ComputerName -ErrorAction Stop).InstallState -ne 'Installed') {
        Write-Verbose "CheckIfADDSRSATIsInstalledOnFS - RSAT-AD-Tools is not installed on $($FileServerToRemoteTo). Installing now."
        [void](ServerManager\Install-WindowsFeature -Name RSAT-AD-Tools -ErrorAction Stop)
    } Else {
        Write-Verbose "CheckIfADDSRSATIsInstalledOnFS - RSAT-AD-Tools is installed on $($FileServerToRemoteTo)"
    }
}


Function Test-Url {
    [cmdletbinding()]
    Param (
        [System.URI]$url
    )
    Try {
        Invoke-WebRequest $url -ErrorAction Stop
    } Catch {
        Write-Error "Test-Url - $($PSItem). This could mean this domain contains a typo or the domain is simply not resolvable." -ErrorAction Stop
    }
}

Function Test-ValueLength {
    [CmdletBinding(SupportsShouldProcess=$true)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSShouldProcess", "", Justification="Just an Test Module")]
    Param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $InputObject,
        $ElementToCheck,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        $MaxLenght
    )
    $lenght = $null
    If ($InputObject.GetType().Name -eq "PSCustomObject") {
        Write-Verbose "Test-ValueLength - $($InputObject.$ElementToCheck) type matched to PSCustomObject"
        If (!([string]::IsNullOrEmpty($InputObject.$ElementToCheck))) {
                $lenght = $null
                $lenght = Get-StringLenght $InputObject.$ElementToCheck
                If ($lenght -gt $MaxLenght) {
                    Write-Error "Test-ValueLength - $($InputObject.$ElementToCheck) has a lenght of $lenght. This is longer MaxLenght of $MaxLenght"
                }
                Else {
                    Write-Verbose "Test-ValueLength - $($InputObject.$ElementToCheck) has a lenght of $lenght. This is not longer then MaxLenght of $MaxLenght"
                }
            }
    } ElseIf ($InputObject.GetType().Name -eq "Object[]") {
        Write-Verbose "Test-ValueLength - $($InputObject.$ElementToCheck) type matched to Object[]. Starting ForEach."
        ForEach ($Value in $InputObject) {
            If (!([string]::IsNullOrEmpty($Value.$ElementToCheck))) {
                $lenght = $null
                $lenght = Get-StringLenght $Value.$ElementToCheck
                If ($lenght -gt $MaxLenght) {
                    Write-Error "Test-ValueLength - $($Value.$ElementToCheck) has a lentgh of $lenght. This is longer then MaxLenght of $MaxLenght"
                } Else {
                    Write-Verbose "Test-ValueLength - $($Value.$ElementToCheck) has a lentgh of $lenght. This is not longer then MaxLenght of $MaxLenght"
                }
            } ElseIf ($null -eq $ElementToCheck) {
                $lenght = $null
                $lenght = Get-StringLenght $Value.$ElementToCheck
                If ($lenght -gt $MaxLenght) {
                    Write-Error "Test-ValueLength - $($Value) has a lentgh of $lenght. This is longer then MaxLenght of $MaxLenght"
                } Else {
                    Write-Verbose "Test-ValueLength - $($Value) has a lentgh of $lenght. This is not longer then MaxLenght of $MaxLenght"
                }
            }
        }
    } ElseIf ($InputObject.GetType().Name -eq "String") {
        Write-Verbose "Test-ValueLength - $($InputObject) type matched to String"
        $lenght = $null
        $lenght = Get-StringLenght $($InputObject)
        If ($lenght -gt $MaxLenght) {
            Write-Error "Test-ValueLength - $($InputObject) has a lentgh of $lenght. This is longer then MaxLenght of $MaxLenght"
        } Else {
            Write-Verbose "Test-ValueLength - $($InputObject) has a lentgh of $lenght. This is not longer then MaxLenght of $MaxLenght"
        }
    }
}

## PUBLIC MODULE FUNCTIONS AND DATA ##

Function Write-SomeTestModule {
    <#
    .EXTERNALHELP SomeTestModule-help.xml
    .LINK
        https://github.com/justin-p/SomeTestModule/tree/master/release/0.0.1/docs/Functions/Write-SomeTestModule.md
    #>
    [CmdletBinding()]
    param(
        $a
    )
    begin {
        if ($script:ThisModuleLoaded -eq $true) {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
        }
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
    }
    process {
        Write-Output 'Yerp. This is a function.'
    }
    end {
        Write-Verbose "$($FunctionName): End."
    }
}


## Post-Load Module code ##

# Use this variable for any path-sepecific actions (like loading dlls and such) to ensure it will work in testing and after being built
$MyModulePath = $(
    Function Get-ScriptPath {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        if($Invocation.PSScriptRoot) {
            $Invocation.PSScriptRoot
        }
        Elseif($Invocation.MyCommand.Path) {
            Split-Path $Invocation.MyCommand.Path
        }
        elseif ($Invocation.InvocationName.Length -eq 0) {
            (Get-Location).Path
        }
        else {
            $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
        }
    }

    Get-ScriptPath
)

# Load any plugins found in the plugins directory
if (Test-Path (Join-Path $MyModulePath 'plugins')) {
    Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName "Load.ps1")) {
            Invoke-Command -NoNewScope -ScriptBlock ([Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "Load.ps1") -Raw)}")) -ErrorVariable errmsg 2>$null
        }
    }
}

$ExecutionContext.SessionState.Module.OnRemove = {
    # Action to take if the module is removed
    # Unload any plugins found in the plugins directory
    if (Test-Path (Join-Path $MyModulePath 'plugins')) {
        Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName "UnLoad.ps1")) {
                Invoke-Command -NoNewScope -ScriptBlock ([Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "UnLoad.ps1") -Raw)}")) -ErrorVariable errmsg 2>$null
            }
        }
    }
}

$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {
    # Action to take if the whole pssession is killed
    # Unload any plugins found in the plugins directory
    if (Test-Path (Join-Path $MyModulePath 'plugins')) {
        Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName "UnLoad.ps1")) {
                Invoke-Command -NoNewScope -ScriptBlock [Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "UnLoad.ps1") -Raw)}") -ErrorVariable errmsg 2>$null
            }
        }
    }
}

# Use this in your scripts to check if the function is being called from your module or independantly.
# Call it immediately to avoid PSScriptAnalyzer 'PSUseDeclaredVarsMoreThanAssignments'
$ThisModuleLoaded = $true
$ThisModuleLoaded

# Non-function exported public module members might go here.
#Export-ModuleMember -Variable SomeVariable -Function  *


