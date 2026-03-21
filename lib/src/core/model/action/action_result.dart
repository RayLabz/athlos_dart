import 'package:athlos/athlos.dart';
import 'package:athlos/src/core/model/logging/world_event_log_entry.dart';

/// Represents the result of applying an action to a state.
class ActionResult<StateType extends GameState, EventType extends WorldEventLogEntry> {

  /// The new state after applying the action.
  final GameState state;

  /// A list of events that occurred during the action.
  final List<EventType> events;

  const ActionResult({
    required this.state,
    this.events = const [],
  });

}