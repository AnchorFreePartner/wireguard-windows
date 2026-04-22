@echo off

setlocal
set BUILDDIR=%~dp0
cd /d %BUILDDIR%../ || exit /b 1

rmdir /s /q .deps 2> NUL
mkdir .deps || goto :error
cd .deps || goto :error
	call :download go.zip https://download.wireguard.com/windows-toolchain/distfiles/go1.26.2-windows_amd64_2026-04-20.zip 79b5d5ff6f2718dfe25e199cda314d174ecf5bb19f0f2d777aec089d09a12620 "--strip-components 1" || goto :error
	rem Mirror of https://github.com/mstorsjo/llvm-mingw/releases/download/20260311/llvm-mingw-20260311-ucrt-x86_64.zip
	call :download llvm-mingw-ucrt.zip https://download.wireguard.com/windows-toolchain/distfiles/llvm-mingw-20260311-ucrt-x86_64.zip dd4c67d98959479c7be2fb6709ba074475991590848cb9d0eb2620be06b182e1 "--strip-components 1" || goto :error
	rem Mirror of https://imagemagick.org/download/binaries/ImageMagick-7.0.8-42-portable-Q16-x64.zip
call :download imagemagick.zip https://download.wireguard.com/windows-toolchain/distfiles/ImageMagick-7.0.8-42-portable-Q16-x64.zip 584e069f56456ce7dde40220948ff9568ac810688c892c5dfb7f6db902aa05aa "convert.exe colors.xml delegates.xml" || goto :error
rem Mirror of https://sourceforge.net/projects/ezwinports/files/make-4.2.1-without-guile-w32-bin.zip
call :download make.zip https://download.wireguard.com/windows-toolchain/distfiles/make-4.2.1-without-guile-w32-bin.zip 30641be9602712be76212b99df7209f4f8f518ba764cf564262bc9d6e4047cc7 "--strip-components 1 bin" || goto :error
	call :download wireguard-tools.zip https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-06a99cce2c9998f53eb30d2f258a9e5ff286445b.zip b7a73e027cee3127f3cccba8ad3a08ea61ccd42d3ea5c28c548a8e0ec9e10cf6 "--exclude wg-quick --strip-components 1" || goto :error
	call :download wireguard-nt.zip https://download.wireguard.com/wireguard-nt/wireguard-nt-1.0.zip d44f53300e47b44c53e77ee4c495cf061d06b5739f28872432ee1596107a302d || goto :error
copy /y NUL prepared > NUL || goto :error

:success
	echo [+] Success. Dependencies downloaded.
	exit /b 0

:download
	echo [+] Downloading %1
	curl -#fLo %1 %2 || exit /b 1
	echo [+] Verifying %1
	for /f %%a in ('CertUtil -hashfile %1 SHA256 ^| findstr /r "^[0-9a-f]*$"') do if not "%%a"=="%~3" exit /b 1
	echo [+] Extracting %1
	tar -xf %1 %~4 || exit /b 1
	echo [+] Cleaning up %1
	del %1 || exit /b 1
	goto :eof
		
:error
	echo [-] Failed with error #%errorlevel%.
	cmd /c exit %errorlevel%