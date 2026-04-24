$root_directory = (Get-Item $PSScriptRoot).Parent.FullName;
Push-Location
Set-Location $root_directory/embeddable-dll-service

# Pin Go's buildvcs stamping to THIS repo's gitdir; prevents walking up into a parent repo
# (e.g. when this checkout is used as a git submodule of another repo).
$savedGitDir = $env:GIT_DIR
$savedGitWorkTree = $env:GIT_WORK_TREE
try {
    $env:GIT_DIR = (& git -C $root_directory rev-parse --absolute-git-dir).Trim()
    $env:GIT_WORK_TREE = (& git -C $root_directory rev-parse --show-toplevel).Trim()
    cmd /c build.bat
    $exit_code = $LASTEXITCODE
} finally {
    $env:GIT_DIR = $savedGitDir
    $env:GIT_WORK_TREE = $savedGitWorkTree
}

if ($exit_code -ne 0) {
    Write-Error "Build failed with exit code $exit_code"
	Pop-Location
    exit $exit_code
}

Write-Host "[+] Build completed successfully!"
Pop-Location