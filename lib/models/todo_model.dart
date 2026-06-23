class TodoModel {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final String priority;
  final DateTime? dueDate;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TodoModel({
    required this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.priority = 'medium',
    this.dueDate,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      completed: json['isCompleted'] == true || json['completed'] == true,
      priority: json['priority']?.toString() ?? 'medium',
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : null,
      userId: json['userId']?.toString() ?? json['user']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      if (description != null) 'description': description,
      'completed': completed,
      'priority': priority,
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      if (userId != null) 'userId': userId,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      if (description != null && description!.isNotEmpty)
        'description': description,
      'priority': priority,
      if (dueDate != null)
        'dueDate':
            '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}',
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'isCompleted': completed,
      'priority': priority,
      if (dueDate != null)
        'dueDate':
            '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}',
    };
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    String? priority,
    DateTime? dueDate,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (dueDate == null || completed) return false;
    return dueDate!.isBefore(DateTime.now());
  }
}
