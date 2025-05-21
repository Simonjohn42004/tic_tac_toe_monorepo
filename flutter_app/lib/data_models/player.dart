enum Player { x, o, none }

extension PlayerSymbol on Player {
  String get symbol {
    switch (this) {
      case Player.x:
        return "X";
      case Player.o:
        return "O";
      case Player.none:
        return "";
    }
  }
}
