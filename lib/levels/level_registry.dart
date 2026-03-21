import '../models/level_data.dart';
import 'level_one.dart';
import 'level_two.dart';
import 'level_three.dart';
import 'level_four.dart';
import 'level_five.dart';

class LevelInfo {
  final String name;
  final LevelData Function() builder;

  const LevelInfo({required this.name, required this.builder});
}

const levelCount = 5;

final List<LevelInfo> levels = [
  LevelInfo(name: 'Cave Escape', builder: buildLevelOne),
  LevelInfo(name: 'The Deep Descent', builder: buildLevelTwo),
  LevelInfo(name: 'Crystal Caverns', builder: buildLevelThree),
  LevelInfo(name: 'The Gauntlet', builder: buildLevelFour),
  LevelInfo(name: 'The Final Chamber', builder: buildLevelFive),
];
