class ConfigResponse {
  final String sessionId;
  final String greeting;

  ConfigResponse({required this.sessionId, required this.greeting});

  factory ConfigResponse.fromJson(Map<String, dynamic> j) => ConfigResponse(
        sessionId: j['session_id']?.toString() ?? '',
        greeting: j['greeting']?.toString() ?? '',
      );
}

class ChatRequest {
  final String sessionId;
  final String message;

  ChatRequest({required this.sessionId, required this.message});

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'message': message,
      };
}

class ChatResponse {
  final String reply;
  final String sessionId;

  ChatResponse({required this.reply, required this.sessionId});

  factory ChatResponse.fromJson(Map<String, dynamic> j) => ChatResponse(
        reply: j['reply']?.toString() ?? '',
        sessionId: j['session_id']?.toString() ?? '',
      );
}

class EvaluationRequest {
  final String sessionId;
  final List<Map<String, dynamic>> turns;

  EvaluationRequest({required this.sessionId, required this.turns});

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'turns': turns,
      };
}

class EvaluationResponse {
  final double score;
  final String feedback;

  EvaluationResponse({required this.score, required this.feedback});

  factory EvaluationResponse.fromJson(Map<String, dynamic> j) =>
      EvaluationResponse(
        score: (j['score'] is num) ? (j['score'] as num).toDouble() : 0.0,
        feedback: j['feedback']?.toString() ?? '',
      );
}
