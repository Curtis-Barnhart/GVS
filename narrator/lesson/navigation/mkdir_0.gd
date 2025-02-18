extends "res://narrator/lesson/checkpoint.gd"

## Contained in parent class
const Path = GVSClassLoader.gvm.filesystem.Path


func start() -> void:
    self.text_screen.text = Checkpoint.make_article([
        "Making Your First Directory - 0",
        [
            "But enough talking - let's put all this theory into action!",
        ],
        [
            "You'll notice the [color=steel blue]Continue[/color] button",
            "is greyed out right now.",
            "Many parts of this tutorial require some action from you,",
            "so that you can practice the concepts you'll learn about.",
            "To continue with the tutorial, you have to create a new directory",
            "named 'new_directory'.",
        ],
        [
            "Notice the strip of darker grey on the bottom",
            "of the left side of the screen?",
            "Click on it to select it.",
            "That is the [color=dark blue]shell prompt[/color] -",
            "the place you can give commands via text to the computer.",
        ],
        [
            "Now that you've selected the shell prompt,",
            "you're ready to enter your first command.",
            "It's time to introduce the program [color=firebrick]mkdir[/color],",
            "which is a program that creates a new directory",
            "([color=firebrick]mkdir[/color] is short for 'make directory').",
            "Type in the command `[color=firebrick]mkdir new_directory[/color]`",
            "and hit the enter key on your keyboard.",
            "Once the new directory is completed,",
            "you'll be able to continue the tutorial.",
        ]
    ])
    self.text_screen.scroll_to_line(0)
    self.fs_man.created_dir.connect(self._on_directory_made)
    self.next_button.pressed.connect(self.finished)
    self.next_button.disabled = true


func _on_directory_made(path: Path):
    if path.as_string() == "/new_directory":
        self.next_button.disabled = false


func finished() -> void:
    self.completed.emit(
        load("res://narrator/lesson/navigation/mkdir_1.gd").new(
            self.fs_man, self.text_screen, self.shell, self.next_button
        )
    )
