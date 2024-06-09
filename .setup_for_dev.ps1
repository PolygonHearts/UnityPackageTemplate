Write-Host "--- Checking Python Is Installed ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
# redirect stderr into stdout
$p = &{python -V} 2>&1
# check if an ErrorRecord was returned
$version = if($p -is [System.Management.Automation.ErrorRecord])
{
    # grab the version string from the error message
    $p.Exception.Message
    Write-Host "Python Install not found or installed correctly, please install" -ForegroundColor Yellow -BackgroundColor DarkRed
    exit 1
}


Write-Host "Python Installed Found - $p"

Write-Host "--- Installing Python Packages ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
Write-Host "--- Installing pre-commit ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
pip install pre-commit

Write-Host "--- Installing conventional-pre-commit ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
pip install conventional-pre-commit

Write-Host "--- Ruinning pre-commit setup ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
pre-commit install --hook-type commit-msg

Write-Host "--- Done! ---" -ForegroundColor Cyan -BackgroundColor DarkBlue
Start-Sleep -Seconds 3