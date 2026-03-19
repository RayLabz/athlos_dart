import '../../../athlos.dart';
import '../model/action/action_result.dart';
import '../model/event/event_record.dart';

/// Represents a reducer that transforms a state based on an action.
abstract class StateReducer<StateType extends GameState, ActionType extends Action, EventType extends EventRecord> {

  /// Reduces the given state based on the given action and state.
  /// Returns a new state and a list of events.
  /// This function should go through each available action, validate it, and then execute it.
  ActionResult<StateType, EventType> reduce(GameState state, ActionType action);

}