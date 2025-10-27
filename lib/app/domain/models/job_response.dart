class JobResponse {
  JobResponse({
    required this.message,
    required this.jobId,
    required this.queueName,
    required this.colaName,
    required this.registro,
    required this.workersAvailable,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      message: json['message'] as String,
      jobId: json['jobId'] as String,
      queueName: json['queueName'] as String,
      colaName: json['colaName'] as String,
      registro: json['registro'] as String,
      workersAvailable: json['workersAvailable'] as int,
    );
  }
  final String message;
  final String jobId;
  final String queueName;
  final String colaName;
  final String registro;
  final int workersAvailable;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'jobId': jobId,
      'queueName': queueName,
      'colaName': colaName,
      'registro': registro,
      'workersAvailable': workersAvailable,
    };
  }
}
