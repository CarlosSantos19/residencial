@echo off
REM Script para ejecutar Flutter con Git correctamente configurado

echo ===============================================
echo    FLUTTER - Conjunto Aralia de Castilla
echo ===============================================

REM Configurar PATH para incluir Git
set "PATH=%PATH%;C:\Program Files\Git\cmd;C:\Program Files\Git\bin"

REM Ir a la carpeta del proyecto Flutter
cd /d "C:\Users\Administrador\Documents\residencial\conjunto_residencial_flutter"

echo.
echo [1/4] Verificando Git...
git --version
if errorlevel 1 (
    echo ERROR: Git no encontrado
    pause
    exit /b 1
)

echo.
echo [2/4] Verificando Flutter...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter no encontrado
    pause
    exit /b 1
)

echo.
echo [3/4] Instalando dependencias...
flutter pub get
if errorlevel 1 (
    echo ERROR: No se pudieron instalar las dependencias
    pause
    exit /b 1
)

echo.
echo [4/4] Ejecutando aplicación en Chrome...
echo.
echo ¡Tu aplicación Flutter se abrirá en Chrome!
echo Para detener: Ctrl+C
echo.

flutter run -d chrome

pause