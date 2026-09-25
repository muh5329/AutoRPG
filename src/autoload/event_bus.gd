extends Node
## Autoload "EventBus": global signals for decoupled cross-system notifications.
## Rule: only UI/presentation concerns go here; domain objects expose their own signals.

## Toast notification. kind: &"info", &"quest", &"reward", &"warning", &"level"
signal toast(text: String, kind: StringName)
signal interaction_target_changed(entity: WorldEntity)
signal dialogue_requested(dialogue: Dialogue)
signal shop_requested(vendor: Vendor)
