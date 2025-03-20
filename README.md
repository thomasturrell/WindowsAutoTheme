# Windows Auto Theme

Automatically switches between light and dark mode on Windows based on sunrise and sunset times.

## Features
- Uses PowerShell to calculate sunrise and sunset times **offline** (no internet required).
- Updates Task Scheduler dynamically to trigger **exactly at sunrise and sunset**.
- Runs automatically **on login and when unlocking** the workstation.
- Energy-efficient: **Does not wake the laptop** when sleeping.

## Installation
### 1. Clone the Repository
```sh
git clone https://github.com/YOUR_USERNAME/WindowsAutoTheme.git
cd WindowsAutoTheme
```

### 2. Set Execution Policy (One-Time Setup)
To allow running PowerShell scripts, execute:
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

### 3. Run the Setup Script
This will create a scheduled task to update the sunrise/sunset schedule automatically.
```powershell
.\setup_task.ps1
```

## How It Works
1. The **`update_scheduler.ps1`** script calculates **sunrise and sunset** times **locally** based on latitude and longitude.
2. It then updates **Task Scheduler** to run the theme-changing script at those exact times.
3. The **`setup_task.ps1`** script ensures the schedule updates **on logon and unlock**.
4. The **`change_theme.ps1`** script switches between light and dark mode when triggered.

## Manual Theme Switching
You can manually switch themes using:
```powershell
.\change_theme.ps1 light
.\change_theme.ps1 dark
```

## Uninstallation
To remove the scheduled tasks and disable automatic theme switching:
```powershell
schtasks /delete /tn "UpdateSunsetSchedule" /f
schtasks /delete /tn "SwitchToLightMode" /f
schtasks /delete /tn "SwitchToDarkMode" /f
```

## License
This project is licensed under the **Apache-2.0 License**.

## Contributions
Feel free to submit pull requests or open issues for improvements!

---
🚀 **Enjoy automatic Windows theme switching!**

