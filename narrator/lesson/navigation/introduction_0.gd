extends Checkpoint


func start() -> void:
    self.text_screen.text = Checkpoint.make_article([
        "Welcome!",
        [
            "Welcome to... your own computer?",
            "While it might be unfamiliar, the terminal is just as key a component",
            "to your computer as the screen, mouse, or keyboard.",
            "In olden days, the terminal was just about the [i]only[/i] way you had",
            "to interact with your computer - back before we had fancy input devices",
            "like wireless mice or tablets.",
        ],
        [
            "You might be wondering - why learn to use a tool so old if we've",
            "had decades to come up with much more sophisticated input devices?",
        ],
        [
            "While it's certainly old, the computer terminal exposes much of the",
            "raw functionality of the computer in relatively simple, structured terms",
            "that interacting with the computer using just the mouse alone can't replicate -",
            "truly an elegant tool for a more civilized age.",
            "For computer scientists, the power and versatility the terminal exposes",
            "is near indispensable.",
        ],
        [
            "This series of tutorials hopes to help demystify and acquaint you",
            "with this essential tool.",
            "To begin learning about some of its functionality,",
            "click the button labelled [color=steel blue]continue[/color] below."
        ],
    ])
    self.next_button.pressed.connect(self.finished)
    self.next_button.disabled = false


func finished() -> void:
    self.completed.emit(
        load("res://narrator/lesson/navigation/introduction_1.gd").new(
            self.fs_man, self.text_screen, self.shell, self.next_button
        )
    )
