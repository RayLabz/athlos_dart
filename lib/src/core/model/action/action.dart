import 'package:athlos/athlos.dart';

/// Represents an action that can be performed by an entity in the game.
abstract class Action {
  // The unique identifier for the action.
  String id;

  // The name of the action.
  String name;

  // A brief description of the action, which can be displayed in the UI or used for tooltips.
  String description;

  // Area of effect, in units. This determines how far the action can affect other entities or terrain.
  double aoe;

  Action({
    required this.id,
    required this.name,
    required this.description,
    required this.aoe,
  });

  /// Validates the action against the given state.
  /// Returns true if the action is valid, false otherwise.
  bool validate<StateType extends GameState>(StateType state);

  /// Executes the action on the given state.
  void execute<StateType extends GameState>(StateType state);

  /// Does something after the action is executed.
  void onActionExecuted<StateType extends GameState>(StateType state);

}
