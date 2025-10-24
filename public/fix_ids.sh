#!/bin/bash
sed -i \
  -e 's/onclick="verDetallesArriendo(${arriendo\.id})"/onclick="verDetallesArriendo('\''${arriendo.id}'\'')"/g' \
  -e 's/onclick="verResenasEmprendimiento(${emp\.id})"/onclick="verResenasEmprendimiento('\''${emp.id}'\'')"/g' \
  -e 's/onclick="escribirResena(${emp\.id})"/onclick="escribirResena('\''${emp.id}'\'')"/g' \
  -e 's/onclick="procesarSalidaVehiculo(${v\.id})"/onclick="procesarSalidaVehiculo('\''${v.id}'\'')"/g' \
  -e 's/onclick="eliminarNoticia(${n\.id})"/onclick="eliminarNoticia('\''${n.id}'\'')"/g' \
  -e 's/onclick="mostrarResponderPQRS(${p\.id})"/onclick="mostrarResponderPQRS('\''${p.id}'\'')"/g' \
  -e 's/onclick="cerrarEncuesta(${e\.id})"/onclick="cerrarEncuesta('\''${e.id}'\'')"/g' \
  -e 's/onclick="eliminarEncuesta(${e\.id})"/onclick="eliminarEncuesta('\''${e.id}'\'')"/g' \
  -e 's/onclick="votarEncuesta(${e\.id})"/onclick="votarEncuesta('\''${e.id}'\'')"/g' \
  -e 's/onclick="eliminarDocumento(${d\.id})"/onclick="eliminarDocumento('\''${d.id}'\'')"/g' \
  -e 's/onclick="mostrarFormularioRespuesta(${pqr\.id})"/onclick="mostrarFormularioRespuesta('\''${pqr.id}'\'')"/g' \
  -e 's/onclick="enviarRespuestaPQRS(${pqr\.id})"/onclick="enviarRespuestaPQRS('\''${pqr.id}'\'')"/g' \
  -e 's/onclick="ocultarFormularioRespuesta(${pqr\.id})"/onclick="ocultarFormularioRespuesta('\''${pqr.id}'\'')"/g' \
  -e 's/onclick="mostrarFormularioRespuesta(${incidente\.id})"/onclick="mostrarFormularioRespuesta('\''${incidente.id}'\'')"/g' \
  -e 's/onclick="enviarRespuestaIncidente(${incidente\.id})"/onclick="enviarRespuestaIncidente('\''${incidente.id}'\'')"/g' \
  index.html
echo "Done!"
