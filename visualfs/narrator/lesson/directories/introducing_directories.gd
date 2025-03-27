extends "res://visualfs/narrator/lesson/checkpoint.gd"

# TODO: this could probably be broken up into a few steps

const Path = GVSClassLoader.gvm.filesystem.Path
const UtilString = GVSClassLoader.shared.scripts.Strings
const FileList = GVSClassLoader.visualfs.FileList
const FileTree = GVSClassLoader.visual.FileTree
const TNode = GVSClassLoader.visual.file_nodes.TreeNode

var _file_tree: FileTree


func context_build() -> void:
    var fl := FileList.make_new()
    fl.name = "FileList"
    self._viewport.add_to_scene(fl)
    self._inst.visible = false


func remove_old_files() -> void:
    var old_files: Array = self._fs_man.read_files_in_dir(Path.ROOT)
    old_files.reverse()
    
    var t: float = 0.25
    for old_file: Path in old_files:
        self._fs_man.remove_file(old_file)
        await GVSGlobals.wait(t)
        t = max(0.95 * t, 1.0/16)


func start(needs_context: bool) -> void:
    if needs_context:
        self.context_build()
        
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "We're going to cover "
            ],
        ]
    )
        
    await self.remove_old_files()
    self._viewport.node_from_scene("FileList").queue_free()
    await GVSGlobals.wait(0.5)
    
    # TODO: If I could check the resolution of the screen and then add it
    # just out of reach that'd be great.
    self._viewport.move_cam_to(Vector2(0, 1000))
    self._next_button.pressed.connect(self.add_filetree)


func add_filetree() -> void:
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "and now there's a directory"
            ],
        ]
    )

    # Create file tree object in drag viewport connected to the fs_manager
    self._file_tree = FileTree.make_new()
    self._file_tree.name = "FileTree"
    self._viewport.add_to_scene(self._file_tree)
    self._fs_man.created_dir.connect(self._file_tree.create_node_dir)
    self._fs_man.created_file.connect(self._file_tree.create_node_file)
    self._fs_man.removed_dir.connect(self._file_tree.remove_node)
    self._fs_man.removed_file.connect(self._file_tree.remove_node)
    self._next_button.disabled = false
    
    self._viewport.move_cam_to(Vector2.ZERO)
    
    self._next_button.pressed.disconnect(self.add_filetree)
    self._next_button.pressed.connect(self.add_subdirectories)


func add_subdirectories() -> void:
    self._next_button.pressed.disconnect(self.add_subdirectories)
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "holy crap there's more of them"
            ],
        ]
    )
    
    self._fs_man.create_dir(Path.new(["school"]))
    self._fs_man.create_dir(Path.new(["work"]))
    await GVSGlobals.wait(0.5)
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT / 2.0))
    
    self._next_button.pressed.connect(self.add_files)


func add_files() -> void:
    self._next_button.pressed.disconnect(self.add_files)
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "and now there's files what"
            ],
        ]
    )
    
    self._fs_man.create_file(Path.new(["school", "document"]))
    self._fs_man.create_file(Path.new(["school", "email"]))
    self._fs_man.create_file(Path.new(["work", "email"]))
    self._fs_man.create_file(Path.new(["work", "email_2"]))
    await GVSGlobals.wait(0.5)
    self._viewport.move_cam_to(Vector2(0, TNode.HEIGHT))

    self._next_button.pressed.connect(self.click_on_directory)


var click_on_directory_highlight_id: int
func click_on_directory() -> void:
    self._next_button.disabled = true
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "you gotta click on the directory"
            ],
        ]
    )
    
    self._inst.visible = true
    self._inst.remove_all()
    self._inst.add_command(Instructions.Command.new(
        "Click on the 'school' directory contained in the '/' directory"
    ))
    self._inst.render()

    self._next_button.pressed.disconnect(self.click_on_directory)
    self._next_button.pressed.connect(self.click_on_file)
    
    self._file_tree.file_clicked.connect(self.click_on_directory_user_click)


func click_on_directory_user_click(p: Path) -> void:
    var school := Path.new(["school"])
    
    if p.as_string() == school.as_string():
        self._text_display.text += UtilString.make_paragraphs([["whoah you clicked the directory!"]])
        self._file_tree.file_clicked.disconnect(self.click_on_directory_user_click)
        self.click_on_directory_highlight_id = self._file_tree.hl_server.push_color_to_tree_nodes(Color.GREEN, Path.ROOT, p)
        self._next_button.disabled = false
        
        self._inst.get_command(0).set_fulfill(true)
        self._inst.render()
    else:
        if p.common_with(school).as_string() == "/school":
            var remaining: Path = self._fs_man.relative_to(p, school)
            self._file_tree.hl_server.push_flash_to_tree_nodes(Color.GREEN, 3, Path.ROOT, school)
            self._file_tree.hl_server.push_flash_to_tree_nodes(Color.RED, 1, school, remaining)
        else:
            self._file_tree.hl_server.push_flash_to_tree_nodes(Color.RED, 1, Path.ROOT, p)


func click_on_file() -> void:
    self._next_button.disabled = true
    self._text_display.text = UtilString.make_article(
        [
            "Finding Files... the Smart Way",
            [
                "now you gotta click on the file"
            ],
        ]
    )
    
    self._inst.add_command(Instructions.Command.new(
        "Click on the 'email' file in the 'school' directory"
    ))
    self._inst.render()

    self._next_button.pressed.disconnect(self.click_on_file)
    
    self._file_tree.file_clicked.connect(self.click_on_file_user_click)


func click_on_file_user_click(p: Path) -> void:
    var school := Path.new(["school"])
    if p.as_string() == school.as_string():
        pass
    elif p.common_with(school).as_string() == school.as_string():
        var remaining: Path = self._fs_man.relative_to(p, school)
        if remaining.as_string() == "/email":
            self._file_tree.hl_server.pop_id(self.click_on_directory_highlight_id)
            self.click_on_directory_highlight_id = self._file_tree.hl_server.push_color_to_tree_nodes(Color.GREEN, Path.ROOT, p)
            self._next_button.disabled = false
            self._text_display.text += UtilString.make_paragraphs([["whoah you clicked the file!"]])

            self._file_tree.file_clicked.disconnect(self.click_on_file_user_click)
            self._next_button.pressed.connect(self.finish)
            
            self._inst.get_command(-1).set_fulfill(true)
            self._inst.render()
        else:
            self._file_tree.hl_server.push_flash_to_tree_nodes(Color.RED, 1, school, remaining)
    else:
        self._file_tree.hl_server.push_flash_to_tree_nodes(Color.RED, 1, Path.ROOT, p)


func finish() -> void:
    self._inst.remove_all()
    self._inst.render()
    
    self._file_tree.hl_server.pop_id(self.click_on_directory_highlight_id)
    self.completed.emit(
        preload("res://visualfs/narrator/lesson/directories/exploring_paths.gd").new()
    )
    assert(
        self.get_reference_count() == 1,
        "Not all references to directory_00 removed before checkpoint exit."
    )
