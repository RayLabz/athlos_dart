// lib/athlos.dart

library athlos;

// Controllers
export "src/core/controller/matchmaker.dart";
export "src/core/controller/state_reducer.dart";

// Models: Achievements
export "src/core/model/achievement/achievement_descriptor.dart";
export "src/core/model/achievement/player_achievement.dart";

// Models: Actions
export "src/core/model/action/action.dart";
export "src/core/model/action/action_result.dart";
export "src/core/model/action/action_validator.dart";
export "src/core/model/action/scheduled_event.dart";

// Models: Directions
export "src/core/model/direction/angle3d.dart";
export "src/core/model/direction/grid_direction.dart";
export "src/core/model/direction/hex_direction.dart";

// Models: Entities
export "src/core/model/entity/entity.dart";
export "src/core/model/entity/entity_type.dart";

// Models: Game
export "src/core/model/game_descriptor.dart";

// Models: Leaderboards
export "src/core/model/leaderboard/leaderboard.dart";
export "src/core/model/leaderboard/leaderboard_order.dart";
export "src/core/model/leaderboard/leaderboard_player_scope.dart";
export "src/core/model/leaderboard/leaderboard_world_scope.dart";
export "src/core/model/leaderboard/season.dart";

// Models: Lobbies
export "src/core/model/lobby/lobby.dart";
export "src/core/model/lobby/lobby_message.dart";
export "src/core/model/lobby/lobby_status.dart";

// Models: Logging
export "src/core/model/logging/analytics_event_entry.dart";
export "src/core/model/logging/log_entry.dart";
export "src/core/model/logging/runtime_error_entry.dart";
export "src/core/model/logging/world_event_log_entry.dart";

// Models: Monetization
export "src/core/model/monetization/purchasable_item.dart";
export "src/core/model/monetization/purchasable_item_transaction.dart";
export "src/core/model/monetization/purchase_cart.dart";
export "src/core/model/monetization/purchase_offer.dart";

// Models: Notifications
export "src/core/model/notification/friend_invite_notification.dart";
export "src/core/model/notification/lobby_invite_notification.dart";
export "src/core/model/notification/notification.dart";
export "src/core/model/notification/offer_notification.dart";

// Models: Players
export "src/core/model/player/player.dart";
export "src/core/model/player/player_preferences.dart";
export "src/core/model/player/player_stats.dart";
export "src/core/model/player/player_type.dart";
export "src/core/model/player/presence_status.dart";

// Models: Positions
export "src/core/model/position/grid_position.dart";
export "src/core/model/position/hex_position.dart";
export "src/core/model/position/vector_position_2d.dart";
export "src/core/model/position/vector_position_3d.dart";
export "src/core/model/position/world_position.dart";

// Models: Resources
export "src/core/model/resource/resource.dart";

// Models: Sessions
export "src/core/model/session/game_session.dart";
export "src/core/model/session/world_session.dart";

// Models: Social
export "src/core/model/social/direct_message.dart";
export "src/core/model/social/message.dart";

// Models: State
export "src/core/model/state/game_state.dart";
export "src/core/model/state/state_update.dart";

// Models: Teams
export "src/core/model/team.dart";

// Models: Transforms
export "src/core/model/transform/generic_transform.dart";
export "src/core/model/transform/grid_transform.dart";
export "src/core/model/transform/hex_transform.dart";
export "src/core/model/transform/vector_transform_2d.dart";
export "src/core/model/transform/vector_transform_3d.dart";

// Models: Worlds
export "src/core/model/world/game_world.dart";
export "src/core/model/world/spatial_partition.dart";
export "src/core/model/world/spatial_unit.dart";
export "src/core/model/world/world_config.dart";
export "src/core/model/world/world_status.dart";

// Networking: Control
export "src/core/net/network_logger.dart";
export "src/core/net/udp_control_message.dart";

// Gateway: Protocol
export "src/gateway/protocol/gateway_opcode.dart";
export "src/gateway/protocol/gateway_packet.dart";

// Gateway: Models
export "src/gateway/model/backend_node.dart";
export "src/gateway/model/gateway_route_info.dart";
export "src/gateway/model/gateway_session.dart";
export "src/gateway/model/gateway_transport.dart";

// Gateway: Services
export "src/gateway/service/backend_node_store.dart";
export "src/gateway/service/ddos_guard.dart";
export "src/gateway/service/gateway_authenticator.dart";
export "src/gateway/service/gateway_matchmaker.dart";
export "src/gateway/service/load_balancer.dart";
export "src/gateway/service/session_router.dart";

// Gateway: Runtime
export "src/gateway/gateway_relay.dart";
export "src/gateway/gateway_tcp_server.dart";
export "src/gateway/gateway_udp_server.dart";

// Networking: Server
export "src/server/tcp_client_info.dart";
export "src/server/tcp_server.dart";
export "src/server/tcp_server_message_handler.dart";
export "src/server/udp_client_info.dart";
export "src/server/udp_server.dart";
export "src/server/udp_server_message_handler.dart";

// Networking: Client
export "src/client/tcp_client.dart";
export "src/client/tcp_client_message_handler.dart";
export "src/client/udp_client.dart";
export "src/client/udp_client_message_handler.dart";
