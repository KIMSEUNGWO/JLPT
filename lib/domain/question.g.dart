// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionAdapter extends TypeAdapter<Question> {
  @override
  final int typeId = 7;

  @override
  Question read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Question(
      question: fields[0] as QuestionBox,
      examples: (fields[1] as List).cast<QuestionBox>(),
      myAnswer: fields[2] as QuestionBox?,
      reverse: fields[3] as bool,
    )..isCorrect = fields[4] as bool;
  }

  @override
  void write(BinaryWriter writer, Question obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.question)
      ..writeByte(1)
      ..write(obj.examples)
      ..writeByte(2)
      ..write(obj.myAnswer)
      ..writeByte(3)
      ..write(obj.reverse)
      ..writeByte(4)
      ..write(obj.isCorrect);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
