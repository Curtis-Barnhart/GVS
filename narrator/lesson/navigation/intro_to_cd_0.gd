extends Checkpoint


func start() -> void:
    self.text_screen.text = """[font=res://shared/JetBrainsMonoNerdFontMono-Regular.ttf][font_size=36][center]Navigation Basics 0[/center]
To interact with the terminal, you use a tool called a shell, which is currently displayed on the left half of the screen.
[/font_size][/font]"""
    self.shell.cwd_changed.connect(self._on_cwd_changed)


func _on_cwd_changed(_origin: FSPath, _path: FSPath) -> void:
    self.text_screen.text = """[font=res://shared/JetBrainsMonoNerdFontMono-Regular.ttf][font_size=36][center]Navigation Basics 0[/center]
Good job changing the current working directory!
You can now press the continue button.
[/font_size][/font]"""
    if self.next_button.disabled:
        self.next_button.disabled = false
        self.next_button.pressed.connect(self.finished)


func finished() -> void:
    self.completed.emit(
        load("res://narrator/lesson/navigation/intro_to_cd_1.gd").new(
            self.fs_man, self.text_screen, self.shell, self.next_button
        )
    )
