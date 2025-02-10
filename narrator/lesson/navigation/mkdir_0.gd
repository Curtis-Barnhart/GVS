extends Checkpoint


func start() -> void:
    self.text_screen.text = Checkpoint.make_article([
        "Making Your First Directory - 0",
        [
            ""
        ],
    ])
    self.text_screen.scroll_to_line(0)
    self.next_button.pressed.connect(self.finished)
    self.next_button.disabled = false


func finished() -> void:
    self.completed.emit(
        load("res://narrator/lesson/navigation/introduction_1.gd").new(
            self.fs_man, self.text_screen, self.shell, self.next_button
        )
    )
