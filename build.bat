set projectPath=%~dp0
if %projectPath:~-1%==\ set projectPath=%projectPath:~0,-1%

set releasePath=%projectPath%\.release
mkdir "%releasePath%"

for /f "tokens=*" %%a in ('type version.txt') do set version=%%a

del "%releasePath%\qstools-whatpulse_%version%.zip"
"build_tools\7za.exe" a -r "%releasePath%\qstools-whatpulse_%version%.zip" "%projectPath%\*" -xr!.* -xr!build_tools -xr!build.bat -xr!publication_assets 
"build_tools\7za.exe" d "%releasePath%\qstools-whatpulse_%version%.zip" data\*.*
