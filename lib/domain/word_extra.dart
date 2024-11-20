
import 'package:jlpt_app/domain/word.dart';

class WordExtra extends Word {

  bool isRead;

  WordExtra.fromJson(super.json) :
    isRead = json['isRead'] ?? false,
    super.fromJson();

}