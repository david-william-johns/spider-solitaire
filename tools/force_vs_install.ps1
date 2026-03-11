# Self-elevate to administrator if not already elevated
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host 'Requesting admin elevation...'
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`""
    exit 0
}

Write-Host 'Running as Administrator - OK'

# Clear PendingFileRenameOperations (requires admin)
Write-Host 'Clearing PendingFileRenameOperations...'
Remove-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
$pfr = Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name PendingFileRenameOperations -ErrorAction SilentlyContinue
if ($pfr) { Write-Host 'STILL present - cannot clear' } else { Write-Host 'Cleared OK' }

# Also stop Spooler so it does not recreate the key
Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
Write-Host 'Print Spooler stopped'

# Run VS installer with properly quoted path
Write-Host 'Launching VS C++ workload install...'
$setup = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'
$installArgs = 'modify --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --quiet --norestart'
$p = Start-Process -FilePath $setup -ArgumentList $installArgs -Wait -PassThru
Write-Host "setup.exe exit code: $($p.ExitCode)"

# Restart Spooler now that VS has been triggered
Start-Service -Name Spooler -ErrorAction SilentlyContinue
Write-Host 'Print Spooler restarted'

# Poll for result
$vcPath = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC'
Write-Host 'Polling for C++ toolchain (up to 15 min)...'
for ($i = 1; $i -le 60; $i++) {
    if (Test-Path $vcPath) {
        $ver = (Get-ChildItem $vcPath | Select-Object -First 1).Name
        Write-Host "SUCCESS: MSVC $ver installed"
        Read-Host 'Press Enter to close'
        exit 0
    }
    Write-Host "Poll $i/60 not yet..."
    Start-Sleep -Seconds 15
}
Write-Host 'TIMEOUT - C++ workload did not appear after 15 minutes'
Read-Host 'Press Enter to close'
exit 1
