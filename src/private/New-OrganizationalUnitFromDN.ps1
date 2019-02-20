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