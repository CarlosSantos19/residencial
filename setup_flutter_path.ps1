# Script para configurar PATH permanentemente para Flutter
Write-Host "Configurando PATH permanente para Flutter..." -ForegroundColor Cyan

# Rutas que necesitamos
$gitPath = "C:\Program Files\Git\cmd"
$gitBinPath = "C:\Program Files\Git\bin"
$flutterPath = "C:\dev\flutter_windows_3.24.1-stable\flutter\bin"

# Obtener PATH actual del usuario
$currentPath = [Environment]::GetEnvironmentVariable("PATH", [EnvironmentVariableTarget]::User)

# Verificar y agregar rutas si no existen
$pathsToAdd = @()

if ($currentPath -notlike "*$gitPath*") {
    $pathsToAdd += $gitPath
}

if ($currentPath -notlike "*$gitBinPath*") {
    $pathsToAdd += $gitBinPath
}

if ($currentPath -notlike "*$flutterPath*") {
    $pathsToAdd += $flutterPath
}

if ($pathsToAdd.Count -gt 0) {
    $newPath = $currentPath + ";" + ($pathsToAdd -join ";")
    [Environment]::SetEnvironmentVariable("PATH", $newPath, [EnvironmentVariableTarget]::User)
    Write-Host "✓ PATH actualizado permanentemente" -ForegroundColor Green
    Write-Host "Rutas agregadas:" -ForegroundColor Yellow
    $pathsToAdd | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
} else {
    Write-Host "✓ PATH ya está configurado correctamente" -ForegroundColor Green
}

Write-Host ""
Write-Host "IMPORTANTE: Reinicia VS Code para que los cambios surtan efecto" -ForegroundColor Red
Write-Host ""
Write-Host "Después de reiniciar VS Code:" -ForegroundColor Yellow
Write-Host "1. Abre el proyecto Flutter" -ForegroundColor White
Write-Host "2. Presiona F5 o ve a Run > Start Debugging" -ForegroundColor White
Write-Host "3. Selecciona 'conjunto_residencial_flutter'" -ForegroundColor White