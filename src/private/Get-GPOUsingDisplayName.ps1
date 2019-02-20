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