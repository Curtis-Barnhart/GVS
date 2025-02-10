extends Checkpoint


func start() -> void:
    self.text_screen.text = Checkpoint.make_article([
        "Making Your First Directory - 2",
        [
            "Every moment you work in the shell,",
            "you are always located in a specific directory of your file system.",
            "This location that you are currently 'at' is called the",
            "[color=dark blue]current working directory[/color] or",
            "[color=dark blue]cwd[/color] for short.",
            "This is signified in the visual file system above by coloring",
            "the cwd [color=dark blue]dark blue[/color]."
        ],
        [
            "Let's explore an example of why knowing where we 'are' is important.",
            "Suppose we want to ask the computer 'what files are available here?'",
            "The computer has to know where 'here' [i]is[/i],",
            "and by default, 'here' is the cwd.",
            "If we ask the computer what files are available here while in the"
        ]
    ])
    self.text_screen.scroll_to_line(0)
    self.next_button.pressed.connect(self.finished)
    self.next_button.disabled = false


func finished() -> void:
    self.completed.emit(
        load("res://narrator/lesson/navigation/mkdir_2.gd").new(
            self.fs_man, self.text_screen, self.shell, self.next_button
        )
    )
