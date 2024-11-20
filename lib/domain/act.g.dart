// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'act.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActAdapter extends TypeAdapter<Act> {
  @override
  final int typeId = 4;

  @override
  Act read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Act.V;
      case 1:
        return Act.N;
      case 2:
        return Act.ADJ;
      case 3:
        return Act.ADV;
      default:
        return Act.V;
    }
  }

  @override
  void write(BinaryWriter writer, Act obj) {
    switch (obj) {
      case Act.V:
        writer.writeByte(0);
        break;
      case Act.N:
        writer.writeByte(1);
        break;
      case Act.ADJ:
        writer.writeByte(2);
        break;
      case Act.ADV:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
