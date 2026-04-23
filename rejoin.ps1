# ==================================================================
Write-Host "`n# 9. Rename & Join Domain" -ForegroundColor Cyan
$pcname = ((Get-WmiObject -Class Win32_BIOS).SerialNumber.Trim()) + "-"
$domain = 'id.corp.seagroup.com'
$username = "$domain\adm.fredy"
$password = 'Monitor@1234567' | ConvertTo-SecureString -AsPlainText -Force
$credUser = New-Object System.Management.Automation.PSCredential($username, $password)

$pcnameNow = $env:COMPUTERNAME
$joinedDomain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain

if (($joinedDomain -ne $true) -and ($pcnameNow -ne $pcname)) {
    Write-Host "[!] Renaming to '$pcname' and joining domain '$domain'..."
    Start-Sleep -Seconds 5
    Add-Computer -DomainName $domain -NewName $pcname -Credential $credUser -Force
    Write-Host "[✓] Renamed and joined to domain." -ForegroundColor Green
} elseif (($joinedDomain -eq $true) -and ($pcnameNow -ne $pcname)) {
    Write-Host "[!] Renaming to '$pcname'..."
    Start-Sleep -Seconds 5
    Rename-Computer -NewName $pcname -DomainCredential $credUser -Force
    Write-Host "[✓] Computer renamed." -ForegroundColor Green
} elseif (($joinedDomain -ne $true) -and ($pcnameNow -eq $pcname)) {
    Write-Host "[!] Joining domain '$domain'..."
    Start-Sleep -Seconds 5
    Add-Computer -DomainName $domain -Credential $credUser -Force
    Write-Host "[✓] Joined to domain." -ForegroundColor Green
} else {
    Write-Host "[✓] Already joined and named correctly." -ForegroundColor Green
}
Start-Sleep -Seconds 3
