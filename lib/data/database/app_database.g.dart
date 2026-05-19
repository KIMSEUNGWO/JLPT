// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $WordsTable extends Words with TableInfo<$WordsTable, WordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actMeta = const VerificationMeta('act');
  @override
  late final GeneratedColumn<String> act = GeneratedColumn<String>(
    'act',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hiraganaMeta = const VerificationMeta(
    'hiragana',
  );
  @override
  late final GeneratedColumn<String> hiragana = GeneratedColumn<String>(
    'hiragana',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _koreanMeta = const VerificationMeta('korean');
  @override
  late final GeneratedColumn<String> korean = GeneratedColumn<String>(
    'korean',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _wrongCntMeta = const VerificationMeta(
    'wrongCnt',
  );
  @override
  late final GeneratedColumn<int> wrongCnt = GeneratedColumn<int>(
    'wrong_cnt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    level,
    act,
    word,
    hiragana,
    korean,
    isRead,
    wrongCnt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'words';
  @override
  VerificationContext validateIntegrity(
    Insertable<WordData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('act')) {
      context.handle(
        _actMeta,
        act.isAcceptableOrUnknown(data['act']!, _actMeta),
      );
    } else if (isInserting) {
      context.missing(_actMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('hiragana')) {
      context.handle(
        _hiraganaMeta,
        hiragana.isAcceptableOrUnknown(data['hiragana']!, _hiraganaMeta),
      );
    } else if (isInserting) {
      context.missing(_hiraganaMeta);
    }
    if (data.containsKey('korean')) {
      context.handle(
        _koreanMeta,
        korean.isAcceptableOrUnknown(data['korean']!, _koreanMeta),
      );
    } else if (isInserting) {
      context.missing(_koreanMeta);
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('wrong_cnt')) {
      context.handle(
        _wrongCntMeta,
        wrongCnt.isAcceptableOrUnknown(data['wrong_cnt']!, _wrongCntMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WordData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      act: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}act'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      hiragana: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hiragana'],
      )!,
      korean: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}korean'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      wrongCnt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_cnt'],
      )!,
    );
  }

  @override
  $WordsTable createAlias(String alias) {
    return $WordsTable(attachedDatabase, alias);
  }
}

