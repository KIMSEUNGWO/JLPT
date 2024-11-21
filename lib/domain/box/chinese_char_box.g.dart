// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chinese_char_box.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChineseCharBoxAdapter extends TypeAdapter<ChineseCharBox> {
  @override
  final int typeId = 6;

  @override
  ChineseCharBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChineseCharBox(
      chars: (fields[0] as Map).cast<String, ChineseChar>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChineseCharBox obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.chars);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChineseCharBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
