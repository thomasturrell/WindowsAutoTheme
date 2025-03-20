# PowerShell script to calculate sunrise/sunset and update Task Scheduler dynamically

function Get-SunTimes {
    param (
        [double]$Latitude = 51.5074,  # London Latitude
        [double]$Longitude = -0.1278, # London Longitude
        [datetime]$Date = (Get-Date)  # Default: Today
    )

    # Constants
    $Zenith = 90.833  # Standard zenith for sunrise/sunset
    $LongitudeHour = $Longitude / 15

    # Calculate the day of the year
    $DayOfYear = $Date.DayOfYear

    # Approximate time of sunrise and sunset in hours (UTC)
    $SunriseApproxTime = $DayOfYear + (($LongitudeHour + 6) / 24)
    $SunsetApproxTime  = $DayOfYear + (($LongitudeHour + 18) / 24)

    function Calculate-SunTime {
        param ($ApproxTime)

        # Mean anomaly
        $M = (0.9856 * $ApproxTime) - 3.289

        # True longitude
        $L = $M + (1.916 * [math]::Sin([math]::PI * $M / 180)) + (0.020 * [math]::Sin([math]::PI * 2 * $M / 180)) + 282.634
        if ($L -gt 360) { $L -= 360 }
        if ($L -lt 0)   { $L += 360 }

        # Right ascension
        $RA = [math]::Atan(0.91764 * [math]::Tan([math]::PI * $L / 180)) * 180 / [math]::PI
        if ($RA -gt 360) { $RA -= 360 }
        if ($RA -lt 0)   { $RA += 360 }

        # RA quadrant correction
        $LQuadrant  = [math]::Floor($L / 90) * 90
        $RAQuadrant = [math]::Floor($RA / 90) * 90
        $RA = $RA + ($LQuadrant - $RAQuadrant)
        $RA = $RA / 15  # Convert to hours

        # Declination of the sun
        $SinDec = 0.39782 * [math]::Sin([math]::PI * $L / 180)
        $CosDec = [math]::Cos([math]::Asin($SinDec))

        # Local hour angle
        $CosH = ([math]::Cos([math]::PI * $Zenith / 180) - ($SinDec * [math]::Sin([math]::PI * $Latitude / 180))) / ($CosDec * [math]::Cos([math]::PI * $Latitude / 180))

        if ($CosH -gt 1) { return "Sun does not rise" }
        if ($CosH -lt -1) { return "Sun does not set" }

        $H = if ($ApproxTime -eq $SunriseApproxTime) { 360 - [math]::Acos($CosH) * 180 / [math]::PI } else { [math]::Acos($CosH) * 180 / [math]::PI }
        $H = $H / 15

        # Local mean time
        $T = $H + $RA - (0.06571 * $ApproxTime) - 6.622

        # UTC time
        $UT = $T - $LongitudeHour
        if ($UT -gt 24) { $UT -= 24 }
        if ($UT -lt 0) { $UT += 24 }

        # Convert to local London time
        $LocalTime = [datetime]$Date.Date + [timespan]::FromHours($UT + (Get-TimeZone).BaseUtcOffset.TotalHours)
        return $LocalTime.ToString("HH:mm")
    }

    return @{
        Sunrise = Calculate-SunTime $SunriseApproxTime
        Sunset  = Calculate-SunTime $SunsetApproxTime
    }
}

# Get today's sunrise/sunset times
$SunTimes = Get-SunTimes
$SunriseTime = $SunTimes.Sunrise
$SunsetTime  = $SunTimes.Sunset

# Define the task names
$SunriseTask = "SwitchToLightMode"
$SunsetTask = "SwitchToDarkMode"
$ScriptPath = "C:\path\to\change_theme.ps1"

# Update Task Scheduler for Sunrise
schtasks /create /tn $SunriseTask /tr "powershell.exe -ExecutionPolicy Bypass -File `"$ScriptPath`" light" /sc once /st $SunriseTime /f

# Update Task Scheduler for Sunset
schtasks /create /tn $SunsetTask /tr "powershell.exe -ExecutionPolicy Bypass -File `"$ScriptPath`" dark" /sc once /st $SunsetTime /f
