// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_sentence_dao.dart';

// ignore_for_file: type=lint
mixin _$ExampleSentenceDaoMixin on DatabaseAccessor<AppDatabase> {
  $ExampleSentencesTable get exampleSentences =>
      attachedDatabase.exampleSentences;
  $WordsTable get words => attachedDatabase.words;
  $WordExampleRefsTable get wordExampleRefs => attachedDatabase.wordExampleRefs;
  ExampleSentenceDaoManager get managers => ExampleSentenceDaoManager(this);
}

class ExampleSentenceDaoManager {
  final _$ExampleSentenceDaoMixin _db;
  ExampleSentenceDaoManager(this._db);
  $$ExampleSentencesTableTableManager get exampleSentences =>
      $$ExampleSentencesTableTableManager(
        _db.attachedDatabase,
        _db.exampleSentences,
      );
  $$WordsTableTableManager get words =>
      $$WordsTableTableManager(_db.attachedDatabase, _db.words);
  $$WordExampleRefsTableTableManager get wordExampleRefs =>
      $$WordExampleRefsTableTableManager(
        _db.attachedDatabase,
        _db.wordExampleRefs,
      );
}
