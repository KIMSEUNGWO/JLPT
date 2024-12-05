// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_entity_box.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionEntityBoxAdapter extends TypeAdapter<QuestionEntityBox> {
  @override
  final int typeId = 8;

  @override
  QuestionEntityBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionEntityBox(
      id: fields[0] as int,
      level: fields[1] as Level?,
      type: fields[2] as PracticeType,
      dateTime: fields[3] as DateTime,
      question: (fields[4] as List).cast<Question>(),
      time: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionEntityBox obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.level)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.question)
      ..writeByte(5)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionEntityBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
