import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import '../models/asignacion_parqueadero.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  final _formatoMoneda = NumberFormat.currency(locale: 'es_CO', symbol: '\$', decimalDigits: 0);
  final _formatoFecha = DateFormat('dd/MM/yyyy HH:mm', 'es');

  // Generar recibo de pago
  Future<void> generarReciboPago({
    required String nombreResidente,
    required String apartamento,
    required double monto,
    required String concepto,
    required String metodoPago,
    required DateTime fecha,
    String? referencia,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue700,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CONJUNTO ARALIA DE CASTILLA',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'RECIBO DE PAGO',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Información del residente
              _buildSeccion('DATOS DEL RESIDENTE', [
                _buildFila('Nombre:', nombreResidente),
                _buildFila('Apartamento:', apartamento),
                _buildFila('Fecha:', _formatoFecha.format(fecha)),
                if (referencia != null) _buildFila('Referencia:', referencia),
              ]),
              pw.SizedBox(height: 20),

              // Detalle del pago
              _buildSeccion('DETALLE DEL PAGO', [
                _buildFila('Concepto:', concepto),
                _buildFila('Método de Pago:', metodoPago),
              ]),
              pw.SizedBox(height: 20),

              // Total
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL:',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      _formatoMoneda.format(monto),
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 40),

              // Firma
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                children: [
                  _buildFirma('Residente'),
                  _buildFirma('Administración'),
                ],
              ),
              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Documento generado automáticamente - ${_formatoFecha.format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Guardar y abrir PDF
    await _guardarYAbrirPdf(pdf, 'Recibo_Pago_$apartamento');
  }

  // Generar recibo de vehículo visitante
  Future<void> generarReciboVehiculo({
    required String placa,
    required String apartamento,
    required DateTime horaEntrada,
    required DateTime horaSalida,
    required Duration tiempoTotal,
    required double valorTotal,
    required String metodoPago,
    required String detalleCalculo,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Encabezado
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange700,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      children: [
                        pw.Icon(pw.IconData(0xe531), size: 30, color: PdfColors.white),
                        pw.SizedBox(width: 10),
                        pw.Text(
                          'RECIBO PARQUEADERO VISITANTE',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Información del vehículo
              _buildSeccion('INFORMACIÓN DEL VEHÍCULO', [
                _buildFila('Placa:', placa.toUpperCase()),
                _buildFila('Apartamento Visitado:', apartamento),
                _buildFila('Entrada:', _formatoFecha.format(horaEntrada)),
                _buildFila('Salida:', _formatoFecha.format(horaSalida)),
              ]),
              pw.SizedBox(height: 20),

              // Tiempo y cálculo
              _buildSeccion('DETALLE DEL COBRO', [
                _buildFila(
                  'Tiempo Total:',
                  '${tiempoTotal.inHours}h ${tiempoTotal.inMinutes.remainder(60)}min',
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Text(
                    detalleCalculo,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              ]),
              pw.SizedBox(height: 20),

              // Total
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'TOTAL A PAGAR:',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Método: $metodoPago',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Text(
                      _formatoMoneda.format(valorTotal),
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: valorTotal == 0 ? PdfColors.green700 : PdfColors.red700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 30),

              // Tarifas
              _buildSeccion('TARIFAS VIGENTES', [
                pw.Text('• Primeras 2 horas: GRATIS'),
                pw.Text('• Horas 3-10: \$1,000 por hora'),
                pw.Text('• Más de 10 horas o varios días: \$12,000 por día'),
              ]),
              pw.Spacer(),

              // Footer
              pw.Center(
                child: pw.Text(
                  'Gracias por su visita - ${_formatoFecha.format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await _guardarYAbrirPdf(pdf, 'Recibo_Vehiculo_$placa');
  }

  // Generar reporte de sorteo de parqueaderos
  Future<void> generarReporteSorteo({
    required DateTime fechaSorteo,
    required List<AsignacionParqueadero> asignaciones,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.green700,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'SORTEO DE PARQUEADEROS',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        _formatoFecha.format(fechaSorteo),
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    '${asignaciones.length} asignados',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 30),

            // Tabla de asignaciones
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                // Encabezado de tabla
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildCeldaTabla('Torre', bold: true),
                    _buildCeldaTabla('Apto', bold: true),
                    _buildCeldaTabla('Residente', bold: true),
                    _buildCeldaTabla('Parqueadero', bold: true),
                  ],
                ),
                // Filas de datos
                ...asignaciones.map((a) => pw.TableRow(
                      children: [
                        _buildCeldaTabla(a.torre),
                        _buildCeldaTabla(a.apartamento),
                        _buildCeldaTabla(a.nombreResidente),
                        _buildCeldaTabla('P-${a.numeroParqueadero}'),
                      ],
                    )),
              ],
            ),
          ];
        },
      ),
    );

    await _guardarYAbrirPdf(pdf, 'Sorteo_Parqueaderos_${fechaSorteo.day}${fechaSorteo.month}${fechaSorteo.year}');
  }

  // Widgets auxiliares
  pw.Widget _buildSeccion(String titulo, List<pw.Widget> contenido) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: contenido,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildFila(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFirma(String titulo) {
    return pw.Column(
      children: [
        pw.Container(
          width: 200,
          height: 60,
          decoration: pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey800),
            ),
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          titulo,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCeldaTabla(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  // Guardar y abrir PDF
  Future<void> _guardarYAbrirPdf(pw.Document pdf, String nombreArchivo) async {
    try {
      // Obtener directorio de documentos
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/$nombreArchivo.pdf';
      final File file = File(path);

      // Guardar PDF
      await file.writeAsBytes(await pdf.save());

      // Abrir PDF
      await OpenFile.open(path);
    } catch (e) {
      print('Error guardando PDF: $e');
    }
  }

  // Imprimir PDF directamente
  Future<void> imprimirPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
