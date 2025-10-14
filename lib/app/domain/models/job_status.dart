class JobStatus {
  JobStatus({
    required this.jobId,
    required this.status,
    required this.progress,
    required this.queueName,
    required this.createdAt,
    required this.processedAt,
    required this.completedAt,
    required this.result,
    required this.error,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) {
    return JobStatus(
      jobId: json['jobId'] ?? '',
      status: json['status'] ?? 'pending',
      progress: json['progress'] ?? 0,
      queueName: json['queueName'] ?? '',
      createdAt: json['createdAt'] ?? '',
      processedAt: json['processedAt'] ?? '',
      completedAt: json['completedAt'] ?? '',
      result: json['result'],
      error: json['error'] ?? '',
    );
  }

  final String jobId;
  final String status; // pending, waiting, completed, failed
  final int progress;
  final String queueName;
  final String createdAt;
  final String processedAt;
  final String completedAt;
  final dynamic result;
  final String? error;

  bool get isPending => status == 'pending';
  bool get isWaiting => status == 'waiting';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isProcessing => status == 'processing';

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'status': status,
      'progress': progress,
      'queueName': queueName,
      'createdAt': createdAt,
      'processedAt': processedAt,
      'completedAt': completedAt,
      'result': result,
      'error': error,
    };
  }
}