class WordData extends DataClass implements Insertable<WordData> {
  final int id;
  final String level;
  final String act;
  final String word;
  final String hiragana;
  final String korean;
  final bool isRead;
  final int wrongCnt;
  const WordData({
    required this.id,
    required this.level,
    required this.act,
    required this.word,
    required this.hiragana,
    required this.korean,
    required this.isRead,
    required this.wrongCnt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level'] = Variable<String>(level);
    map['act'] = Variable<String>(act);
    map['word'] = Variable<String>(word);
    map['hiragana'] = Variable<String>(hiragana);
    map['korean'] = Variable<String>(korean);
    map['is_read'] = Variable<bool>(isRead);
    map['wrong_cnt'] = Variable<int>(wrongCnt);
    return map;
  }

  WordsCompanion toCompanion(bool nullToAbsent) {
    return WordsCompanion(
      id: Value(id),
      level: Value(level),
      act: Value(act),
      word: Value(word),
      hiragana: Value(hiragana),
      korean: Value(korean),
      isRead: Value(isRead),
      wrongCnt: Value(wrongCnt),
    );
  }

  factory WordData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WordData(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String>(json['level']),
      act: serializer.fromJson<String>(json['act']),
      word: serializer.fromJson<String>(json['word']),
      hiragana: serializer.fromJson<String>(json['hiragana']),
      korean: serializer.fromJson<String>(json['korean']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      wrongCnt: serializer.fromJson<int>(json['wrongCnt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String>(level),
      'act': serializer.toJson<String>(act),
      'word': serializer.toJson<String>(word),
      'hiragana': serializer.toJson<String>(hiragana),
      'korean': serializer.toJson<String>(korean),
      'isRead': serializer.toJson<bool>(isRead),
      'wrongCnt': serializer.toJson<int>(wrongCnt),
    };
  }

  WordData copyWith({
    int? id,
    String? level,
    String? act,
    String? word,
    String? hiragana,
    String? korean,
    bool? isRead,
    int? wrongCnt,
  }) => WordData(
    id: id ?? this.id,
    level: level ?? this.level,
    act: act ?? this.act,
    word: word ?? this.word,
    hiragana: hiragana ?? this.hiragana,
    korean: korean ?? this.korean,
    isRead: isRead ?? this.isRead,
    wrongCnt: wrongCnt ?? this.wrongCnt,
  );
  WordData copyWithCompanion(WordsCompanion data) {
    return WordData(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      act: data.act.present ? data.act.value : this.act,
      word: data.word.present ? data.word.value : this.word,
      hiragana: data.hiragana.present ? data.hiragana.value : this.hiragana,
      korean: data.korean.present ? data.korean.value : this.korean,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      wrongCnt: data.wrongCnt.present ? data.wrongCnt.value : this.wrongCnt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WordData(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('act: $act, ')
          ..write('word: $word, ')
          ..write('hiragana: $hiragana, ')
          ..write('korean: $korean, ')
          ..write('isRead: $isRead, ')
          ..write('wrongCnt: $wrongCnt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, level, act, word, hiragana, korean, isRead, wrongCnt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WordData &&
          other.id == this.id &&
          other.level == this.level &&
          other.act == this.act &&
          other.word == this.word &&
          other.hiragana == this.hiragana &&
          other.korean == this.korean &&
          other.isRead == this.isRead &&
          other.wrongCnt == this.wrongCnt);
}

class WordsCompanion extends UpdateCompanion<WordData> {
  final Value<int> id;
  final Value<String> level;
  final Value<String> act;
  final Value<String> word;
  final Value<String> hiragana;
  final Value<String> korean;
  final Value<bool> isRead;
  final Value<int> wrongCnt;
  const WordsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.act = const Value.absent(),
    this.word = const Value.absent(),
    this.hiragana = const Value.absent(),
    this.korean = const Value.absent(),
    this.isRead = const Value.absent(),
    this.wrongCnt = const Value.absent(),
  });
  WordsCompanion.insert({
    this.id = const Value.absent(),
    required String level,
    required String act,
    required String word,
    required String hiragana,
    required String korean,
    this.isRead = const Value.absent(),
    this.wrongCnt = const Value.absent(),
  }) : level = Value(level),
       act = Value(act),
       word = Value(word),
       hiragana = Value(hiragana),
       korean = Value(korean);
  static Insertable<WordData> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? act,
    Expression<String>? word,
    Expression<String>? hiragana,
    Expression<String>? korean,
    Expression<bool>? isRead,
    Expression<int>? wrongCnt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (act != null) 'act': act,
      if (word != null) 'word': word,
      if (hiragana != null) 'hiragana': hiragana,
      if (korean != null) 'korean': korean,
      if (isRead != null) 'is_read': isRead,
      if (wrongCnt != null) 'wrong_cnt': wrongCnt,
    });
  }

  WordsCompanion copyWith({
    Value<int>? id,
    Value<String>? level,
    Value<String>? act,
    Value<String>? word,
    Value<String>? hiragana,
    Value<String>? korean,
    Value<bool>? isRead,
    Value<int>? wrongCnt,
  }) {
    return WordsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      act: act ?? this.act,
      word: word ?? this.word,
      hiragana: hiragana ?? this.hiragana,
      korean: korean ?? this.korean,
      isRead: isRead ?? this.isRead,
      wrongCnt: wrongCnt ?? this.wrongCnt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (act.present) {
      map['act'] = Variable<String>(act.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (hiragana.present) {
      map['hiragana'] = Variable<String>(hiragana.value);
    }
    if (korean.present) {
      map['korean'] = Variable<String>(korean.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (wrongCnt.present) {
      map['wrong_cnt'] = Variable<int>(wrongCnt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WordsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('act: $act, ')
          ..write('word: $word, ')
          ..write('hiragana: $hiragana, ')
          ..write('korean: $korean, ')
          ..write('isRead: $isRead, ')
          ..write('wrongCnt: $wrongCnt')
          ..write(')'))
        .toString();
  }
}

class $ChineseCharsTable extends ChineseChars
    with TableInfo<$ChineseCharsTable, ChineseCharData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChineseCharsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _charMeta = const VerificationMeta('char');
  @override
  late final GeneratedColumn<String> char = GeneratedColumn<String>(
    'char',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _koreanCharMeta = const VerificationMeta(
    'koreanChar',
  );
  @override
  late final GeneratedColumn<String> koreanChar = GeneratedColumn<String>(
    'korean_char',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _soundReadingMeta = const VerificationMeta(
    'soundReading',
  );
  @override
  late final GeneratedColumn<String> soundReading = GeneratedColumn<String>(
    'sound_reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meanReadingMeta = const VerificationMeta(
    'meanReading',
  );
  @override
  late final GeneratedColumn<String> meanReading = GeneratedColumn<String>(
    'mean_reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    char,
    koreanChar,
    soundReading,
    meanReading,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chinese_chars';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChineseCharData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('char')) {
      context.handle(
        _charMeta,
        char.isAcceptableOrUnknown(data['char']!, _charMeta),
      );
    } else if (isInserting) {
      context.missing(_charMeta);
    }
    if (data.containsKey('korean_char')) {
      context.handle(
        _koreanCharMeta,
        koreanChar.isAcceptableOrUnknown(data['korean_char']!, _koreanCharMeta),
      );
    } else if (isInserting) {
      context.missing(_koreanCharMeta);
    }
    if (data.containsKey('sound_reading')) {
      context.handle(
        _soundReadingMeta,
        soundReading.isAcceptableOrUnknown(
          data['sound_reading']!,
          _soundReadingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_soundReadingMeta);
    }
    if (data.containsKey('mean_reading')) {
      context.handle(
        _meanReadingMeta,
        meanReading.isAcceptableOrUnknown(
          data['mean_reading']!,
          _meanReadingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meanReadingMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {char};
  @override
  ChineseCharData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChineseCharData(
      char: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}char'],
      )!,
      koreanChar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}korean_char'],
      )!,
      soundReading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound_reading'],
      )!,
      meanReading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mean_reading'],
      )!,
    );
  }

  @override
  $ChineseCharsTable createAlias(String alias) {
    return $ChineseCharsTable(attachedDatabase, alias);
  }
}

class ChineseCharData extends DataClass implements Insertable<ChineseCharData> {
  final String char;
  final String koreanChar;
  final String soundReading;
  final String meanReading;
  const ChineseCharData({
    required this.char,
    required this.koreanChar,
    required this.soundReading,
    required this.meanReading,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['char'] = Variable<String>(char);
    map['korean_char'] = Variable<String>(koreanChar);
    map['sound_reading'] = Variable<String>(soundReading);
    map['mean_reading'] = Variable<String>(meanReading);
    return map;
  }

  ChineseCharsCompanion toCompanion(bool nullToAbsent) {
    return ChineseCharsCompanion(
      char: Value(char),
      koreanChar: Value(koreanChar),
      soundReading: Value(soundReading),
      meanReading: Value(meanReading),
    );
  }

  factory ChineseCharData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChineseCharData(
      char: serializer.fromJson<String>(json['char']),
      koreanChar: serializer.fromJson<String>(json['koreanChar']),
      soundReading: serializer.fromJson<String>(json['soundReading']),
      meanReading: serializer.fromJson<String>(json['meanReading']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'char': serializer.toJson<String>(char),
      'koreanChar': serializer.toJson<String>(koreanChar),
      'soundReading': serializer.toJson<String>(soundReading),
      'meanReading': serializer.toJson<String>(meanReading),
    };
  }

  ChineseCharData copyWith({
    String? char,
    String? koreanChar,
    String? soundReading,
    String? meanReading,
  }) => ChineseCharData(
    char: char ?? this.char,
    koreanChar: koreanChar ?? this.koreanChar,
    soundReading: soundReading ?? this.soundReading,
    meanReading: meanReading ?? this.meanReading,
  );
  ChineseCharData copyWithCompanion(ChineseCharsCompanion data) {
    return ChineseCharData(
      char: data.char.present ? data.char.value : this.char,
      koreanChar: data.koreanChar.present
          ? data.koreanChar.value
          : this.koreanChar,
      soundReading: data.soundReading.present
          ? data.soundReading.value
          : this.soundReading,
      meanReading: data.meanReading.present
          ? data.meanReading.value
          : this.meanReading,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChineseCharData(')
          ..write('char: $char, ')
          ..write('koreanChar: $koreanChar, ')
          ..write('soundReading: $soundReading, ')
          ..write('meanReading: $meanReading')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(char, koreanChar, soundReading, meanReading);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChineseCharData &&
          other.char == this.char &&
          other.koreanChar == this.koreanChar &&
          other.soundReading == this.soundReading &&
          other.meanReading == this.meanReading);
}

class ChineseCharsCompanion extends UpdateCompanion<ChineseCharData> {
  final Value<String> char;
  final Value<String> koreanChar;
  final Value<String> soundReading;
  final Value<String> meanReading;
  final Value<int> rowid;
  const ChineseCharsCompanion({
    this.char = const Value.absent(),
    this.koreanChar = const Value.absent(),
    this.soundReading = const Value.absent(),
    this.meanReading = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChineseCharsCompanion.insert({
    required String char,
    required String koreanChar,
    required String soundReading,
    required String meanReading,
    this.rowid = const Value.absent(),
  }) : char = Value(char),
       koreanChar = Value(koreanChar),
       soundReading = Value(soundReading),
       meanReading = Value(meanReading);
  static Insertable<ChineseCharData> custom({
    Expression<String>? char,
    Expression<String>? koreanChar,
    Expression<String>? soundReading,
    Expression<String>? meanReading,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (char != null) 'char': char,
      if (koreanChar != null) 'korean_char': koreanChar,
      if (soundReading != null) 'sound_reading': soundReading,
      if (meanReading != null) 'mean_reading': meanReading,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChineseCharsCompanion copyWith({
    Value<String>? char,
    Value<String>? koreanChar,
    Value<String>? soundReading,
    Value<String>? meanReading,
    Value<int>? rowid,
  }) {
    return ChineseCharsCompanion(
      char: char ?? this.char,
      koreanChar: koreanChar ?? this.koreanChar,
      soundReading: soundReading ?? this.soundReading,
      meanReading: meanReading ?? this.meanReading,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (char.present) {
      map['char'] = Variable<String>(char.value);
    }
    if (koreanChar.present) {
      map['korean_char'] = Variable<String>(koreanChar.value);
    }
    if (soundReading.present) {
      map['sound_reading'] = Variable<String>(soundReading.value);
    }
    if (meanReading.present) {
      map['mean_reading'] = Variable<String>(meanReading.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChineseCharsCompanion(')
          ..write('char: $char, ')
          ..write('koreanChar: $koreanChar, ')
          ..write('soundReading: $soundReading, ')
          ..write('meanReading: $meanReading, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TestResultsTable extends TestResults
    with TableInfo<$TestResultsTable, TestResultData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
    'taken_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeSecondsMeta = const VerificationMeta(
    'timeSeconds',
  );
  @override
  late final GeneratedColumn<int> timeSeconds = GeneratedColumn<int>(
    'time_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, level, type, takenAt, timeSeconds];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestResultData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    } else if (isInserting) {
      context.missing(_takenAtMeta);
    }
    if (data.containsKey('time_seconds')) {
      context.handle(
        _timeSecondsMeta,
        timeSeconds.isAcceptableOrUnknown(
          data['time_seconds']!,
          _timeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeSecondsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestResultData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestResultData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taken_at'],
      )!,
      timeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_seconds'],
      )!,
    );
  }

  @override
  $TestResultsTable createAlias(String alias) {
    return $TestResultsTable(attachedDatabase, alias);
  }
}

class TestResultData extends DataClass implements Insertable<TestResultData> {
  final int id;
  final String? level;
  final String type;
  final DateTime takenAt;
  final int timeSeconds;
  const TestResultData({
    required this.id,
    this.level,
    required this.type,
    required this.takenAt,
    required this.timeSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<String>(level);
    }
    map['type'] = Variable<String>(type);
    map['taken_at'] = Variable<DateTime>(takenAt);
    map['time_seconds'] = Variable<int>(timeSeconds);
    return map;
  }

  TestResultsCompanion toCompanion(bool nullToAbsent) {
    return TestResultsCompanion(
      id: Value(id),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      type: Value(type),
      takenAt: Value(takenAt),
      timeSeconds: Value(timeSeconds),
    );
  }

  factory TestResultData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestResultData(
      id: serializer.fromJson<int>(json['id']),
      level: serializer.fromJson<String?>(json['level']),
      type: serializer.fromJson<String>(json['type']),
      takenAt: serializer.fromJson<DateTime>(json['takenAt']),
      timeSeconds: serializer.fromJson<int>(json['timeSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'level': serializer.toJson<String?>(level),
      'type': serializer.toJson<String>(type),
      'takenAt': serializer.toJson<DateTime>(takenAt),
      'timeSeconds': serializer.toJson<int>(timeSeconds),
    };
  }

  TestResultData copyWith({
    int? id,
    Value<String?> level = const Value.absent(),
    String? type,
    DateTime? takenAt,
    int? timeSeconds,
  }) => TestResultData(
    id: id ?? this.id,
    level: level.present ? level.value : this.level,
    type: type ?? this.type,
    takenAt: takenAt ?? this.takenAt,
    timeSeconds: timeSeconds ?? this.timeSeconds,
  );
  TestResultData copyWithCompanion(TestResultsCompanion data) {
    return TestResultData(
      id: data.id.present ? data.id.value : this.id,
      level: data.level.present ? data.level.value : this.level,
      type: data.type.present ? data.type.value : this.type,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      timeSeconds: data.timeSeconds.present
          ? data.timeSeconds.value
          : this.timeSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestResultData(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('type: $type, ')
          ..write('takenAt: $takenAt, ')
          ..write('timeSeconds: $timeSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, level, type, takenAt, timeSeconds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestResultData &&
          other.id == this.id &&
          other.level == this.level &&
          other.type == this.type &&
          other.takenAt == this.takenAt &&
          other.timeSeconds == this.timeSeconds);
}

class TestResultsCompanion extends UpdateCompanion<TestResultData> {
  final Value<int> id;
  final Value<String?> level;
  final Value<String> type;
  final Value<DateTime> takenAt;
  final Value<int> timeSeconds;
  const TestResultsCompanion({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    this.type = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.timeSeconds = const Value.absent(),
  });
  TestResultsCompanion.insert({
    this.id = const Value.absent(),
    this.level = const Value.absent(),
    required String type,
    required DateTime takenAt,
    required int timeSeconds,
  }) : type = Value(type),
       takenAt = Value(takenAt),
       timeSeconds = Value(timeSeconds);
  static Insertable<TestResultData> custom({
    Expression<int>? id,
    Expression<String>? level,
    Expression<String>? type,
    Expression<DateTime>? takenAt,
    Expression<int>? timeSeconds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (level != null) 'level': level,
      if (type != null) 'type': type,
      if (takenAt != null) 'taken_at': takenAt,
      if (timeSeconds != null) 'time_seconds': timeSeconds,
    });
  }

  TestResultsCompanion copyWith({
    Value<int>? id,
    Value<String?>? level,
    Value<String>? type,
    Value<DateTime>? takenAt,
    Value<int>? timeSeconds,
  }) {
    return TestResultsCompanion(
      id: id ?? this.id,
      level: level ?? this.level,
      type: type ?? this.type,
      takenAt: takenAt ?? this.takenAt,
      timeSeconds: timeSeconds ?? this.timeSeconds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (timeSeconds.present) {
      map['time_seconds'] = Variable<int>(timeSeconds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestResultsCompanion(')
          ..write('id: $id, ')
          ..write('level: $level, ')
          ..write('type: $type, ')
          ..write('takenAt: $takenAt, ')
          ..write('timeSeconds: $timeSeconds')
          ..write(')'))
        .toString();
  }
}

class $TestQuestionsTable extends TestQuestions
    with TableInfo<$TestQuestionsTable, TestQuestionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TestQuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _testResultIdMeta = const VerificationMeta(
    'testResultId',
  );
  @override
  late final GeneratedColumn<int> testResultId = GeneratedColumn<int>(
    'test_result_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES test_results (id)',
    ),
  );
  static const VerificationMeta _questionWordIdMeta = const VerificationMeta(
    'questionWordId',
  );
  @override
  late final GeneratedColumn<int> questionWordId = GeneratedColumn<int>(
    'question_word_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _myAnswerWordIdMeta = const VerificationMeta(
    'myAnswerWordId',
  );
  @override
  late final GeneratedColumn<int> myAnswerWordId = GeneratedColumn<int>(
    'my_answer_word_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _reverseMeta = const VerificationMeta(
    'reverse',
  );
  @override
  late final GeneratedColumn<bool> reverse = GeneratedColumn<bool>(
    'reverse',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reverse" IN (0, 1))',
    ),
  );
  static const VerificationMeta _examplesJsonMeta = const VerificationMeta(
    'examplesJson',
  );
  @override
  late final GeneratedColumn<String> examplesJson = GeneratedColumn<String>(
    'examples_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    testResultId,
    questionWordId,
    myAnswerWordId,
    isCorrect,
    reverse,
    examplesJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'test_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TestQuestionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('test_result_id')) {
      context.handle(
        _testResultIdMeta,
        testResultId.isAcceptableOrUnknown(
          data['test_result_id']!,
          _testResultIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_testResultIdMeta);
    }
    if (data.containsKey('question_word_id')) {
      context.handle(
        _questionWordIdMeta,
        questionWordId.isAcceptableOrUnknown(
          data['question_word_id']!,
          _questionWordIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionWordIdMeta);
    }
    if (data.containsKey('my_answer_word_id')) {
      context.handle(
        _myAnswerWordIdMeta,
        myAnswerWordId.isAcceptableOrUnknown(
          data['my_answer_word_id']!,
          _myAnswerWordIdMeta,
        ),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('reverse')) {
      context.handle(
        _reverseMeta,
        reverse.isAcceptableOrUnknown(data['reverse']!, _reverseMeta),
      );
    } else if (isInserting) {
      context.missing(_reverseMeta);
    }
    if (data.containsKey('examples_json')) {
      context.handle(
        _examplesJsonMeta,
        examplesJson.isAcceptableOrUnknown(
          data['examples_json']!,
          _examplesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_examplesJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TestQuestionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TestQuestionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      testResultId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}test_result_id'],
      )!,
      questionWordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_word_id'],
      )!,
      myAnswerWordId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}my_answer_word_id'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      reverse: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reverse'],
      )!,
      examplesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples_json'],
      )!,
    );
  }

  @override
  $TestQuestionsTable createAlias(String alias) {
    return $TestQuestionsTable(attachedDatabase, alias);
  }
}

class TestQuestionData extends DataClass
    implements Insertable<TestQuestionData> {
  final int id;
  final int testResultId;
  final int questionWordId;
  final int? myAnswerWordId;
  final bool isCorrect;
  final bool reverse;
  final String examplesJson;
  const TestQuestionData({
    required this.id,
    required this.testResultId,
    required this.questionWordId,
    this.myAnswerWordId,
    required this.isCorrect,
    required this.reverse,
    required this.examplesJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['test_result_id'] = Variable<int>(testResultId);
    map['question_word_id'] = Variable<int>(questionWordId);
    if (!nullToAbsent || myAnswerWordId != null) {
      map['my_answer_word_id'] = Variable<int>(myAnswerWordId);
    }
    map['is_correct'] = Variable<bool>(isCorrect);
    map['reverse'] = Variable<bool>(reverse);
    map['examples_json'] = Variable<String>(examplesJson);
    return map;
  }

  TestQuestionsCompanion toCompanion(bool nullToAbsent) {
    return TestQuestionsCompanion(
      id: Value(id),
      testResultId: Value(testResultId),
      questionWordId: Value(questionWordId),
      myAnswerWordId: myAnswerWordId == null && nullToAbsent
          ? const Value.absent()
          : Value(myAnswerWordId),
      isCorrect: Value(isCorrect),
      reverse: Value(reverse),
      examplesJson: Value(examplesJson),
    );
  }

  factory TestQuestionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TestQuestionData(
      id: serializer.fromJson<int>(json['id']),
      testResultId: serializer.fromJson<int>(json['testResultId']),
      questionWordId: serializer.fromJson<int>(json['questionWordId']),
      myAnswerWordId: serializer.fromJson<int?>(json['myAnswerWordId']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      reverse: serializer.fromJson<bool>(json['reverse']),
      examplesJson: serializer.fromJson<String>(json['examplesJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'testResultId': serializer.toJson<int>(testResultId),
      'questionWordId': serializer.toJson<int>(questionWordId),
      'myAnswerWordId': serializer.toJson<int?>(myAnswerWordId),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'reverse': serializer.toJson<bool>(reverse),
      'examplesJson': serializer.toJson<String>(examplesJson),
    };
  }

  TestQuestionData copyWith({
    int? id,
    int? testResultId,
    int? questionWordId,
    Value<int?> myAnswerWordId = const Value.absent(),
    bool? isCorrect,
    bool? reverse,
    String? examplesJson,
  }) => TestQuestionData(
    id: id ?? this.id,
    testResultId: testResultId ?? this.testResultId,
    questionWordId: questionWordId ?? this.questionWordId,
    myAnswerWordId: myAnswerWordId.present
        ? myAnswerWordId.value
        : this.myAnswerWordId,
    isCorrect: isCorrect ?? this.isCorrect,
    reverse: reverse ?? this.reverse,
    examplesJson: examplesJson ?? this.examplesJson,
  );
  TestQuestionData copyWithCompanion(TestQuestionsCompanion data) {
    return TestQuestionData(
      id: data.id.present ? data.id.value : this.id,
      testResultId: data.testResultId.present
          ? data.testResultId.value
          : this.testResultId,
      questionWordId: data.questionWordId.present
          ? data.questionWordId.value
          : this.questionWordId,
      myAnswerWordId: data.myAnswerWordId.present
          ? data.myAnswerWordId.value
          : this.myAnswerWordId,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      reverse: data.reverse.present ? data.reverse.value : this.reverse,
      examplesJson: data.examplesJson.present
          ? data.examplesJson.value
          : this.examplesJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TestQuestionData(')
          ..write('id: $id, ')
          ..write('testResultId: $testResultId, ')
          ..write('questionWordId: $questionWordId, ')
          ..write('myAnswerWordId: $myAnswerWordId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('reverse: $reverse, ')
          ..write('examplesJson: $examplesJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    testResultId,
    questionWordId,
    myAnswerWordId,
    isCorrect,
    reverse,
    examplesJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TestQuestionData &&
          other.id == this.id &&
          other.testResultId == this.testResultId &&
          other.questionWordId == this.questionWordId &&
          other.myAnswerWordId == this.myAnswerWordId &&
          other.isCorrect == this.isCorrect &&
          other.reverse == this.reverse &&
          other.examplesJson == this.examplesJson);
}

class TestQuestionsCompanion extends UpdateCompanion<TestQuestionData> {
  final Value<int> id;
  final Value<int> testResultId;
  final Value<int> questionWordId;
  final Value<int?> myAnswerWordId;
  final Value<bool> isCorrect;
  final Value<bool> reverse;
  final Value<String> examplesJson;
  const TestQuestionsCompanion({
    this.id = const Value.absent(),
    this.testResultId = const Value.absent(),
    this.questionWordId = const Value.absent(),
    this.myAnswerWordId = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.reverse = const Value.absent(),
    this.examplesJson = const Value.absent(),
  });
  TestQuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int testResultId,
    required int questionWordId,
    this.myAnswerWordId = const Value.absent(),
    required bool isCorrect,
    required bool reverse,
    required String examplesJson,
  }) : testResultId = Value(testResultId),
       questionWordId = Value(questionWordId),
       isCorrect = Value(isCorrect),
       reverse = Value(reverse),
       examplesJson = Value(examplesJson);
  static Insertable<TestQuestionData> custom({
    Expression<int>? id,
    Expression<int>? testResultId,
    Expression<int>? questionWordId,
    Expression<int>? myAnswerWordId,
    Expression<bool>? isCorrect,
    Expression<bool>? reverse,
    Expression<String>? examplesJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (testResultId != null) 'test_result_id': testResultId,
      if (questionWordId != null) 'question_word_id': questionWordId,
      if (myAnswerWordId != null) 'my_answer_word_id': myAnswerWordId,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (reverse != null) 'reverse': reverse,
      if (examplesJson != null) 'examples_json': examplesJson,
    });
  }

  TestQuestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? testResultId,
    Value<int>? questionWordId,
    Value<int?>? myAnswerWordId,
    Value<bool>? isCorrect,
    Value<bool>? reverse,
    Value<String>? examplesJson,
  }) {
    return TestQuestionsCompanion(
      id: id ?? this.id,
      testResultId: testResultId ?? this.testResultId,
      questionWordId: questionWordId ?? this.questionWordId,
      myAnswerWordId: myAnswerWordId ?? this.myAnswerWordId,
      isCorrect: isCorrect ?? this.isCorrect,
      reverse: reverse ?? this.reverse,
      examplesJson: examplesJson ?? this.examplesJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (testResultId.present) {
      map['test_result_id'] = Variable<int>(testResultId.value);
    }
    if (questionWordId.present) {
      map['question_word_id'] = Variable<int>(questionWordId.value);
    }
    if (myAnswerWordId.present) {
      map['my_answer_word_id'] = Variable<int>(myAnswerWordId.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (reverse.present) {
      map['reverse'] = Variable<bool>(reverse.value);
    }
    if (examplesJson.present) {
      map['examples_json'] = Variable<String>(examplesJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TestQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('testResultId: $testResultId, ')
          ..write('questionWordId: $questionWordId, ')
          ..write('myAnswerWordId: $myAnswerWordId, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('reverse: $reverse, ')
          ..write('examplesJson: $examplesJson')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyStatsTable extends DailyStats
    with TableInfo<$DailyStatsTable, DailyStatData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<int> date = GeneratedColumn<int>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studySecondsMeta = const VerificationMeta(
    'studySeconds',
  );
  @override
  late final GeneratedColumn<int> studySeconds = GeneratedColumn<int>(
    'study_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wordsLearnedMeta = const VerificationMeta(
    'wordsLearned',
  );
  @override
  late final GeneratedColumn<int> wordsLearned = GeneratedColumn<int>(
    'words_learned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _grammarsLearnedMeta = const VerificationMeta(
    'grammarsLearned',
  );
  @override
  late final GeneratedColumn<int> grammarsLearned = GeneratedColumn<int>(
    'grammars_learned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _testsTakenMeta = const VerificationMeta(
    'testsTaken',
  );
  @override
  late final GeneratedColumn<int> testsTaken = GeneratedColumn<int>(
    'tests_taken',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalAnswersMeta = const VerificationMeta(
    'totalAnswers',
  );
  @override
  late final GeneratedColumn<int> totalAnswers = GeneratedColumn<int>(
    'total_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    studySeconds,
    wordsLearned,
    grammarsLearned,
    testsTaken,
    correctAnswers,
    totalAnswers,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStatData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('study_seconds')) {
      context.handle(
        _studySecondsMeta,
        studySeconds.isAcceptableOrUnknown(
          data['study_seconds']!,
          _studySecondsMeta,
        ),
      );
    }
    if (data.containsKey('words_learned')) {
      context.handle(
        _wordsLearnedMeta,
        wordsLearned.isAcceptableOrUnknown(
          data['words_learned']!,
          _wordsLearnedMeta,
        ),
      );
    }
    if (data.containsKey('grammars_learned')) {
      context.handle(
        _grammarsLearnedMeta,
        grammarsLearned.isAcceptableOrUnknown(
          data['grammars_learned']!,
          _grammarsLearnedMeta,
        ),
      );
    }
    if (data.containsKey('tests_taken')) {
      context.handle(
        _testsTakenMeta,
        testsTaken.isAcceptableOrUnknown(data['tests_taken']!, _testsTakenMeta),
      );
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    }
    if (data.containsKey('total_answers')) {
      context.handle(
        _totalAnswersMeta,
        totalAnswers.isAcceptableOrUnknown(
          data['total_answers']!,
          _totalAnswersMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyStatData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStatData(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}date'],
      )!,
      studySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}study_seconds'],
      )!,
      wordsLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}words_learned'],
      )!,
      grammarsLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grammars_learned'],
      )!,
      testsTaken: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tests_taken'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      totalAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_answers'],
      )!,
    );
  }

  @override
  $DailyStatsTable createAlias(String alias) {
    return $DailyStatsTable(attachedDatabase, alias);
  }
}

class DailyStatData extends DataClass implements Insertable<DailyStatData> {
  final int date;
  final int studySeconds;
  final int wordsLearned;
  final int grammarsLearned;
  final int testsTaken;
  final int correctAnswers;
  final int totalAnswers;
  const DailyStatData({
    required this.date,
    required this.studySeconds,
    required this.wordsLearned,
    required this.grammarsLearned,
    required this.testsTaken,
    required this.correctAnswers,
    required this.totalAnswers,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<int>(date);
    map['study_seconds'] = Variable<int>(studySeconds);
    map['words_learned'] = Variable<int>(wordsLearned);
    map['grammars_learned'] = Variable<int>(grammarsLearned);
    map['tests_taken'] = Variable<int>(testsTaken);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['total_answers'] = Variable<int>(totalAnswers);
    return map;
  }

  DailyStatsCompanion toCompanion(bool nullToAbsent) {
    return DailyStatsCompanion(
      date: Value(date),
      studySeconds: Value(studySeconds),
      wordsLearned: Value(wordsLearned),
      grammarsLearned: Value(grammarsLearned),
      testsTaken: Value(testsTaken),
      correctAnswers: Value(correctAnswers),
      totalAnswers: Value(totalAnswers),
    );
  }

  factory DailyStatData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStatData(
      date: serializer.fromJson<int>(json['date']),
      studySeconds: serializer.fromJson<int>(json['studySeconds']),
      wordsLearned: serializer.fromJson<int>(json['wordsLearned']),
      grammarsLearned: serializer.fromJson<int>(json['grammarsLearned']),
      testsTaken: serializer.fromJson<int>(json['testsTaken']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      totalAnswers: serializer.fromJson<int>(json['totalAnswers']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<int>(date),
      'studySeconds': serializer.toJson<int>(studySeconds),
      'wordsLearned': serializer.toJson<int>(wordsLearned),
      'grammarsLearned': serializer.toJson<int>(grammarsLearned),
      'testsTaken': serializer.toJson<int>(testsTaken),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'totalAnswers': serializer.toJson<int>(totalAnswers),
    };
  }

  DailyStatData copyWith({
    int? date,
    int? studySeconds,
    int? wordsLearned,
    int? grammarsLearned,
    int? testsTaken,
    int? correctAnswers,
    int? totalAnswers,
  }) => DailyStatData(
    date: date ?? this.date,
    studySeconds: studySeconds ?? this.studySeconds,
    wordsLearned: wordsLearned ?? this.wordsLearned,
    grammarsLearned: grammarsLearned ?? this.grammarsLearned,
    testsTaken: testsTaken ?? this.testsTaken,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    totalAnswers: totalAnswers ?? this.totalAnswers,
  );
  DailyStatData copyWithCompanion(DailyStatsCompanion data) {
    return DailyStatData(
      date: data.date.present ? data.date.value : this.date,
      studySeconds: data.studySeconds.present
          ? data.studySeconds.value
          : this.studySeconds,
      wordsLearned: data.wordsLearned.present
          ? data.wordsLearned.value
          : this.wordsLearned,
      grammarsLearned: data.grammarsLearned.present
          ? data.grammarsLearned.value
          : this.grammarsLearned,
      testsTaken: data.testsTaken.present
          ? data.testsTaken.value
          : this.testsTaken,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      totalAnswers: data.totalAnswers.present
          ? data.totalAnswers.value
          : this.totalAnswers,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatData(')
          ..write('date: $date, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('wordsLearned: $wordsLearned, ')
          ..write('grammarsLearned: $grammarsLearned, ')
          ..write('testsTaken: $testsTaken, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalAnswers: $totalAnswers')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    studySeconds,
    wordsLearned,
    grammarsLearned,
    testsTaken,
    correctAnswers,
    totalAnswers,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStatData &&
          other.date == this.date &&
          other.studySeconds == this.studySeconds &&
          other.wordsLearned == this.wordsLearned &&
          other.grammarsLearned == this.grammarsLearned &&
          other.testsTaken == this.testsTaken &&
          other.correctAnswers == this.correctAnswers &&
          other.totalAnswers == this.totalAnswers);
}

class DailyStatsCompanion extends UpdateCompanion<DailyStatData> {
  final Value<int> date;
  final Value<int> studySeconds;
  final Value<int> wordsLearned;
  final Value<int> grammarsLearned;
  final Value<int> testsTaken;
  final Value<int> correctAnswers;
  final Value<int> totalAnswers;
  const DailyStatsCompanion({
    this.date = const Value.absent(),
    this.studySeconds = const Value.absent(),
    this.wordsLearned = const Value.absent(),
    this.grammarsLearned = const Value.absent(),
    this.testsTaken = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.totalAnswers = const Value.absent(),
  });
  DailyStatsCompanion.insert({
    this.date = const Value.absent(),
    this.studySeconds = const Value.absent(),
    this.wordsLearned = const Value.absent(),
    this.grammarsLearned = const Value.absent(),
    this.testsTaken = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.totalAnswers = const Value.absent(),
  });
  static Insertable<DailyStatData> custom({
    Expression<int>? date,
    Expression<int>? studySeconds,
    Expression<int>? wordsLearned,
    Expression<int>? grammarsLearned,
    Expression<int>? testsTaken,
    Expression<int>? correctAnswers,
    Expression<int>? totalAnswers,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (studySeconds != null) 'study_seconds': studySeconds,
      if (wordsLearned != null) 'words_learned': wordsLearned,
      if (grammarsLearned != null) 'grammars_learned': grammarsLearned,
      if (testsTaken != null) 'tests_taken': testsTaken,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (totalAnswers != null) 'total_answers': totalAnswers,
    });
  }

  DailyStatsCompanion copyWith({
    Value<int>? date,
    Value<int>? studySeconds,
    Value<int>? wordsLearned,
    Value<int>? grammarsLearned,
    Value<int>? testsTaken,
    Value<int>? correctAnswers,
    Value<int>? totalAnswers,
  }) {
    return DailyStatsCompanion(
      date: date ?? this.date,
      studySeconds: studySeconds ?? this.studySeconds,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      grammarsLearned: grammarsLearned ?? this.grammarsLearned,
      testsTaken: testsTaken ?? this.testsTaken,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<int>(date.value);
    }
    if (studySeconds.present) {
      map['study_seconds'] = Variable<int>(studySeconds.value);
    }
    if (wordsLearned.present) {
      map['words_learned'] = Variable<int>(wordsLearned.value);
    }
    if (grammarsLearned.present) {
      map['grammars_learned'] = Variable<int>(grammarsLearned.value);
    }
    if (testsTaken.present) {
      map['tests_taken'] = Variable<int>(testsTaken.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (totalAnswers.present) {
      map['total_answers'] = Variable<int>(totalAnswers.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatsCompanion(')
          ..write('date: $date, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('wordsLearned: $wordsLearned, ')
          ..write('grammarsLearned: $grammarsLearned, ')
          ..write('testsTaken: $testsTaken, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalAnswers: $totalAnswers')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $WordsTable words = $WordsTable(this);
  late final $ChineseCharsTable chineseChars = $ChineseCharsTable(this);
  late final $TestResultsTable testResults = $TestResultsTable(this);
  late final $TestQuestionsTable testQuestions = $TestQuestionsTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $DailyStatsTable dailyStats = $DailyStatsTable(this);
  late final WordDao wordDao = WordDao(this as AppDatabase);
  late final ChineseCharDao chineseCharDao = ChineseCharDao(
    this as AppDatabase,
  );
  late final TestResultDao testResultDao = TestResultDao(this as AppDatabase);
  late final AppMetaDao appMetaDao = AppMetaDao(this as AppDatabase);
  late final DailyStatDao dailyStatDao = DailyStatDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    words,
    chineseChars,
    testResults,
    testQuestions,
    appMeta,
    dailyStats,
  ];
}

typedef $$WordsTableCreateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      required String level,
      required String act,
      required String word,
      required String hiragana,
      required String korean,
      Value<bool> isRead,
      Value<int> wrongCnt,
    });
typedef $$WordsTableUpdateCompanionBuilder =
    WordsCompanion Function({
      Value<int> id,
      Value<String> level,
      Value<String> act,
      Value<String> word,
      Value<String> hiragana,
      Value<String> korean,
      Value<bool> isRead,
      Value<int> wrongCnt,
    });

class $$WordsTableFilterComposer extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get act => $composableBuilder(
    column: $table.act,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hiragana => $composableBuilder(
    column: $table.hiragana,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get korean => $composableBuilder(
    column: $table.korean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongCnt => $composableBuilder(
    column: $table.wrongCnt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WordsTableOrderingComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get act => $composableBuilder(
    column: $table.act,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hiragana => $composableBuilder(
    column: $table.hiragana,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get korean => $composableBuilder(
    column: $table.korean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongCnt => $composableBuilder(
    column: $table.wrongCnt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WordsTable> {
  $$WordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get act =>
      $composableBuilder(column: $table.act, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get hiragana =>
      $composableBuilder(column: $table.hiragana, builder: (column) => column);

  GeneratedColumn<String> get korean =>
      $composableBuilder(column: $table.korean, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<int> get wrongCnt =>
      $composableBuilder(column: $table.wrongCnt, builder: (column) => column);
}

class $$WordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WordsTable,
          WordData,
          $$WordsTableFilterComposer,
          $$WordsTableOrderingComposer,
          $$WordsTableAnnotationComposer,
          $$WordsTableCreateCompanionBuilder,
          $$WordsTableUpdateCompanionBuilder,
          (WordData, BaseReferences<_$AppDatabase, $WordsTable, WordData>),
          WordData,
          PrefetchHooks Function()
        > {
  $$WordsTableTableManager(_$AppDatabase db, $WordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> act = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> hiragana = const Value.absent(),
                Value<String> korean = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<int> wrongCnt = const Value.absent(),
              }) => WordsCompanion(
                id: id,
                level: level,
                act: act,
                word: word,
                hiragana: hiragana,
                korean: korean,
                isRead: isRead,
                wrongCnt: wrongCnt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String level,
                required String act,
                required String word,
                required String hiragana,
                required String korean,
                Value<bool> isRead = const Value.absent(),
                Value<int> wrongCnt = const Value.absent(),
              }) => WordsCompanion.insert(
                id: id,
                level: level,
                act: act,
                word: word,
                hiragana: hiragana,
                korean: korean,
                isRead: isRead,
                wrongCnt: wrongCnt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WordsTable,
      WordData,
      $$WordsTableFilterComposer,
      $$WordsTableOrderingComposer,
      $$WordsTableAnnotationComposer,
      $$WordsTableCreateCompanionBuilder,
      $$WordsTableUpdateCompanionBuilder,
      (WordData, BaseReferences<_$AppDatabase, $WordsTable, WordData>),
      WordData,
      PrefetchHooks Function()
    >;
typedef $$ChineseCharsTableCreateCompanionBuilder =
    ChineseCharsCompanion Function({
      required String char,
      required String koreanChar,
      required String soundReading,
      required String meanReading,
      Value<int> rowid,
    });
typedef $$ChineseCharsTableUpdateCompanionBuilder =
    ChineseCharsCompanion Function({
      Value<String> char,
      Value<String> koreanChar,
      Value<String> soundReading,
      Value<String> meanReading,
      Value<int> rowid,
    });

class $$ChineseCharsTableFilterComposer
    extends Composer<_$AppDatabase, $ChineseCharsTable> {
  $$ChineseCharsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get char => $composableBuilder(
    column: $table.char,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get koreanChar => $composableBuilder(
    column: $table.koreanChar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get soundReading => $composableBuilder(
    column: $table.soundReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meanReading => $composableBuilder(
    column: $table.meanReading,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChineseCharsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChineseCharsTable> {
  $$ChineseCharsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get char => $composableBuilder(
    column: $table.char,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get koreanChar => $composableBuilder(
    column: $table.koreanChar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get soundReading => $composableBuilder(
    column: $table.soundReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meanReading => $composableBuilder(
    column: $table.meanReading,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChineseCharsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChineseCharsTable> {
  $$ChineseCharsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get char =>
      $composableBuilder(column: $table.char, builder: (column) => column);

  GeneratedColumn<String> get koreanChar => $composableBuilder(
    column: $table.koreanChar,
    builder: (column) => column,
  );

  GeneratedColumn<String> get soundReading => $composableBuilder(
    column: $table.soundReading,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meanReading => $composableBuilder(
    column: $table.meanReading,
    builder: (column) => column,
  );
}

class $$ChineseCharsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChineseCharsTable,
          ChineseCharData,
          $$ChineseCharsTableFilterComposer,
          $$ChineseCharsTableOrderingComposer,
          $$ChineseCharsTableAnnotationComposer,
          $$ChineseCharsTableCreateCompanionBuilder,
          $$ChineseCharsTableUpdateCompanionBuilder,
          (
            ChineseCharData,
            BaseReferences<_$AppDatabase, $ChineseCharsTable, ChineseCharData>,
          ),
          ChineseCharData,
          PrefetchHooks Function()
        > {
  $$ChineseCharsTableTableManager(_$AppDatabase db, $ChineseCharsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChineseCharsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChineseCharsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChineseCharsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> char = const Value.absent(),
                Value<String> koreanChar = const Value.absent(),
                Value<String> soundReading = const Value.absent(),
                Value<String> meanReading = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChineseCharsCompanion(
                char: char,
                koreanChar: koreanChar,
                soundReading: soundReading,
                meanReading: meanReading,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String char,
                required String koreanChar,
                required String soundReading,
                required String meanReading,
                Value<int> rowid = const Value.absent(),
              }) => ChineseCharsCompanion.insert(
                char: char,
                koreanChar: koreanChar,
                soundReading: soundReading,
                meanReading: meanReading,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChineseCharsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChineseCharsTable,
      ChineseCharData,
      $$ChineseCharsTableFilterComposer,
      $$ChineseCharsTableOrderingComposer,
      $$ChineseCharsTableAnnotationComposer,
      $$ChineseCharsTableCreateCompanionBuilder,
      $$ChineseCharsTableUpdateCompanionBuilder,
      (
        ChineseCharData,
        BaseReferences<_$AppDatabase, $ChineseCharsTable, ChineseCharData>,
      ),
      ChineseCharData,
      PrefetchHooks Function()
    >;
typedef $$TestResultsTableCreateCompanionBuilder =
    TestResultsCompanion Function({
      Value<int> id,
      Value<String?> level,
      required String type,
      required DateTime takenAt,
      required int timeSeconds,
    });
typedef $$TestResultsTableUpdateCompanionBuilder =
    TestResultsCompanion Function({
      Value<int> id,
      Value<String?> level,
      Value<String> type,
      Value<DateTime> takenAt,
      Value<int> timeSeconds,
    });

final class $$TestResultsTableReferences
    extends BaseReferences<_$AppDatabase, $TestResultsTable, TestResultData> {
  $$TestResultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TestQuestionsTable, List<TestQuestionData>>
  _testQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.testQuestions,
    aliasName: $_aliasNameGenerator(
      db.testResults.id,
      db.testQuestions.testResultId,
    ),
  );

  $$TestQuestionsTableProcessedTableManager get testQuestionsRefs {
    final manager = $$TestQuestionsTableTableManager(
      $_db,
      $_db.testQuestions,
    ).filter((f) => f.testResultId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_testQuestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TestResultsTableFilterComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> testQuestionsRefs(
    Expression<bool> Function($$TestQuestionsTableFilterComposer f) f,
  ) {
    final $$TestQuestionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testQuestions,
      getReferencedColumn: (t) => t.testResultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestQuestionsTableFilterComposer(
            $db: $db,
            $table: $db.testQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TestResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestResultsTable> {
  $$TestResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<int> get timeSeconds => $composableBuilder(
    column: $table.timeSeconds,
    builder: (column) => column,
  );

  Expression<T> testQuestionsRefs<T extends Object>(
    Expression<T> Function($$TestQuestionsTableAnnotationComposer a) f,
  ) {
    final $$TestQuestionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.testQuestions,
      getReferencedColumn: (t) => t.testResultId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestQuestionsTableAnnotationComposer(
            $db: $db,
            $table: $db.testQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TestResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestResultsTable,
          TestResultData,
          $$TestResultsTableFilterComposer,
          $$TestResultsTableOrderingComposer,
          $$TestResultsTableAnnotationComposer,
          $$TestResultsTableCreateCompanionBuilder,
          $$TestResultsTableUpdateCompanionBuilder,
          (TestResultData, $$TestResultsTableReferences),
          TestResultData,
          PrefetchHooks Function({bool testQuestionsRefs})
        > {
  $$TestResultsTableTableManager(_$AppDatabase db, $TestResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> level = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<DateTime> takenAt = const Value.absent(),
                Value<int> timeSeconds = const Value.absent(),
              }) => TestResultsCompanion(
                id: id,
                level: level,
                type: type,
                takenAt: takenAt,
                timeSeconds: timeSeconds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> level = const Value.absent(),
                required String type,
                required DateTime takenAt,
                required int timeSeconds,
              }) => TestResultsCompanion.insert(
                id: id,
                level: level,
                type: type,
                takenAt: takenAt,
                timeSeconds: timeSeconds,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TestResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({testQuestionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (testQuestionsRefs) db.testQuestions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (testQuestionsRefs)
                    await $_getPrefetchedData<
                      TestResultData,
                      $TestResultsTable,
                      TestQuestionData
                    >(
                      currentTable: table,
                      referencedTable: $$TestResultsTableReferences
                          ._testQuestionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TestResultsTableReferences(
                            db,
                            table,
                            p0,
                          ).testQuestionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.testResultId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TestResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestResultsTable,
      TestResultData,
      $$TestResultsTableFilterComposer,
      $$TestResultsTableOrderingComposer,
      $$TestResultsTableAnnotationComposer,
      $$TestResultsTableCreateCompanionBuilder,
      $$TestResultsTableUpdateCompanionBuilder,
      (TestResultData, $$TestResultsTableReferences),
      TestResultData,
      PrefetchHooks Function({bool testQuestionsRefs})
    >;
typedef $$TestQuestionsTableCreateCompanionBuilder =
    TestQuestionsCompanion Function({
      Value<int> id,
      required int testResultId,
      required int questionWordId,
      Value<int?> myAnswerWordId,
      required bool isCorrect,
      required bool reverse,
      required String examplesJson,
    });
typedef $$TestQuestionsTableUpdateCompanionBuilder =
    TestQuestionsCompanion Function({
      Value<int> id,
      Value<int> testResultId,
      Value<int> questionWordId,
      Value<int?> myAnswerWordId,
      Value<bool> isCorrect,
      Value<bool> reverse,
      Value<String> examplesJson,
    });

final class $$TestQuestionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TestQuestionsTable, TestQuestionData> {
  $$TestQuestionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TestResultsTable _testResultIdTable(_$AppDatabase db) =>
      db.testResults.createAlias(
        $_aliasNameGenerator(db.testQuestions.testResultId, db.testResults.id),
      );

  $$TestResultsTableProcessedTableManager get testResultId {
    final $_column = $_itemColumn<int>('test_result_id')!;

    final manager = $$TestResultsTableTableManager(
      $_db,
      $_db.testResults,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_testResultIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TestQuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $TestQuestionsTable> {
  $$TestQuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionWordId => $composableBuilder(
    column: $table.questionWordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get myAnswerWordId => $composableBuilder(
    column: $table.myAnswerWordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reverse => $composableBuilder(
    column: $table.reverse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnFilters(column),
  );

  $$TestResultsTableFilterComposer get testResultId {
    final $$TestResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.testResultId,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableFilterComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestQuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TestQuestionsTable> {
  $$TestQuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionWordId => $composableBuilder(
    column: $table.questionWordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get myAnswerWordId => $composableBuilder(
    column: $table.myAnswerWordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reverse => $composableBuilder(
    column: $table.reverse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => ColumnOrderings(column),
  );

  $$TestResultsTableOrderingComposer get testResultId {
    final $$TestResultsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.testResultId,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableOrderingComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestQuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TestQuestionsTable> {
  $$TestQuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get questionWordId => $composableBuilder(
    column: $table.questionWordId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get myAnswerWordId => $composableBuilder(
    column: $table.myAnswerWordId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<bool> get reverse =>
      $composableBuilder(column: $table.reverse, builder: (column) => column);

  GeneratedColumn<String> get examplesJson => $composableBuilder(
    column: $table.examplesJson,
    builder: (column) => column,
  );

  $$TestResultsTableAnnotationComposer get testResultId {
    final $$TestResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.testResultId,
      referencedTable: $db.testResults,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TestResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.testResults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TestQuestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TestQuestionsTable,
          TestQuestionData,
          $$TestQuestionsTableFilterComposer,
          $$TestQuestionsTableOrderingComposer,
          $$TestQuestionsTableAnnotationComposer,
          $$TestQuestionsTableCreateCompanionBuilder,
          $$TestQuestionsTableUpdateCompanionBuilder,
          (TestQuestionData, $$TestQuestionsTableReferences),
          TestQuestionData,
          PrefetchHooks Function({bool testResultId})
        > {
  $$TestQuestionsTableTableManager(_$AppDatabase db, $TestQuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TestQuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TestQuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TestQuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> testResultId = const Value.absent(),
                Value<int> questionWordId = const Value.absent(),
                Value<int?> myAnswerWordId = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<bool> reverse = const Value.absent(),
                Value<String> examplesJson = const Value.absent(),
              }) => TestQuestionsCompanion(
                id: id,
                testResultId: testResultId,
                questionWordId: questionWordId,
                myAnswerWordId: myAnswerWordId,
                isCorrect: isCorrect,
                reverse: reverse,
                examplesJson: examplesJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int testResultId,
                required int questionWordId,
                Value<int?> myAnswerWordId = const Value.absent(),
                required bool isCorrect,
                required bool reverse,
                required String examplesJson,
              }) => TestQuestionsCompanion.insert(
                id: id,
                testResultId: testResultId,
                questionWordId: questionWordId,
                myAnswerWordId: myAnswerWordId,
                isCorrect: isCorrect,
                reverse: reverse,
                examplesJson: examplesJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TestQuestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({testResultId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (testResultId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.testResultId,
                                referencedTable: $$TestQuestionsTableReferences
                                    ._testResultIdTable(db),
                                referencedColumn: $$TestQuestionsTableReferences
                                    ._testResultIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TestQuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TestQuestionsTable,
      TestQuestionData,
      $$TestQuestionsTableFilterComposer,
      $$TestQuestionsTableOrderingComposer,
      $$TestQuestionsTableAnnotationComposer,
      $$TestQuestionsTableCreateCompanionBuilder,
      $$TestQuestionsTableUpdateCompanionBuilder,
      (TestQuestionData, $$TestQuestionsTableReferences),
      TestQuestionData,
      PrefetchHooks Function({bool testResultId})
    >;
typedef $$AppMetaTableCreateCompanionBuilder =
    AppMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppMetaTableUpdateCompanionBuilder =
    AppMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) =>
                  AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;
typedef $$DailyStatsTableCreateCompanionBuilder =
    DailyStatsCompanion Function({
      Value<int> date,
      Value<int> studySeconds,
      Value<int> wordsLearned,
      Value<int> grammarsLearned,
      Value<int> testsTaken,
      Value<int> correctAnswers,
      Value<int> totalAnswers,
    });
typedef $$DailyStatsTableUpdateCompanionBuilder =
    DailyStatsCompanion Function({
      Value<int> date,
      Value<int> studySeconds,
      Value<int> wordsLearned,
      Value<int> grammarsLearned,
      Value<int> testsTaken,
      Value<int> correctAnswers,
      Value<int> totalAnswers,
    });

class $$DailyStatsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordsLearned => $composableBuilder(
    column: $table.wordsLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grammarsLearned => $composableBuilder(
    column: $table.grammarsLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get testsTaken => $composableBuilder(
    column: $table.testsTaken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAnswers => $composableBuilder(
    column: $table.totalAnswers,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordsLearned => $composableBuilder(
    column: $table.wordsLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grammarsLearned => $composableBuilder(
    column: $table.grammarsLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get testsTaken => $composableBuilder(
    column: $table.testsTaken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAnswers => $composableBuilder(
    column: $table.totalAnswers,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wordsLearned => $composableBuilder(
    column: $table.wordsLearned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get grammarsLearned => $composableBuilder(
    column: $table.grammarsLearned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get testsTaken => $composableBuilder(
    column: $table.testsTaken,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAnswers => $composableBuilder(
    column: $table.totalAnswers,
    builder: (column) => column,
  );
}

class $$DailyStatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyStatsTable,
          DailyStatData,
          $$DailyStatsTableFilterComposer,
          $$DailyStatsTableOrderingComposer,
          $$DailyStatsTableAnnotationComposer,
          $$DailyStatsTableCreateCompanionBuilder,
          $$DailyStatsTableUpdateCompanionBuilder,
          (
            DailyStatData,
            BaseReferences<_$AppDatabase, $DailyStatsTable, DailyStatData>,
          ),
          DailyStatData,
          PrefetchHooks Function()
        > {
  $$DailyStatsTableTableManager(_$AppDatabase db, $DailyStatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> date = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                Value<int> wordsLearned = const Value.absent(),
                Value<int> grammarsLearned = const Value.absent(),
                Value<int> testsTaken = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> totalAnswers = const Value.absent(),
              }) => DailyStatsCompanion(
                date: date,
                studySeconds: studySeconds,
                wordsLearned: wordsLearned,
                grammarsLearned: grammarsLearned,
                testsTaken: testsTaken,
                correctAnswers: correctAnswers,
                totalAnswers: totalAnswers,
              ),
          createCompanionCallback:
              ({
                Value<int> date = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                Value<int> wordsLearned = const Value.absent(),
                Value<int> grammarsLearned = const Value.absent(),
                Value<int> testsTaken = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> totalAnswers = const Value.absent(),
              }) => DailyStatsCompanion.insert(
                date: date,
                studySeconds: studySeconds,
                wordsLearned: wordsLearned,
                grammarsLearned: grammarsLearned,
                testsTaken: testsTaken,
                correctAnswers: correctAnswers,
                totalAnswers: totalAnswers,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyStatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyStatsTable,
      DailyStatData,
      $$DailyStatsTableFilterComposer,
      $$DailyStatsTableOrderingComposer,
      $$DailyStatsTableAnnotationComposer,
      $$DailyStatsTableCreateCompanionBuilder,
      $$DailyStatsTableUpdateCompanionBuilder,
      (
        DailyStatData,
        BaseReferences<_$AppDatabase, $DailyStatsTable, DailyStatData>,
      ),
      DailyStatData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db, _db.words);
  $$ChineseCharsTableTableManager get chineseChars =>
      $$ChineseCharsTableTableManager(_db, _db.chineseChars);
  $$TestResultsTableTableManager get testResults =>
      $$TestResultsTableTableManager(_db, _db.testResults);
  $$TestQuestionsTableTableManager get testQuestions =>
      $$TestQuestionsTableTableManager(_db, _db.testQuestions);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$DailyStatsTableTableManager get dailyStats =>
      $$DailyStatsTableTableManager(_db, _db.dailyStats);
}
