@echo off

setlocal
set BUILDDIR=%~dp0
cd /d %BUILDDIR%../ || exit /b 1

rmdir /s /q .deps 2> NUL
mkdir .deps || goto :error
cd .deps || goto :error
call :download go.zip https://go.dev/dl/go1.26.1.windows-amd64.zip 9b68112c913f45b7aebbf13c036721264bbba7e03a642f8f7490c561eebd1ecc || goto :error
rem Mirror of https://github.com/mstorsjo/llvm-mingw/releases/download/20201020/llvm-mingw-20201020-msvcrt-x86_64.zip
call :download llvm-mingw-msvcrt.zip https://download.wireguard.com/windows-toolchain/distfiles/llvm-mingw-20201020-msvcrt-x86_64.zip 2e46593245090df96d15e360e092f0b62b97e93866e0162dca7f93b16722b844 || goto :error
rem Mirror of https://imagemagick.org/download/binaries/ImageMagick-7.0.8-42-portable-Q16-x64.zip
call :download imagemagick.zip https://download.wireguard.com/windows-toolchain/distfiles/ImageMagick-7.0.8-42-portable-Q16-x64.zip 584e069f56456ce7dde40220948ff9568ac810688c892c5dfb7f6db902aa05aa "convert.exe colors.xml delegates.xml" || goto :error
rem Mirror of https://sourceforge.net/projects/ezwinports/files/make-4.2.1-without-guile-w32-bin.zip
call :download make.zip https://download.wireguard.com/windows-toolchain/distfiles/make-4.2.1-without-guile-w32-bin.zip 30641be9602712be76212b99df7209f4f8f518ba764cf564262bc9d6e4047cc7 "--strip-components 1 bin" || goto :error
call :download wireguard-tools.zip https://git.zx2c4.com/wireguard-tools/snapshot/wireguard-tools-1ee37b8e4833a25efe6f1fc0d5bdcb476148f4ba.zip ed0739bc3e5a7021a59d4cc4fc63e5fb60a0cb8628d30515a747bfbdcf1fdb0a "--exclude wg-quick --strip-components 1" || goto :error
call :download wireguard-nt.zip https://download.wireguard.com/wireguard-nt/wireguard-nt-0.10.1.zip 772c0b1463d8d2212716f43f06f4594d880dea4f735165bd68e388fc41b81605 || goto :error
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