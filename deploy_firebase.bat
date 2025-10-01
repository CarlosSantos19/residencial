@echo off
echo =================================
echo   DEPLOY CONJUNTO RESIDENCIAL
echo   A FIREBASE HOSTING + FUNCTIONS
echo =================================
echo.

REM Configurar PATH de Git
set "PATH=%PATH%;C:\Program Files\Git\cmd"

echo 1. Verificando herramientas...
echo   - Git:
git --version
if %errorlevel% neq 0 (
    echo ERROR: Git no encontrado en PATH
    pause
    exit /b 1
)

echo   - Flutter:
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter no encontrado
    pause
    exit /b 1
)

echo   - Firebase CLI:
firebase --version
if %errorlevel% neq 0 (
    echo ERROR: Firebase CLI no encontrado
    echo Instala con: npm install -g firebase-tools
    pause
    exit /b 1
)

echo.
echo 2. Autenticando en Firebase...
firebase login --no-localhost
if %errorlevel% neq 0 (
    echo ERROR: Autenticación de Firebase falló
    pause
    exit /b 1
)

echo.
echo 3. Listando proyectos disponibles...
firebase projects:list

echo.
set /p PROJECT_ID=Ingresa el ID del proyecto Firebase (o 'new' para crear uno nuevo):

if "%PROJECT_ID%"=="new" (
    set /p NEW_PROJECT_ID=Ingresa el ID para el nuevo proyecto:
    echo Creando proyecto %NEW_PROJECT_ID%...
    firebase projects:create %NEW_PROJECT_ID%
    set PROJECT_ID=%NEW_PROJECT_ID%
)

echo.
echo 4. Seleccionando proyecto %PROJECT_ID%...
firebase use %PROJECT_ID%
if %errorlevel% neq 0 (
    echo ERROR: No se pudo seleccionar el proyecto
    pause
    exit /b 1
)

echo.
echo 5. Inicializando Firebase en el proyecto...
firebase init hosting functions --project %PROJECT_ID%

echo.
echo 6. Instalando dependencias Flutter...
cd conjunto_residencial_flutter
flutter clean
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get falló
    pause
    exit /b 1
)

echo.
echo 7. Compilando Flutter para web...
flutter build web --release
if %errorlevel% neq 0 (
    echo ERROR: Flutter build web falló
    pause
    exit /b 1
)

cd ..

echo.
echo 8. Instalando dependencias de Functions...
cd functions
npm install
if %errorlevel% neq 0 (
    echo ERROR: npm install en functions falló
    pause
    exit /b 1
)

echo.
echo 9. Compilando TypeScript...
npm run build
if %errorlevel% neq 0 (
    echo ERROR: Build de TypeScript falló
    pause
    exit /b 1
)

cd ..

echo.
echo 10. Desplegando a Firebase...
firebase deploy --project %PROJECT_ID%

echo.
echo =================================
echo      DESPLIEGUE COMPLETADO
echo =================================
echo.
echo URLs disponibles:
echo - Aplicación Web: https://%PROJECT_ID%.web.app
echo - Aplicación Flutter: https://%PROJECT_ID%.web.app
echo - Functions API: https://us-central1-%PROJECT_ID%.cloudfunctions.net/api
echo.
echo Para ver el estado: firebase hosting:sites:list
echo.
pause