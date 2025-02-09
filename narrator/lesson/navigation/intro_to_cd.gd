extends Checkpoint

const text: PackedStringArray = [
    """[center]Navigation Basics[/center]
    hello"""
]


func check_completion() -> bool:
    return false


func get_text() -> String:
    return self.text[0]
