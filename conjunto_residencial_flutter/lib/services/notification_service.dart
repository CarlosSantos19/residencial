import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Inicializar servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Solicitar permisos
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('User granted permission: ${settings.authorizationStatus}');

      // Configurar notificaciones locales
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Configurar canal de notificaciones para Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Configurar handler para mensajes en background
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Listener para mensajes en foreground
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listener para cuando se toca una notificación
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Obtener token FCM
      String? token = await _fcm.getToken();
      debugPrint('FCM Token: $token');

      _initialized = true;
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Obtener token FCM
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }

  // Handler para mensajes en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint('Message also contained a notification: ${message.notification}');
      await showLocalNotification(
        title: message.notification!.title ?? 'Nueva notificación',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  // Handler para cuando se abre la app desde una notificación
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('Message clicked!');
    debugPrint('Message data: ${message.data}');
    // Aquí puedes navegar a una pantalla específica según el tipo de notificación
  }

  // Handler para cuando se toca una notificación local
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notification tapped: ${notificationResponse.payload}');
    // Aquí puedes navegar a una pantalla específica
  }

  // Mostrar notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.general,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Notificación de nueva noticia
  Future<void> enviarNotificacionNoticia(String titulo, String extracto) async {
    await showLocalNotification(
      title: '📰 Nueva Noticia',
      body: titulo,
      type: NotificationType.noticia,
    );
  }

  // Notificación de paquete recibido
  Future<void> enviarNotificacionPaquete(String apartamento) async {
    await showLocalNotification(
      title: '📦 Paquete Recibido',
      body: 'Tienes un paquete esperando en portería',
      type: NotificationType.paquete,
    );
  }

  // Notificación de pago pendiente
  Future<void> enviarNotificacionPago(double monto, String concepto) async {
    await showLocalNotification(
      title: '💳 Pago Pendiente',
      body: '$concepto - \$${monto.toStringAsFixed(0)}',
      type: NotificationType.pago,
    );
  }

  // Notificación de reserva confirmada
  Future<void> enviarNotificacionReserva(
      String espacio, String fecha, String hora) async {
    await showLocalNotification(
      title: '✅ Reserva Confirmada',
      body: '$espacio - $fecha a las $hora',
      type: NotificationType.reserva,
    );
  }

  // Notificación de PQRS actualizada
  Future<void> enviarNotificacionPQRS(String estado) async {
    await showLocalNotification(
      title: '📋 PQRS Actualizada',
      body: 'Tu solicitud cambió a estado: $estado',
      type: NotificationType.pqrs,
    );
  }

  // Notificación de permiso aprobado/rechazado
  Future<void> enviarNotificacionPermiso(String tipo, bool aprobado) async {
    await showLocalNotification(
      title: aprobado ? '✅ Permiso Aprobado' : '❌ Permiso Rechazado',
      body: 'Tu permiso de $tipo fue ${aprobado ? 'aprobado' : 'rechazado'}',
      type: NotificationType.permiso,
    );
  }

  // Notificación de alarma SOS
  Future<void> enviarAlarmaSOS(String tipo, String apartamento) async {
    await showLocalNotification(
      title: '🚨 ALARMA DE EMERGENCIA',
      body: '$tipo - Apartamento $apartamento',
      type: NotificationType.alarma,
    );
  }

  // Notificación de mensaje de chat
  Future<void> enviarNotificacionChat(
      String remitente, String mensaje, String canal) async {
    await showLocalNotification(
      title: '💬 Nuevo mensaje de $remitente',
      body: mensaje,
      type: NotificationType.chat,
    );
  }

  // Notificación de solicitud de chat privado
  Future<void> enviarNotificacionSolicitudChat(String remitente) async {
    await showLocalNotification(
      title: '💬 Solicitud de Chat',
      body: '$remitente quiere iniciar un chat contigo',
      type: NotificationType.chat,
    );
  }

  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }
}

// Tipos de notificación
enum NotificationType {
  general,
  noticia,
  paquete,
  pago,
  reserva,
  pqrs,
  permiso,
  alarma,
  chat,
}
