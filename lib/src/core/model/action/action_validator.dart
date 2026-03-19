import 'package:athlos/athlos.dart';

abstract class ActionValidator<StateType extends GameState, ActionType extends Action> {

  /// Validates the given action against the given state.
  bool validate(StateType state, ActionType action);

}