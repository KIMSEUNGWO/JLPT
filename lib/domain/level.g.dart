// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LevelAdapter extends TypeAdapter<Level> {
  @override
  final int typeId = 3;

  @override
  Level read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Level.N5;
      case 1:
        return Level.N4;
      case 2:
        return Level.N3;
      case 3:
        return Level.N2;
      case 4:
        return Level.N1;
      default:
        return Level.N5;
    }
  }

  @override
  void write(BinaryWriter writer, Level obj) {
    switch (obj) {
      case Level.N5:
        writer.writeByte(0);
        break;
      case Level.N4:
        writer.writeByte(1);
        break;
      case Level.N3:
        writer.writeByte(2);
        break;
      case Level.N2:
        writer.writeByte(3);
        break;
      case Level.N1:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
