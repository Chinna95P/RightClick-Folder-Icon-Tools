:: Template-Version=v1.1
:: 2025-12-24 Added auto adjusted font size and font spacing for the second tab.

::                Template Info
::========================================================
::`  PSD template by Redcat0 (www.deviantart.com/redcat0)
::`  Convert and Edit using ImageMagick.
::` ------------------------------------------------------


::                Template Config
::========================================================
set "use-GlobalConfig=no"
set "custom-FolderName=yes"
 
::--------- Label --------------------------
set "display-FolderName=yes"
set "FolderNameShort-characters-limit=10"
set "FolderNameLong-characters-limit=38"
set "FolderName-Center=Auto"
set "FolderName-Font-Color=rgba(255,255,255,0.9)"
set "FolderName-Pos-Short-Center=-gravity center -geometry +205-69"
set "Foldername-Pos-Short-Left=-gravity Northwest -geometry +422+92"
set "Foldername-Pos-Long=-gravity Northwest -geometry +382-3"
set "FolderName-Pos-Tab2=-gravity center -geometry +207+88"

set "Tab2_FontSize=5"
set "Tab2_FontSpacing=3"

::--------- Movie Info ---------------------
set "display-movieinfo=yes"
set "show-Rating=yes"
set "preferred-rating=imdb"
set "show-Genre=yes"
set "genre-characters-limit=26"

::--------- Additional Art -----------------
set "use-Logo-instead-FolderName=yes"
set "display-clearArt=no"
::========================================================


::                Images Source
::========================================================
set "DualTabV-front=%RCFI%\images\DualTabV-Front.png"
set "DualTabV-frontfx=%RCFI%\images\DualTabV-FrontFX.png"
set "DualTabV-tab1=%RCFI%\images\DualTabV-Tab1.png"
set "DualTabV-tab1fx=%RCFI%\images\DualTabV-Tab1FX.png"
set "DualTabV-tab2=%RCFI%\images\DualTabV-Tab2.png"
set "DualTabV-tab2fx=%RCFI%\images\DualTabV-Tab2FX.png"
set "DualTabV-shadow=%RCFI%\images\DualTabV-DropShadow.png"
set "star-image=%rcfi%\images\star.png"  
set "canvas=%rcfi%\images\- canvas.png"         
::========================================================
setlocal
chcp 65001 >nul
call :LAYER-BASE
call :LAYER-RATING
call :LAYER-GENRE
call :LAYER-LOGO
call :LAYER-CLEARART
call :LAYER-FOLDER_NAME

 "%Converter%"              ^
  %LAYER-BACKGROUND%         ^
  %LAYER-TAB2%               ^
  %LAYER-TAB2-LABEL%         ^
  %LAYER-TAB2-LOGO%          ^
  %LAYER-TAB2-FX%            ^
  %LAYER-TAB1%               ^
  %LAYER-TAB1-FX%            ^
  %LAYER-LOGO-IMAGE%         ^
  %LAYER-FOLDER-NAME-SHORT%  ^
  %LAYER-FOLDER-NAME-LONG%   ^
  %LAYER-POSTER-MAIN%        ^
  %LAYER-CLEARART-IMAGE%     ^
  %LAYER-STAR-IMAGE%         ^
  %LAYER-RATING%             ^
  %LAYER-GENRE%              ^
  %LAYER-ICON-SIZE%          ^
 "%OutputFile%"

 "%Converter%"              ^
  %LAYER-BACKGROUND%         ^
  %LAYER-DROPSHADOW%         ^
  ( "%OutputFile%" -scale 512x512! ) -compose over -composite ^
  %LAYER-ICON-SIZE%          ^
 "%OutputFile%"
endlocal
exit /b



:::::::::::::::::::::::::::   CODE START   ::::::::::::::::::::::::::::::::


:LAYER-BASE
if /i "%use-GlobalConfig%"=="yes" (
	for /f "usebackq tokens=1,2 delims==" %%A in ("%RCFI.templates.ini%") do (
		if /i not "%%B"=="" if /i not %%B EQU ^" %%A=%%B
	)
)

rem variable couldn't pass the 3rd call/start. (?)
set "multi-FolderName=yes"
set "cfn1=%RCFI%\resources\custom_foldername.txt"
set "cfn2=%RCFI%\resources\custom_foldername2.txt"
if /i "%custom-FolderName%"=="yes" (
	start /WAIT "" "%RCFI%\resources\custom_foldername.bat"
	if exist "%cfn1%" (
		for /f "usebackq tokens=* delims=" %%C in ("%cfn1%") do %%C
		del /q "%cfn1%"
	)
	if exist "%cfn2%" (
		for /f "usebackq tokens=* delims=" %%C in ("%cfn2%") do set tab2-label=%%C
		call :LAYER-TAB2
		del /q "%cfn2%"
	)
)

set LAYER-BACKGROUND= ( ^
	"%canvas%" ^
	-scale 512x512! ^
	-background none ^
	-extent 512x512 ) -compose Over

set LAYER-POSTER-MAIN= ( ^
	 "%inputfile%" ^
	 -resize "372x482^" -gravity South -extent 372x482 ^
	 -brightness-contrast 5x15 ^
	 -modulate 100,110 ^
	 -gravity Northwest ^
	 -geometry +51+4 ^
	 "%DualTabV-front%" ) -compose over -composite ^
	 ( "%DualTabV-frontfx%" -scale 512x512! ) -compose over -composite

set LAYER-TAB1= ( ^
	 "%inputfile%" ^
	 -resize 3x3! ^
	 -resize 1000x1000! ^
	 -scale 512x512! ^
	 -modulate 100,130 ^
	 -brightness-contrast 8x13 ^
	 -blur 0x50 ^
	 "%DualTabV-tab1%" ) -compose over -composite
set LAYER-TAB1-FX= ( "%DualTabV-tab1fx%" -scale 512x512! ) -compose over -composite
  
set LAYER-DROPSHADOW=( "%DualTabV-shadow%" -scale 512x512! ) -compose over -composite
set LAYER-ICON-SIZE=-define icon:auto-resize="%TemplateIconSize%"
exit /b
 
:LAYER-RATING
if /i not "%display-movieinfo%" EQU "yes" exit /b
if not exist "*.nfo" (exit /b) else call "%RCFI%\resources\extract-NFO.bat"
if /i not "%Show-Rating%" EQU "yes" exit /b

set LAYER-STAR-IMAGE= ( ^
	 "%star-image%" ^
	 -scale 88x84! ^
	 -gravity Northwest ^
	 -geometry +40+404 ^
	 ( +clone -background BLACK -shadow 0x1.2+4+6 ) ^
	 +swap -background none -layers merge -extent 512x512 ^
	 ) -compose Over -composite
	 if not defined rating exit /b

set LAYER-RATING= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill rgba(0,0,0,0.9) ^
	 -density 400 ^
	 -pointsize 6 ^
	 -kerning 0 ^
	 label:"%rating%" ^
	 -gravity Northwest ^
	 -geometry +52+429  ^
	 ( +clone -background ORANGE -shadow 30x1.2+2+2 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 30x1.2-2-2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2-2+2 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 30x1.2+2-2 ) +swap -background none -layers merge ^
	 ) -compose Over -composite 
exit /b


:LAYER-GENRE
if /i not "%display-movieinfo%" EQU "yes" exit /b
if /i not "%Show-Genre%" EQU "yes" exit /b
if not defined GENRE exit /b

set LAYER-GENRE= ( ^
	 -font "%rcfi%\resources\ANGIE-BOLD.TTF" ^
	 -fill BLACK ^
	 -density 400 ^
	 -pointsize 5 ^
	 -kerning 0 ^
	 -gravity Northwest ^
	 -geometry +113+440 ^
	 label:"%genre%" ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.5+2.5 ) +swap -background none -layers merge ^
	 ( +clone -background YELLOW -shadow 70x1.2-2.5-2.5 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2-2.5+2.5 ) +swap -background none -layers merge ^
	 ( +clone -background ORANGE -shadow 70x1.2+2.5-2.5 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK  -shadow 0x0.2+4+5 ) +swap -background none -layers merge ^
	 ) -composite 
exit /b
 
:LAYER-LOGO
if /i not "%use-Logo-instead-folderName%"=="yes" exit /b

if /i not "%custom-FolderName-HaveTheLogo%"=="yes" if exist "*logo.png" (
	for %%D in (*logo.png) do set "Logo=%%~fD"&set "LogoName=%%~nxD"
) else exit /b

echo %TAB% %G_%Logo        :%ESC%%LogoName%%ESC%

set LAYER-LOGO-IMAGE= ( "%Logo%" ^
	 -trim +repage ^
	 -scale 167x60^ ^
	 -background none ^
	 -gravity center ^
	 -geometry +200-72 ^
	 -rotate 90 ^
	 ) -compose Over -composite
exit /b
 
:LAYER-CLEARART
if /i not "%display-clearArt%"=="yes" exit /b

if exist "*clearart.png" (
	for %%D in (*clearart.png) do set "ClearArt=%%~fD"&set "ClearArtName=%%~nxD"
) else exit /b

echo %TAB% %G_%Clear Art   :%ESC%%ClearArtName%%ESC%

set LAYER-CLEARART-IMAGE= ( "%clearart%" ^
	 -trim +repage ^
	 -scale 380x ^
	 -background none ^
	 -gravity SouthWest ^
	 -geometry -250-320 ^
	 ( +clone -background BLACK -shadow 40x40+10+10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40-10-10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40-10+10 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 40x40+10-10 ) +swap -background none -layers merge ^
	 ) -compose Over -composite
exit /b

:LAYER-FOLDER_NAME
if /i "%display-FolderName%"=="no" exit /b
if defined LAYER-LOGO-IMAGE exit /b

if /i not "%custom-FolderName%"=="yes" for %%F in ("%cd%") do set "foldername=%%~nxF"
if not defined foldername set "foldername=%cd:\=\\            %"&set "FolderNameLong-characters-limit=0"

set "FolNamShort=%foldername%"
set "FolNamShortLimit=%FolderNameShort-characters-limit%"
set /a "FolNamShortLimit=%FolNamShortLimit%+1"
set "FolNamLong=%foldername%"
set "FolNamLongLimit=%FolderNameLong-characters-limit%"
set /a "FolNamLongLimit=%FolNamLongLimit%+1"

:GetInfo-FolderName-Short
set /a FolNamShortCount+=1
if not "%_FolNamShort%"=="%FolderName%" (
	call set "_FolNamShort=%%FolderName:~0,%FolNamShortCount%%%"
	goto GetInfo-FolderName-Short
)
set /A "FolNamShortLimiter=%FolNamShortLimit%-4"
if %FolNamShortCount% GTR %FolNamShortLimit% call set "FolNamShort=%%FolderName:~0,%FolNamShortLimiter%%%..."
    
      
set "FolNamPos-Center=%FolderName-Pos-Short-Center%"
set "FolNamPos-Left=%Foldername-Pos-Short-Left%"
if %FolNamShortCount% LEQ %FolNamShortLimiter% (set "FolNamPos=%FolNamPos-Left%") else (set "FolNamPos=%FolNamPos-Center%")
if /i "%FolderName-Center%"=="yes" set "FolNamPos=%FolNamPos-Center%"
if /i "%FolderName-Center%"=="no"  set "FolNamPos=%FolNamPos-Left%"


:GetInfo-FolderName-Long
set /a FolNamLongCount+=1
if not "%_FolNamLong%"=="%FolderName%" (
	call set "_FolNamLong=%%FolderName:~0,%FolNamLongCount%%%"
	goto GetInfo-FolderName-Long
)
set /A "FolNamLongLimiter=%FolNamLongLimit%-4"
if %FolNamLongCount% GTR %FolNamLongLimit% call set "FolNamLong=%%FolderName:~0,%FolNamLongLimiter%%%..."

set LAYER-FOLDER-NAME-SHORT= ^
	 ( ^
	 -font "%RCFI%\resources\BIG_NOODLE_TITLING.ttf" ^
	 -fill %FolderName-Font-Color% ^
	 -density 400 ^
	 -pointsize 7 ^
	 -kerning 1.2 ^
	 %FolNamPos% ^
	 -background none ^
	 label:"%FolNamShort%" ^
	 ( +clone -background BLACK -shadow 00x2+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 00x2-0.6-0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 00x2-0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 00x2+0.6-0.6 ) +swap -background none -layers merge ^
	 -rotate 90 ) -composite
   
if %FolNamShortCount% LEQ %FolNamShortLimit% exit /b
set LAYER-FOLDER-NAME-LONG= ^
	 ( ^
	 -font "%RCFI%\resources\BIG_NOODLE_TITLING.ttf"  ^
	 -fill %FolderName-Font-Color% ^
	 -density 400 ^
	 -pointsize 2.8 ^
	 -kerning 2 ^
	  %Foldername-Pos-Long% ^
	 -background none ^
	 label:"%FolNamLong%" ^
	 ( +clone -background BLACK -shadow 0x5+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 0x5-0.2-0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 0x5-0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 0x5+0.2-0.2 ) +swap -background none -layers merge ^
	 -rotate 90 ) -composite

if "%FolderNameLong-characters-limit%"=="0" set "LAYER-FOLDER-NAME-LONG="
exit /b


:LAYER-TAB2
set LAYER-TAB2= ( ^
	 "%inputfile%" ^
	 -resize 3x3! ^
	 -resize 1000x1000! ^
	 -scale 512x512! ^
	 -modulate 100,130 ^
	 -brightness-contrast 8x13 ^
	 -brightness-contrast -2x0 ^
	 -blur 0x50 ^
	 "%DualTabV-tab2%" ) -compose over -composite
	 
set LAYER-TAB2-FX= ( "%DualTabV-tab2fx%" -scale 512x512! ) -compose over -composite

set tab2-label=%tab2-label:"=%
set "Logo2="
set "Logo2-Name="
set "LAYER-TAB2-LOGO="

if exist "%tab2-label%" for %%I in ("%tab2-label%") do (
	for %%X in (%ImageSupport%) do if "%%X"=="%%~xI" (
		set "Logo2=%%~fI"
		set "Logo2-Name=%%~nxI"
	)
)
 
if defined Logo2 set LAYER-TAB2-LOGO= ^
    ( "%Logo2%" ^
	 -trim +repage ^
	 -scale 150x45^ ^
	 -background none ^
	 -gravity center ^
	 -geometry +205+90 ^
	 -rotate 90 ^
	 ) -compose Over -composite

if defined LAYER-TAB2-LOGO exit /b

:: Adjusting font size and characters spacing base on characters count

if defined tab2-label set "ChCount=%tab2-label%"&call :ChCount
if %ChCount% GTR 11 call :Tab2-Label-Reducer

set LAYER-TAB2-LABEL= ^
   ( ^
	 -font "%RCFI%\resources\BIG_NOODLE_TITLING.ttf" ^
	 -fill %FolderName-Font-Color% ^
	 -density 400 ^
	 -pointsize %Tab2_FontSize% ^
	 -kerning %Tab2_FontSpacing% ^
	 -gravity center -geometry +207+88 ^
	 -background none ^
	 label:"%tab2-label%" ^
	 ( +clone -background BLACK -shadow 00x7.0+0.1-0.1 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 00x7.0-0.1-0.1 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 00x7.0-0.1+0.1 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow 00x7.0+0.1-0.1 ) +swap -background none -layers merge ^
	 -rotate 90 ) -composite
exit /b

:Tab2-Label-Reducer
set /a len=%ChCount%
set /a refLen=9
set /a baseFont=45
set /a baseKerning=40

:: step count
set /a stepFont=(50-45)/(15-11)
set /a stepKerning=(30-10)/(15-11)

:: dynamic count
set /a Tab2fontsize=baseFont - (len - refLen) * stepFont
set /a Tab2kerning=baseKerning - (len - refLen) * stepKerning

if %Tab2fontsize% GEQ 10 set Tab2fontsize=%Tab2fontsize:~0,-1%.%Tab2fontsize:~-1%
if %Tab2kerning% GEQ 10 set Tab2kerning=%Tab2kerning:~0,-1%.%Tab2kerning:~-1%
if %ChCount% GTR 15 set Tab2kerning=0

set Tab2_FontSize=%Tab2fontsize%
set Tab2_FontSpacing=%Tab2kerning%

echo %TAB% %G_%2ndTab_Characters: %ChCount%   Font size: %Tab2_FontSize%   Spacing: %Tab2_FontSpacing%
exit /b

:ChCount
set /a ChCounting+=1
if not defined ChCount if ChCounting EQU 1 (
	set ChCount=0
	exit /b
	) else (
	set /a ChCount=%ChCounting%-1
	set ChCounting=0
	exit /b
	)
set "ChCount=%ChCount:~1%"
goto ChCount
:::::::::::::::::::::::::::   CODE END   ::::::::::::::::::::::::::::::::::