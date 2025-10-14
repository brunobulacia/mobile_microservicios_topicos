class JobResponse {
  JobResponse({
    required this.jobId,
    required this.message,
    required this.queueName,
    required this.queueLoad,
    required this.availableQueues,
    required this.status,
    required this.timestamp,
    required this.loadBalancing,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      jobId: json['jobId'] ?? '',
      message: json['message'] ?? '',
      queueName: json['queueName'] ?? '',
      queueLoad: json['queueLoad'] ?? 0,
      availableQueues: json['availableQueues'] ?? 0,
      status: json['status'] ?? '',
      timestamp: json['timestamp'] ?? '',
      loadBalancing: LoadBalancing.fromJson(json['loadBalancing'] ?? {}),
    );
  }

  final String jobId;
  final String message;
  final String queueName;
  final int queueLoad;
  final int availableQueues;
  final String status;
  final String timestamp;
  final LoadBalancing loadBalancing;

  Map<String, dynamic> toJson() {
    return {
      'jobId': jobId,
      'message': message,
      'queueName': queueName,
      'queueLoad': queueLoad,
      'availableQueues': availableQueues,
      'status': status,
      'timestamp': timestamp,
      'loadBalancing': loadBalancing.toJson(),
    };
  }
}

class LoadBalancing {
  LoadBalancing({required this.selectedQueue, required this.allQueues});

  factory LoadBalancing.fromJson(Map<String, dynamic> json) {
    return LoadBalancing(
      selectedQueue: SelectedQueue.fromJson(json['selectedQueue'] ?? {}),
      allQueues: (json['allQueues'] as List? ?? [])
          .map((e) => QueueInfo.fromJson(e))
          .toList(),
    );
  }

  final SelectedQueue selectedQueue;
  final List<QueueInfo> allQueues;

  Map<String, dynamic> toJson() {
    return {
      'selectedQueue': selectedQueue.toJson(),
      'allQueues': allQueues.map((e) => e.toJson()).toList(),
    };
  }
}

class SelectedQueue {
  SelectedQueue({
    required this.colaId,
    required this.nombre,
    required this.load,
  });

  factory SelectedQueue.fromJson(Map<String, dynamic> json) {
    return SelectedQueue(
      colaId: json['colaId'] ?? '',
      nombre: json['nombre'] ?? '',
      load: json['load'] ?? 0,
    );
  }

  final String colaId;
  final String nombre;
  final int load;

  Map<String, dynamic> toJson() {
    return {'colaId': colaId, 'nombre': nombre, 'load': load};
  }
}

class QueueInfo {
  QueueInfo({
    required this.nombre,
    required this.load,
    required this.workers,
    required this.waiting,
    required this.active,
  });

  factory QueueInfo.fromJson(Map<String, dynamic> json) {
    return QueueInfo(
      nombre: json['nombre'] ?? '',
      load: json['load'] ?? 0,
      workers: json['workers'] ?? 0,
      waiting: json['waiting'] ?? 0,
      active: json['active'] ?? 0,
    );
  }

  final String nombre;
  final int load;
  final int workers;
  final int waiting;
  final int active;

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'load': load,
      'workers': workers,
      'waiting': waiting,
      'active': active,
    };
  }
}
