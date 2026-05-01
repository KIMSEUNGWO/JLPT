import 'package:jlpt_app/domain/level.dart';
import 'package:jlpt_app/domain/question.dart';
import 'package:jlpt_app/domain/type.dart';

class QuestionEntityBox {
  final int id;
  final Level? level;
  final PracticeType type;
  final DateTime dateTime;
  final List<Question> question;
  final int time;

  const QuestionEntityBox({
    required this.id,
    required this.level,
    required this.type,
    required this.dateTime,
    required this.question,
    required this.time,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is QuestionEntityBox && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
