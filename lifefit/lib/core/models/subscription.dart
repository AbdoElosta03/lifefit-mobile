class Subscription {
  final int id;
  final String serviceTitle;
  final String coachName;
  final String duration;
  final String price;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentMethod;
  final String status;


  Subscription({
    required this.id,
    required this.serviceTitle,
    required this.coachName,
    required this.price,
    required this.duration,
    required this.startDate,
    required this.endDate,
    required this.paymentMethod,
    required this.status,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] ?? 0,
      serviceTitle: json['service_title']??'',
      coachName: json['coach_name']??'',
      price: json['price']??'',
      duration: json['duration']??'',
      startDate: DateTime.parse(json['start_date']??DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['end_date']??DateTime.now().toIso8601String()),
      paymentMethod: json['payment_method']??'',
      status: json['status']??'',
    );
  }
  // تحويل كائن الاشتراك إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'service_title': serviceTitle,
      'coach_name': coachName,
      'price': price,
      'duration': duration,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'payment_method': paymentMethod,
      'status': status,
    };
  }
}