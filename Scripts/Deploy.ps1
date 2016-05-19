Param(
  $vmName,
  $sourceFile
)

$ErrorActionPreference = "Stop"

Set-Item wsman:\localhost\client\trustedhosts * -force

Start-Sleep -s 30
Invoke-Command -ComputerName $vmName -ScriptBlock { Get-ChildItem C:\ }
Invoke-Command -ComputerName $vmName -ScriptBlock { netsh advfirewall firewall set rule group=”File and Printer Sharing” new enable=Yes }

$root = "\\" + $vmName + "\c$\AppSetup.msi"

Copy-Item $sourceFile $root

Invoke-Command -ComputerName $vmName -ScriptBlock { Get-ChildItem C:\ }

# IIS add features
Invoke-Command -ComputerName $vmName -ScriptBlock { import-module servermanager ;  Add-WindowsFeature Web-Server,Web-Asp-Net45,Web-Mgmt-Console ; Remove-Website "Default Web Site"}

Invoke-Command -ComputerName $vmName -ScriptBlock { & cmd /c "msiexec.exe /i c:\AppSetup.msi" /qn ADVANCED_OPTIONS=1 CHANNEL=100 }
