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
