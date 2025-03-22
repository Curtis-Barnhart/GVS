extends GutTest

const TimeColorStack = GVSClassLoader.visual.file_nodes.TimeColorStack

var _tcs: TimeColorStack


func before_each() -> void:
    self._tcs = TimeColorStack.new(Color.RED)    


func test_default_color() -> void:
    assert_eq(self._tcs.get_current_color(), Color.RED)


func test_push_pop() -> void:
    assert_eq(self._tcs.get_current_color(), Color.RED)

    var id0: int = self._tcs.push_solid_color(Color.BLUE)
    assert_eq(self._tcs.get_current_color(), Color.BLUE)
    
    var id1: int = self._tcs.push_solid_color(Color.VIOLET)
    assert_eq(self._tcs.get_current_color(), Color.VIOLET)
    
    var id2: int = self._tcs.push_solid_color(Color.VIOLET)
    assert_eq(self._tcs.get_current_color(), Color.VIOLET)

    self._tcs.pop_id(id2)
    assert_eq(self._tcs.get_current_color(), Color.VIOLET)

    self._tcs.pop_id(id1)
    assert_eq(self._tcs.get_current_color(), Color.BLUE)

    self._tcs.pop_id(id0)
    assert_eq(self._tcs.get_current_color(), Color.RED)


func test_flash() -> void:
    # red
    assert_eq(self._tcs.get_current_color(), Color.RED)

    # red, blue
    self._tcs.push_flash_color(Color.BLUE, 4)
    var temp_color: Color = self._tcs.get_current_color()
    temp_color.a = 1
    assert_eq(temp_color, Color.BLUE)
    
    # red, blue, green
    self._tcs.push_flash_color(Color.GREEN, 2)
    temp_color = self._tcs.get_current_color()
    temp_color.a = 1
    assert_eq(temp_color, Color.GREEN)
    
    await GVSGlobals.wait(3)
    # red, blue
    temp_color = self._tcs.get_current_color()
    temp_color.a = 1
    assert_eq(temp_color, Color.BLUE)    
    
    # red, blue, green
    self._tcs.push_flash_color(Color.GREEN, 4)
    temp_color = self._tcs.get_current_color()
    temp_color.a = 1
    assert_eq(temp_color, Color.GREEN)
    
    await GVSGlobals.wait(1.5)
    # red, green
    temp_color = self._tcs.get_current_color()
    temp_color.a = 1
    assert_eq(temp_color, Color.GREEN)    
    await GVSGlobals.wait(1.5)
    # red, green
    temp_color = self._tcs.get_current_color()
    temp_color.a = 1
    assert_eq(temp_color, Color.GREEN)
    await GVSGlobals.wait(2)
    # red
    temp_color = self._tcs.get_current_color()
    temp_color.a = 1
    assert_eq(temp_color, Color.RED)
