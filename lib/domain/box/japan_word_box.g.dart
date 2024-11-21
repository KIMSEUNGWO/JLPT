// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'japan_word_box.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JapanWordBoxAdapter extends TypeAdapter<JapanWordBox> {
  @override
  final int typeId = 5;

  @override
  JapanWordBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JapanWordBox(
      words: (fields[0] as Map).map((dynamic k, dynamic v) =>
          MapEntry(k as Level, (v as List).cast<Word>())),
    );
  }

  @override
  void write(BinaryWriter writer, JapanWordBox obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.words);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JapanWordBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
