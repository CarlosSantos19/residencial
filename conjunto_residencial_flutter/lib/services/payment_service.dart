import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  // Procesar pago según el método seleccionado
  Future<PaymentResult> procesarPago({
    required double monto,
    required String concepto,
    required MetodoPago metodo,
    String? referencia,
  }) async {
    try {
      switch (metodo) {
        case MetodoPago.efectivo:
          return _registrarPagoEfectivo(monto, concepto);
        case MetodoPago.nequi:
          return await _pagarConNequi(monto, concepto);
        case MetodoPago.daviplata:
          return await _pagarConDaviplata(monto, concepto);
        case MetodoPago.pse:
          return await _pagarConPSE(monto, concepto);
        case MetodoPago.transferencia:
          return _mostrarDatosBancarios(monto, concepto);
      }
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return PaymentResult(
        success: false,
        mensaje: 'Error al procesar el pago: $e',
      );
    }
  }

  // Pago en efectivo (solo registra)
  PaymentResult _registrarPagoEfectivo(double monto, String concepto) {
    return PaymentResult(
      success: true,
      mensaje: 'Pago en efectivo registrado. Por favor entregar en administración.',
      metodoPago: MetodoPago.efectivo,
    );
  }

  // Pago con Nequi (abre la app)
  Future<PaymentResult> _pagarConNequi(double monto, String concepto) async {
    // Número de Nequi del conjunto (ejemplo)
    const String numeroNequi = '3001234567';

    try {
      // Intentar abrir la app de Nequi
      final Uri uri = Uri.parse('nequi://send?phone=$numeroNequi&amount=${monto.toInt()}&message=$concepto');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return PaymentResult(
          success: true,
          mensaje: 'Redirigiendo a Nequi...',
          metodoPago: MetodoPago.nequi,
        );
      } else {
        // Si no tiene la app, abrir navegador
        return PaymentResult(
          success: true,
          mensaje: 'Por favor realiza la transferencia Nequi a: $numeroNequi\nValor: \$${monto.toStringAsFixed(0)}\nConcepto: $concepto',
          metodoPago: MetodoPago.nequi,
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        mensaje: 'No se pudo abrir Nequi. Por favor usa el número $numeroNequi manualmente.',
      );
    }
  }

  // Pago con Daviplata
  Future<PaymentResult> _pagarConDaviplata(double monto, String concepto) async {
    const String numeroDaviplata = '3007654321';

    try {
      final Uri uri = Uri.parse('daviplata://send?phone=$numeroDaviplata&amount=${monto.toInt()}');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return PaymentResult(
          success: true,
          mensaje: 'Redirigiendo a Daviplata...',
          metodoPago: MetodoPago.daviplata,
        );
      } else {
        return PaymentResult(
          success: true,
          mensaje: 'Por favor realiza la transferencia Daviplata a: $numeroDaviplata\nValor: \$${monto.toStringAsFixed(0)}\nConcepto: $concepto',
          metodoPago: MetodoPago.daviplata,
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        mensaje: 'No se pudo abrir Daviplata. Usa el número $numeroDaviplata manualmente.',
      );
    }
  }

  // Pago con PSE
  Future<PaymentResult> _pagarConPSE(double monto, String concepto) async {
    // Aquí se integraría con la pasarela de pagos real (Wompi, PayU, etc.)
    // Por ahora retornamos un mensaje
    return PaymentResult(
      success: true,
      mensaje: 'PSE no configurado aún. Por favor usa otro método de pago.',
      metodoPago: MetodoPago.pse,
    );
  }

  // Mostrar datos bancarios
  PaymentResult _mostrarDatosBancarios(double monto, String concepto) {
    return PaymentResult(
      success: true,
      mensaje: '''
Datos Bancarios:
Banco: Bancolombia
Cuenta Ahorros: 12345678901
Titular: Conjunto Aralia de Castilla
NIT: 900.123.456-7

Valor: \$${monto.toStringAsFixed(0)}
Concepto: $concepto

⚠️ Envía el comprobante al administrador
      ''',
      metodoPago: MetodoPago.transferencia,
    );
  }

  // Generar recibo de pago
  Future<String> generarRecibo({
    required String nombreResidente,
    required String apartamento,
    required double monto,
    required String concepto,
    required MetodoPago metodo,
    required DateTime fecha,
    String? referencia,
  }) async {
    // Aquí se generaría un PDF (implementación en otro archivo)
    return 'RECIBO-${DateTime.now().millisecondsSinceEpoch}';
  }
}

// Enumeración de métodos de pago
enum MetodoPago {
  efectivo('Efectivo'),
  nequi('Nequi'),
  daviplata('Daviplata'),
  pse('PSE'),
  transferencia('Transferencia Bancaria');

  final String displayName;
  const MetodoPago(this.displayName);
}

// Resultado de un pago
class PaymentResult {
  final bool success;
  final String mensaje;
  final MetodoPago? metodoPago;
  final String? transaccionId;
  final DateTime fecha;

  PaymentResult({
    required this.success,
    required this.mensaje,
    this.metodoPago,
    this.transaccionId,
    DateTime? fecha,
  }) : fecha = fecha ?? DateTime.now();
}
