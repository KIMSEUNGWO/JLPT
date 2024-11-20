// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chinese_char.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChineseCharAdapter extends TypeAdapter<ChineseChar> {
  @override
  final int typeId = 1;

  @override
  ChineseChar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChineseChar(
      char: fields[0] as String,
      soundReading: (fields[1] as List).cast<String>(),
      meanReading: (fields[2] as List).cast<String>(),
      koreanChar: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ChineseChar obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.char)
      ..writeByte(1)
      ..write(obj.soundReading)
      ..writeByte(2)
      ..write(obj.meanReading)
      ..writeByte(3)
      ..write(obj.koreanChar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChineseCharAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
