
abstract class Speaker {

  Future<void> init({Function()? completionHandler});
  Future<void> speak(String word);
  Future<void> stopped();
}