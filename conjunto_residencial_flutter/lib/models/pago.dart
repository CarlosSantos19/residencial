class Pago {
  final int id;
  final String concepto;
  final int valor;
  final String mes;
  final String estado;
  final String vencimiento;

  Pago({
    required this.id,
    required this.concepto,
    required this.valor,
    required this.mes,
    required this.estado,
    required this.vencimiento,
  });

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'],
      concepto: json['concepto'],
      valor: json['valor'],
      mes: json['mes'],
      estado: json['estado'],
      vencimiento: json['vencimiento'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'concepto': concepto,
      'valor': valor,
      'mes': mes,
      'estado': estado,
      'vencimiento': vencimiento,
    };
  }

  bool get isPendiente => estado == 'pendiente';
  bool get isPagado => estado == 'pagado';

  DateTime get fechaVencimiento {
    return DateTime.parse(vencimiento);
  }

  bool get isVencido {
    return isPendiente && fechaVencimiento.isBefore(DateTime.now());
  }

  String get valorFormateado {
    return '\$${valor.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }
}

enum EstadoPago {
  pendiente('pendiente', '⏳'),
  pagado('pagado', '✅'),
  vencido('vencido', '❌');

  const EstadoPago(this.value, this.emoji);
  final String value;
  final String emoji;
}