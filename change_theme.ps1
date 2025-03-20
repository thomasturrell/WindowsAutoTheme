# PowerShell script to switch Windows theme between light and dark

param (
    [string]$mode
)

$RegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
$ValueName = "AppsUseLightTheme"

if ($mode -eq "light") {
    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value 1
    Write-Output "Switched to Light Mode"
} elseif ($mode -eq "dark") {
    Set-ItemProperty -Path $RegistryPath -Name $ValueName -Value 0
    Write-Output "Switched to Dark Mode"
} else {
    Write-Output "Invalid mode. Use 'light' or 'dark'."
    exit 1
}

# Restart Explorer to apply changes
Stop-Process -Name "explorer" -Force
Start-Process "explorer"
