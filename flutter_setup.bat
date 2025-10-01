@echo off
REM Script para configurar Flutter correctamente

echo Configurando PATH para Flutter...

REM Agregar Git al PATH de Flutter
set PATH=%PATH%;C:\Program Files\Git\cmd
set PATH=%PATH%;C:\Program Files\Git\bin

REM Verificar Flutter
echo Verificando Flutter...
flutter doctor

REM Ir a proyecto Flutter
cd conjunto_residencial_flutter

REM Limpiar y obtener dependencias
echo Limpiando proyecto Flutter...
flutter clean

echo Obteniendo dependencias...
flutter pub get

echo ¡Flutter configurado correctamente!
pause