extends "res://visualfs/narrator/lesson/checkpoint.gd"

const UtilString = GVSClassLoader.shared.Strings


func start(_needs_context: bool) -> void:
    self._text_display.text = UtilString.make_article(
        [
            "That's it.",
            [
                "Nothing more.",
            ]
        ]
    )
