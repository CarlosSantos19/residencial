@echo off
REM Script para crear backup de archivos importantes del proyecto
REM Conjunto Residencial Aralia de Castilla

echo ========================================
echo   BACKUP - Conjunto Residencial
echo ========================================
echo.

REM Crear carpeta de backups si no existe
if not exist "backups" mkdir backups

REM Crear carpeta con fecha actual
set FECHA=%date:~-4%%date:~3,2%%date:~0,2%
set HORA=%time:~0,2%%time:~3,2%%time:~6,2%
set HORA=%HORA: =0%
set CARPETA_BACKUP=backups\backup-%FECHA%-%HORA%

mkdir "%CARPETA_BACKUP%"

echo Creando backup en: %CARPETA_BACKUP%
echo.

REM Copiar archivos importantes
echo [1/5] Copiando index.html...
copy "public\index.html" "%CARPETA_BACKUP%\index.html" >nul

echo [2/5] Copiando firebase-adapter.js...
copy "public\firebase-adapter.js" "%CARPETA_BACKUP%\firebase-adapter.js" >nul

echo [3/5] Copiando conjunto-aralia-firebase.html...
copy "public\conjunto-aralia-firebase.html" "%CARPETA_BACKUP%\conjunto-aralia-firebase.html" >nul

echo [4/5] Copiando firestore.rules...
copy "firestore.rules" "%CARPETA_BACKUP%\firestore.rules" >nul

echo [5/5] Copiando package.json...
copy "package.json" "%CARPETA_BACKUP%\package.json" >nul

echo.
echo ========================================
echo   BACKUP COMPLETADO EXITOSAMENTE
echo ========================================
echo.
echo Archivos guardados en: %CARPETA_BACKUP%
echo.
echo Presiona cualquier tecla para continuar...
pause >nul
