$root_directory = (Get-Item $PSScriptRoot).Parent.FullName;
Set-Location $root_directory/embeddable-dll-service
cmd /c build.bat

$exit_code = $LASTEXITCODE

if ($exit_code -ne 0) {
    Write-Error "Build failed with exit code $exit_code"
    exit $exit_code
}

Write-Host "[+] Build completed successfully!"