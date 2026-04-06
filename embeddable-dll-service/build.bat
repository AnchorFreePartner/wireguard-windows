@echo off
rem SPDX-License-Identifier: MIT
rem Copyright (C) 2019-2021 WireGuard LLC. All Rights Reserved.

setlocal
set BUILDDIR=%~dp0
set PATH=%BUILDDIR%..\.deps\llvm-mingw\bin;%BUILDDIR%..\.deps\go\bin;%PATH%
set PATHEXT=.exe
cd /d %BUILDDIR% || exit /b 1

if exist ..\.deps\prepared goto :getversion
:installdeps
	call .\installdependencies.bat || goto :error
	
:getversion
	for /f "tokens=3" %%a in ('findstr /r "Number.*=.*[0-9.]*" ..\version\version.go') do set WIREGUARD_VERSION=%%a
	set WIREGUARD_VERSION=%WIREGUARD_VERSION:"=%
	for /f "tokens=1-4" %%a in ("%WIREGUARD_VERSION:.= % 0 0 0") do set WIREGUARD_VERSION_ARRAY=%%a,%%b,%%c,%%d

:build
	set GOOS=windows
	set GOARM=7
	set GOPATH=%BUILDDIR%..\.deps\gopath
	set GOROOT=%BUILDDIR%..\.deps\go
	set CGO_ENABLED=1
	set CGO_CFLAGS=-O3 -Wall -Wno-unused-function -Wno-switch -std=gnu11 -DWINVER=0x0601
	call :build_plat x86 i686 386 || goto :error
	call :build_plat amd64 x86_64 amd64 || goto :error
	call :build_plat arm64 aarch64 arm64 || goto :error

:success
	echo [+] Success
	exit /b 0

:build_plat
	set CC=%~2-w64-mingw32-gcc
	set GOARCH=%~3
	mkdir %1 >NUL 2>&1
	echo [+] Assembling resources %1
	%~2-w64-mingw32-windres -I "..\.deps\wireguard-nt\bin\%~1" -DWIREGUARD_VERSION_ARRAY=%WIREGUARD_VERSION_ARRAY% -DWIREGUARD_VERSION_STR=%WIREGUARD_VERSION% -i resources.rc -o "resources_%~3.syso" -O coff -c 65001 || exit /b %errorlevel%
	echo [+] Building library %1
	go build -buildmode c-shared -ldflags="-w -s" -trimpath -v -o "%~1/tunnel.dll" || exit /b 1
	echo [+] Building library %1 completed
	del "%~1\tunnel.h"
	goto :eof

:error
	echo [-] Failed with error #%errorlevel%.
	cmd /c exit %errorlevel%