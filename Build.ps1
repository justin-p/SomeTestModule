#Requires -Version 5
[CmdletBinding(DefaultParameterSetName = 'Build')]
param (
    [parameter(Position = 0, ParameterSetName = 'Build')]
    [switch]$BuildModule,
    [parameter(Position = 2, ParameterSetName = 'Build')]
    [switch]$UploadPSGallery,
    [parameter(Position = 3, ParameterSetName = 'Build')]
    [switch]$InstallAndTestModule,
    [parameter(Position = 4, ParameterSetName = 'Build')]
    [version]$NewVersion,
    [parameter(Position = 5, ParameterSetName = 'Build')]
    [string]$ReleaseNotes,
    [parameter(Position = 6, ParameterSetName = 'CBH')]
    [switch]$AddCBH
)

function PrerequisitesLoaded {
    # Install required modules if missing
    try {
        if ((get-module InvokeBuild -ListAvailable) -eq $null) {
            Write-Output "Attempting to install the InvokeBuild module..."
            $null = Install-Module InvokeBuild -Scope:CurrentUser
        }
        if (get-module InvokeBuild -ListAvailable) {
            Write-Output -NoNewLine "Importing InvokeBuild module"
            Import-Module InvokeBuild -Force
            Write-Output '...Loaded!'
            return $true
        }
        else {
            return $false
        }
    }
    catch {
        return $false
    }
}
if (-not (PrerequisitesLoaded)) {
    throw 'Unable to load InvokeBuild!'
}
switch ($psCmdlet.ParameterSetName) {
    'CBH' {
        if ($AddCBH) {
            try {
                Invoke-Build -Task AddMissingCBH -ErrorAction stop
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
    'Build' {
        if ($NewVersion -ne $null) {
            try {
                Invoke-Build -Task UpdateVersion -NewVersion $NewVersion -ReleaseNotes $ReleaseNotes -ErrorAction Stop
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
        # If no parameters were specified or the build action was manually specified then kick off a standard build
        if (($psboundparameters.count -eq 0) -or ($BuildModule)) {
            try {
                Write-Error 'TEST: This should fail.' -ErrorAction Stop
                Invoke-Build -ErrorAction Stop
            }
            catch {
                Write-Output 'Build Failed with the following error:'
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
        # Install and test the module?
        if ($InstallAndTestModule) {
            try {
                Invoke-Build -Task InstallAndTestModule -ErrorAction Stop
            }
            catch {
                Write-Output 'Install and test of module failed:'
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
        # Upload to gallery?
        if ($UploadPSGallery) {
            try {
                Invoke-Build -Task PublishPSGallery -ErrorAction Stop
            }
            catch {
                Write-Output 'Unable to upload project to the PowerShell Gallery!'
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
    }
}
