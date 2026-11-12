class TemplateVariableModel {
  final String name;
  final String label;
  final String type; // 'text' | 'number' | 'date' | 'select'
  final List<String> options;
  final bool required;
  final String defaultValue;

  TemplateVariableModel({
    required this.name,
    required this.label,
    this.type = 'text',
    this.options = const [],
    this.required = true,
    this.defaultValue = '',
  });

  factory TemplateVariableModel.fromJson(Map<String, dynamic> json) {
    return TemplateVariableModel(
      name: json['name'] ?? '',
      label: json['label'] ?? json['name'] ?? '',
      type: json['type'] ?? 'text',
      options: (json['options'] as List?)?.map((e) => e.toString()).toList() ?? [],
      required: json['required'] ?? true,
      defaultValue: json['defaultValue']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'type': type,
      'options': options,
      'required': required,
      'defaultValue': defaultValue,
    };
  }
}

class TemplateModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String content;
  final List<String> placeholders;
  final List<TemplateVariableModel> variables;
  final double autoGeneratePrice;
  final double lawyerReviewPrice;
  final double price;
  final bool requiresReview;
  final DateTime? createdAt;

  TemplateModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.content,
    this.placeholders = const [],
    this.variables = const [],
    this.autoGeneratePrice = 150.0,
    this.lawyerReviewPrice = 450.0,
    this.price = 150.0,
    this.requiresReview = false,
    this.createdAt,
  });

  factory TemplateModel.fromJson(Map<String, dynamic> json) {
    final varsJson = json['variables'] as List? ?? [];
    final phsJson = json['placeholders'] as List? ?? [];

    List<TemplateVariableModel> parsedVars = varsJson
        .map((v) => TemplateVariableModel.fromJson(v as Map<String, dynamic>))
        .toList();

    // If variables array is empty but placeholders exist, generate default text variables
    if (parsedVars.isEmpty && phsJson.isNotEmpty) {
      parsedVars = phsJson.map((p) {
        final key = p.toString();
        return TemplateVariableModel(
          name: key,
          label: key.replaceAll('_', ' '),
          type: key.contains('تاريخ') ? 'date' : (key.contains('قيمة') || key.contains('مبلغ') || key.contains('مدة') ? 'number' : 'text'),
        );
      }).toList();
    }

    return TemplateModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'عقود عامة',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      placeholders: phsJson.map((e) => e.toString()).toList(),
      variables: parsedVars,
      autoGeneratePrice: (json['autoGeneratePrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 150.0,
      lawyerReviewPrice: (json['lawyerReviewPrice'] as num?)?.toDouble() ?? 450.0,
      price: (json['price'] as num?)?.toDouble() ?? 150.0,
      requiresReview: json['requiresReview'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

