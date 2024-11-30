// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PracticeTypeAdapter extends TypeAdapter<PracticeType> {
  @override
  final int typeId = 9;

  @override
  PracticeType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PracticeType.WORD;
      case 1:
        return PracticeType.GRAMMAR;
      default:
        return PracticeType.WORD;
    }
  }

  @override
  void write(BinaryWriter writer, PracticeType obj) {
    switch (obj) {
      case PracticeType.WORD:
        writer.writeByte(0);
        break;
      case PracticeType.GRAMMAR:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PracticeTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
