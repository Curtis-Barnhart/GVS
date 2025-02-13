extends "res://narrator/lesson/checkpoint.gd"


func start() -> void:
    self.text_screen.text = Checkpoint.make_article([
        "Making Your First Directory - 1",
        [
            "Some interesting stuff happened on screen just a moment ago -",
            "let's spend some time breaking it down.",
        ],
        [
            "First, the command you wrote showed up at the top of the shell prompt,",
            "and a new line underneath it was printed out.",
            "Everything command you entered will be displayed in the history",
            "of the shell, as well as the output that any programs might print."
        ],
        [
            "Second, a new directory appeared in the window above.",
            "That window gives a visual representation of what your file system",
            "looks like at any given time.",
            "The new directory appeared, labelled with its name, and now lives",
            "inside the directory at the top.",
            "Since it lives inside the directory above it, we call it the",
            "[color=dark blue]child[/color] directory and the one on top the",
            "[color=dark blue]parent[/color] directory.",
            "We represent this relationship between the two folders by drawing",
            "a blue line from the child to its parent."
        ],
        [
            "You'll notice that the two directories are different colors.",
            "This has to with something we call the",
            "[color=dark blue]current working directory[/color],",
            "which has to do with our sense of location within the file system",
            "and which we will discuss in the next chapter."
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
