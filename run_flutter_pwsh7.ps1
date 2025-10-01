# Script para ejecutar Flutter con PowerShell 7
# Configurar PATH para incluir Git y Flutter

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "    FLUTTER - Conjunto Aralia de Castilla" -ForegroundColor Cyan
Write-Host "    PowerShell 7" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

# Configurar PATH temporal para esta sesión
$env:PATH = "C:\Program Files\Git\cmd;C:\Program Files\Git\bin;C:\dev\flutter_windows_3.24.1-stable\flutter\bin;" + $env:PATH

# Configurar variables de entorno de Flutter
$env:FLUTTER_ROOT = "C:\dev\flutter_windows_3.24.1-stable\flutter"
$env:PUB_CACHE = "$env:USERPROFILE\.pub-cache"

# Verificar Git
Write-Host ""
Write-Host "[1/4] Verificando Git..." -ForegroundColor Yellow
try {
    $gitVersion = git --version
    Write-Host "✓ $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: Git no encontrado" -ForegroundColor Red
    pause
    exit 1
}

# Verificar Flutter
Write-Host ""
Write-Host "[2/4] Verificando Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version
    Write-Host "✓ Flutter encontrado" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: Flutter no encontrado" -ForegroundColor Red
    pause
    exit 1
}

# Cambiar a directorio del proyecto
Set-Location "C:\Users\Administrador\Documents\residencial\conjunto_residencial_flutter"

# Instalar dependencias
Write-Host ""
Write-Host "[3/4] Instalando dependencias..." -ForegroundColor Yellow
try {
    flutter pub get
    Write-Host "✓ Dependencias instaladas" -ForegroundColor Green
} catch {
    Write-Host "✗ ERROR: No se pudieron instalar dependencias" -ForegroundColor Red
    pause
    exit 1
}

# Ejecutar aplicación
Write-Host ""
Write-Host "[4/4] Ejecutando aplicación en Chrome..." -ForegroundColor Yellow
Write-Host ""
Write-Host "¡Tu aplicación Flutter se abrirá en Chrome!" -ForegroundColor Green
Write-Host "Para detener: Ctrl+C" -ForegroundColor Yellow
Write-Host ""

try {
    flutter run -d chrome
} catch {
    Write-Host "✗ ERROR: No se pudo ejecutar Flutter" -ForegroundColor Red
    pause
    exit 1
}