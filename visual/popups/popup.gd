extends Control

const SelfScene = preload("res://visual/popups/Popup.tscn")
const GVSPopup = GVSClassLoader.visual.popups.GVSPopup

signal click_outside
signal closing

var close_on_clickoff: bool = true


static func make_new() -> GVSPopup:
    return SelfScene.instantiate()


static func make_into_popup(
    node: CanvasItem,
    tree_access: Node,
    where: Vector2 = Vector2.ZERO
) -> GVSPopup:
    var p: GVSPopup = GVSPopup.make_new()
    p.add_to_scene(node)
    p.position = where
    p.popup(tree_access)
    return p


func add_to_scene(node: CanvasItem) -> void:
    self.add_child(node)


# This is what allows this control to intercept all points not already processed
func _has_point(_point: Vector2) -> bool:
    return true


func _gui_input(_event: InputEvent) -> void:
    if _event is InputEventMouseButton and self.close_on_clickoff:
        self.click_outside.emit()
        self.close_popup()


func popup(tree_access: Node) -> void:
    tree_access.get_tree().get_root().add_child(self)


func close_popup() -> void:
    self.closing.emit()
    self.queue_free()
