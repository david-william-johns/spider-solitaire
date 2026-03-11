$setup = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe'
$installPath = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools'
$vcPath = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC'

Write-Host 'Launching VS installer modify...'
$p = Start-Process -FilePath $setup -ArgumentList @(
    'modify',
    '--installPath', $installPath,
    '--add', 'Microsoft.VisualStudio.Workload.VCTools',
    '--includeRecommended',
    '--quiet',
    '--norestart'
) -Wait -PassThru
Write-Host "setup.exe exit code: $($p.ExitCode)"

Write-Host 'Polling for C++ toolchain...'
for ($i = 1; $i -le 60; $i++) {
    if (Test-Path $vcPath) {
        $ver = (Get-ChildItem $vcPath | Select-Object -First 1).Name
        Write-Host "SUCCESS: $vcPath\$ver"
        exit 0
    }
    Write-Host "Poll $i/60 not yet"
    Start-Sleep -Seconds 15
}
Write-Host 'TIMEOUT after 15 minutes'
exit 1
