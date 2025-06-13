# This is the correct script.
# It is designed to find your "1.png", "2.png", etc., files and rename them.

Write-Host "Starting file renaming process for numbered images..." -ForegroundColor Green

# This map links your numbered files ("1.png") to their new, descriptive names ("lab-architecture.png").
$fileMap = @{
    "1.png"  = "lab-architecture.png";
    "2.png"  = "windows-10-vm-setup.png";
    "3.png"  = "windows-10-add-user.png";
    "4.png"  = "kali-prebuilt-vm-page.png";
    "5.png"  = "kali-vm-settings.png";
    "6.png"  = "windows-server-vm-settings.png";
    "7.png"  = "windows-server-os-selection.png";
    "8.png"  = "ubuntu-vm-settings.png";
    "9.png"  = "ubuntu-login-motd.png";
    "10.png" = "ubuntu-server-profile-setup.png";
    "11.png" = "virtualbox-nat-network-setup.png";
    "12.png" = "virtualbox-vm-list.png";
    "13.png" = "ubuntu-network-config.png";
    "14.png" = "ubuntu-update-upgrade.png";
    "15.png" = "splunk-download-page.png";
    "16.png" = "ubuntu-edit-netplan-command.png";
    "17.png" = "virtualbox-shared-folders.png";
    "18.png" = "ubuntu-install-guest-utils.png";
    "19.png" = "ubuntu-mkdir-share.png";
    "20.png" = "ubuntu-adduser-to-vboxsf.png";
    "21.png" = "ubuntu-mount-shared-folder.png";
    "22.png" = "splunk-cli-start-server.png";
    "23.png" = "splunk-login-page.png";
    "24.png" = "splunk-uf-download-page.png";
    "25.png" = "splunk-uf-installer-setup.png";
    "26.png" = "sysmon-download-page.png";
    "27.png" = "sysmon-config-repo.png";
    "28.png" = "sysmon-config-save-as.png";
    "29.png" = "sysmon-install-command.png";
    "30.png" = "endpoint-inputs-conf.png";
    "31.png" = "splunk-create-index.png";
    "32.png" = "splunk-receive-port.png";
    "33.png" = "splunk-forwarder-service.png";
    "34.png" = "splunk-detect-target-pc-host.png";
    "35.png" = "splunk-detect-sources.png";
    "36.png" = "windows-server-rename-pc.png";
    "37.png" = "splunk-detect-hosts.png";
    "38.png" = "windows-server-network-config.png";
    "39.png" = "windows-server-add-roles.png";
    "40.png" = "windows-server-promote-dc.png";
    "41.png" = "windows-server-create-domain.png";
    "42.png" = "windows-server-domain-login.png";
    "43.png" = "windows-server-ad-users-computers.png";
    "44.png" = "windows-10-join-domain.png";
    "45.png" = "windows-10-rdp-access-setup.png";
    "46.png" = "kali-network-config.png";
    "47.png" = "kali-ping-test.png";
    "48.png" = "kali-install-tools.png";
    "49.png" = "kali-rockyou-setup.png";
    "50.png" = "kali-password-list-setup.png";
    "51.png" = "kali-rdp-brute-force.png";
    "52.png" = "event-viewer-logon-list.png";
    "53.png" = "ultimate-security-event-id-4634.png";
    "54.png" = "event-viewer-logon-failure-4625.png";
    "55.png" = "event-viewer-successful-logon-4624.png";
    "56.png" = "splunk-detect-logon-failure-4625.png";
    "57.png" = "atomic-defender-exclusion.png";
    "58.png" = "atomic-red-team-install.png";
    "59.png" = "atomic-red-team-folder.png";
    "60.png" = "mitre-t1136-create-account.png";
    "61.png" = "atomic-invoke-t1136.png";
    "62.png" = "ultimate-security-event-id-4720.png";
    "63.png" = "splunk-detect-event-id-4720.png"
}

# Loop through each entry in our map
foreach ($entry in $fileMap.GetEnumerator()) {
    $originalFile = $entry.Name
    $newFile = $entry.Value
    
    if (Test-Path $originalFile) {
        try {
            Rename-Item -Path $originalFile -NewName $newFile -ErrorAction Stop
            Write-Host "Renamed '$originalFile' -> '$newFile'" -ForegroundColor Cyan
        }
        catch {
            Write-Host "ERROR renaming '$originalFile': $_" -ForegroundColor Red
        }
    }
}

Write-Host "`nRenaming process complete. You can now upload these files to GitHub." -ForegroundColor Green
Read-Host "Press Enter to exit..."