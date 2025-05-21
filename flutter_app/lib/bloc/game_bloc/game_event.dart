import 'package:equatable/equatable.dart';


abstract class GameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class OnBoxTappedEvent extends GameEvent {
  final int index;

  OnBoxTappedEvent({required this.index});
  @override
  List<Object?> get props => [index];
}

class GameResetEvent extends GameEvent {
  final bool fromRemote;
  GameResetEvent({this.fromRemote = false});
}

