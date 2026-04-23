
# ---------------------------------------
# 1. Stop Windows Update Services
# ---------------------------------------
Write-Host "[...] Stopping Windows Update services..."
Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
Stop-Service -Name bits -Force -ErrorAction SilentlyContinue
Stop-Service -Name dosvc -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# ---------------------------------------
# 3. Get Serial Number & Domain Info
# ---------------------------------------
$pcname = (Get-WmiObject -Class Win32_BIOS).SerialNumber.Trim()
$domain = 'id.corp.seagroup.com'
$username = "$domain\adm.fredy"
$password = 'Monitor@1234567' | ConvertTo-SecureString -AsPlainText -Force
$credUser = New-Object System.Management.Automation.PSCredential($username, $password)

# ---------------------------------------
# 4. Enable Built-in Administrator Account
# ---------------------------------------
Write-Host "[...] Enabling local Administrator account..."
$adminPass = ConvertTo-SecureString '1q2w3e4r$R#E@W!Q' -AsPlainText -Force
Try {
    Set-LocalUser -Name "Administrator" -Password $adminPass
    Enable-LocalUser -Name "Administrator"
    Write-Host "[OK] Local Administrator account enabled."
} Catch {
    Write-Error "Failed to enable Administrator account: $_"
}

# ---------------------------------------
# 5. Rename & Join Domain
# ---------------------------------------
$pcnameNow = $env:COMPUTERNAME
$joinedDomain = (Get-WmiObject -Class Win32_ComputerSystem).PartOfDomain

if (($joinedDomain -ne $true) -and ($pcnameNow -ne $pcname)) {
    Write-Host "[!] Renaming to '$pcname' and joining domain '$domain'..."
    Start-Sleep -Seconds 5
    Add-Computer -DomainName $domain -NewName $pcname -Credential $credUser -Force
    Write-Host "[OK] Renamed and joined to domain."
} elseif (($joinedDomain -eq $true) -and ($pcnameNow -ne $pcname)) {
    Write-Host "[!] Renaming to '$pcname'..."
    Start-Sleep -Seconds 5
    Rename-Computer -NewName $pcname -DomainCredential $credUser -Force
    Write-Host "[OK] Computer renamed."
} elseif (($joinedDomain -ne $true) -and ($pcnameNow -eq $pcname)) {
    Write-Host "[!] Joining domain '$domain'..."
    Start-Sleep -Seconds 5
    Add-Computer -DomainName $domain -Credential $credUser -Force
    Write-Host "[OK] Joined to domain."
} else {
    Write-Host "[OK] Already joined and named correctly."
}


Start-Sleep -Seconds 3

# ---------------------------------------
# 8. Restart
# ---------------------------------------
Write-Host "`n[✓] All tasks completed. Restarting system in 3 seconds..."
Start-Sleep -Seconds 3
Restart-Computer -Force

