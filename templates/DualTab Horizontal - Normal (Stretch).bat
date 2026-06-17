:: Template-Version=v1.2
:: 2026-01-11 Added auto adjusted font size and font spacing for the second tab.
:: 2026-01-11 Added Shadow on tab labels.

::                Template Info
::========================================================
::`  PSD template by kasbandi (www.deviantart.com/kasbandi)
::`  Convert and Edit using ImageMagick.
::` ------------------------------------------------------


::                Template Config
::========================================================
set "use-GlobalConfig=no"
set "custom-FolderName=yes"
 
::--------- Label --------------------------
set "display-FolderName=yes"
set "FolderName-Center=Auto"

set "FolderNameShort-characters-limit=10"
set "FolderNameShort-Font-Color=rgba(255,255,255,0.9)"
set "FolderNameShort-Shadow=20x1"
set "FolderNameShort-Center=-gravity center -geometry -113-135"
set "FolderNameShort-Left=-gravity Northwest -geometry +66+90"

set "FolderNameLong-characters-limit=38"
set "FolderNameLong-Font-Color=rgba(250,250,250,0.8)"
set "FolderNameLong-Shadow=0x1"
set "FolderNameLong-Pos=-gravity Northwest -geometry +35+127"

set "Tab2-Pos=-gravity center -geometry +40-136"
set "Tab2-Shadow=00x7.0"
set "Tab2-Font-Color=rgba(240,240,240,0.8)"

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
set "DualTabH-front=%RCFI%\images\DualTabH-Front.png"
set "DualTabH-frontfx=%RCFI%\images\DualTabH-FrontFX.png"
set "DualTabH-tab1=%RCFI%\images\DualTabH-Tab1.png"
set "DualTabH-tab1fx=%RCFI%\images\DualTabH-Tab1FX.png"
set "DualTabH-tab2=%RCFI%\images\DualTabH-Tab2.png"
set "DualTabH-tab2fx=%RCFI%\images\DualTabH-Tab2FX.png"
set "DualTabH-shadow=%RCFI%\images\DualTabH-DropShadow.png"
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
  %LAYER-TAB2-FX%            ^
  %LAYER-TAB2%               ^
  %LAYER-TAB2-LABEL%         ^
  %LAYER-TAB2-LOGO%          ^
  %LAYER-TAB1-FX%            ^
  %LAYER-TAB1%               ^
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
	if defined FolderName-Font-Color (
		call set "FolderNameShort-Font-Color=%%FolderName-Font-Color%%"
		call set "FolderNameLong-Font-Color=%%FolderName-Font-Color%%"
		call set "Tab2-Font-Color=%%FolderName-Font-Color%%"
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
	 -scale 488x305! ^
	 -brightness-contrast 5x15 ^
	 -modulate 100,110 ^
	 -gravity Northwest ^
	 -geometry +12+155 ^
	 "%DualTabH-front%" ) -compose over -composite ^
	 ( "%DualTabH-frontfx%" -scale 512x512! ) -compose over -composite

set LAYER-TAB1= ( ^
	 "%inputfile%" ^
	 -resize 3x3! ^
	 -resize 1000x1000! ^
	 -scale 512x512! ^
	 -modulate 100,130 ^
	 -brightness-contrast 8x13 ^
	 -blur 0x50 ^
	 "%DualTabH-tab1%" ) -compose over -composite
set LAYER-TAB1-FX= ( "%DualTabH-tab1fx%" -scale 512x512! ) -compose over -composite
  
set LAYER-DROPSHADOW=( "%DualTabH-shadow%" -scale 512x512! ) -compose over -composite
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
	 -scale 152x40^ ^
	 -background none ^
	 -gravity center ^
	 -geometry -114-132 ^
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
    
      
set "FolNamPos-Center=%FolderNameShort-Center%"
set "FolNamPos-Left=%FolderNameShort-Left%"
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
	 -fill %FolderNameShort-Font-Color% ^
	 -density 400 ^
	 -pointsize 7 ^
	 -kerning 1.2 ^
	 %FolNamPos% ^
	 -background none ^
	 label:"%FolNamShort%" ^
	 ( +clone -background BLACK -shadow %FolderNameShort-Shadow%+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %FolderNameShort-Shadow%+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %FolderNameShort-Shadow%+0.6+0.6 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %FolderNameShort-Shadow%+0.6+0.6 ) +swap -background none -layers merge ^
	 ) -composite
   
if %FolNamShortCount% LEQ %FolNamShortLimit% exit /b
set LAYER-FOLDER-NAME-LONG= ^
	 ( ^
	 -font "%RCFI%\resources\BIG_NOODLE_TITLING.ttf"  ^
	 -fill %FolderNameLong-Font-Color% ^
	 -density 400 ^
	 -pointsize 3 ^
	 -kerning 2 ^
	 %FolderNameLong-Pos% ^
	 -background none ^
	 label:"%FolNamLong%" ^
	 ( +clone -background BLACK -shadow %FolderNameLong-Shadow%+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %FolderNameLong-Shadow%+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %FolderNameLong-Shadow%+0.2+0.2 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %FolderNameLong-Shadow%+0.2+0.2 ) +swap -background none -layers merge ^
	 ) -composite

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
	 -brightness-contrast -8x5 ^
	 -blur 0x50 ^
	 "%DualTabH-tab2%" ) -compose over -composite
	 
set LAYER-TAB2-FX= ( "%DualTabH-tab2fx%" -scale 512x512! ) -compose over -composite

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
	 -scale 110x27^ ^
	 -background none ^
	 -gravity center ^
	 -geometry +35-140 ^
	 ) -compose Over -composite
 
if defined LAYER-TAB2-LOGO exit /b

if defined tab2-label set "ChCount=%tab2-label%"&call :ChCount

:: Default Tab2 Font Size
set "Tab2_Font-Size=5"
set "Tab2_Font-Spacing=2"

:: Tab2 FontSize if characters count less than 8
if %ChCount% LSS 8 (
	set "Tab2_Font-Size=6.5"
	set "Tab2_Font-Spacing=3"
)

if %ChCount% GTR 11 call :Tab2-Label-Reducer

set LAYER-TAB2-LABEL= ^
   ( ^
	 -font "%RCFI%\resources\BIG_NOODLE_TITLING.ttf" ^
	 -fill %Tab2-Font-Color% ^
	 -density 400 ^
	 -pointsize %Tab2_Font-Size% ^
	 -kerning %Tab2_Font-Spacing% ^
	 %Tab2-Pos% ^
	 -background none ^
	 label:"%tab2-label%" ^
	 ( +clone -background BLACK -shadow %Tab2-Shadow%+0.1-0.1 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %Tab2-Shadow%+0.1-0.1 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %Tab2-Shadow%+0.1-0.1 ) +swap -background none -layers merge ^
	 ( +clone -background BLACK -shadow %Tab2-Shadow%+0.1-0.1 ) +swap -background none -layers merge ^
	 ) -composite
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

set Tab2_Font-Size=%Tab2fontsize%
set Tab2_Font-Spacing=%Tab2kerning%

echo %TAB% %G_%2ndTab_Characters: %ChCount%   Font size: %Tab2_Font-Size%   Spacing: %Tab2_Font-Spacing%
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