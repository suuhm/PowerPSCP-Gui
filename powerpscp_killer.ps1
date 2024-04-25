#
##       PowerPSCP Gui        ##
## -----------------------------
#
# Easy SCP Transfer Gui for PSCP
#
# (C) 2024 by suuhm (https://github.com/suuhm)
# All rights reserved
#
#
# Find all processes that contain 'pscp.exe' in their name
#

$processes = Get-Process | Where-Object { $_.ProcessName -eq "pscp" }

# Terminate all found processes
foreach ($proc in $processes) {
    Stop-Process -Id $proc.Id -Force -PassThru | Out-String
    Write-Output "Process $($proc.Id) - $($proc.ProcessName) has been terminated."
}

# Check if any processes were found and terminated
if ($processes.Count -eq 0) {
    Write-Output "No processes found."
}
pause
