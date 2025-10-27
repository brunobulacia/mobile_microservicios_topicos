class JobStatus {
  JobStatus({
    required this.jobId,
    required this.queueName,
    required this.status,
    required this.data,
    required this.progress,
    required this.createdAt,
    this.processedOn,
    this.finishedOn,
    this.returnValue,
    required this.attemptsMade,
    required this.opts,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) {
    return JobStatus(
      jobId: json['jobId'] as String,
      queueName: json['queueName'] as String,
      status: StatusExtension.fromString(json['status'] as String),
      data: JobData.fromJson(json['data'] as Map<String, dynamic>),
      progress: json['progress'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedOn: json['processedOn'] != null
          ? DateTime.tryParse(json['processedOn'])
          : null,
      finishedOn: json['finishedOn'] != null
          ? DateTime.tryParse(json['finishedOn'])
          : null,
      returnValue: json['returnValue'],
      attemptsMade: json['attemptsMade'] as int,
      opts: JobOpts.fromJson(json['opts'] as Map<String, dynamic>),
    );
  }
  final String jobId;
  final String queueName;
  final Status status;
  final JobData data;
  final int progress;
  final DateTime createdAt;
  final DateTime? processedOn;
  final DateTime? finishedOn;
  final dynamic returnValue;
  final int attemptsMade;
  final JobOpts opts;

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'queueName': queueName,
      'status': status,
      'data': data.toJson(),
      'progress': progress,
      'createdAt': createdAt.toIso8601String(),
      'processedOn': processedOn?.toIso8601String(),
      'finishedOn': finishedOn?.toIso8601String(),
      'returnValue': returnValue,
      'attemptsMade': attemptsMade,
      'opts': opts.toJson(),
    };
  }
}

class JobData {
  JobData({required this.registro, required this.ofertaId});

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(
      registro: json['registro'] as String,
      ofertaId: List<String>.from(json['ofertaId'] as List),
    );
  }
  final String registro;
  final List<String> ofertaId;

  Map<String, dynamic> toJson() {
    return {'registro': registro, 'ofertaId': ofertaId};
  }
}

class JobOpts {
  JobOpts({required this.attempts, required this.delay});

  factory JobOpts.fromJson(Map<String, dynamic> json) {
    return JobOpts(
      attempts: json['attempts'] as int,
      delay: json['delay'] as int,
    );
  }
  final int attempts;
  final int delay;

  Map<String, dynamic> toJson() {
    return {'attempts': attempts, 'delay': delay};
  }
}

enum Status { completed, waiting, active, delayed, failed, paused }

extension StatusExtension on Status {
  static Status fromString(String value) {
    switch (value) {
      case 'completed':
        return Status.completed;
      case 'waiting':
        return Status.waiting;
      case 'active':
        return Status.active;
      case 'delayed':
        return Status.delayed;
      case 'failed':
        return Status.failed;
      case 'paused':
        return Status.paused;
      default:
        throw ArgumentError('Unknown status: $value');
    }
  }
}

extension StatusJson on Status {
  String toJson() {
    return toString().split('.').last;
  }
}
