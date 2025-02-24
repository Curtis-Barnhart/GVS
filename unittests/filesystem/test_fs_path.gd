extends GutTest

const Path = GVSClassLoader.gvm.filesystem.Path


func test_degen():
    assert_true(Path.new([]).degen(),
        "Path.degen did not return true on empty path."
    )
    
    assert_false(Path.new(["hello"]).degen(),
        "Path.degen returned true on a path of length 1."
    )
    
    assert_false(Path.new(["hello", "there", "world"]).degen(),
        "Path.degen returned true on a path of length 3."
    )


func test_head():
    assert_eq(Path.new(["hello", "world"]).head(), "hello",
        "Path.head did not return the first element of the path of length 2."
    )

    assert_eq(Path.new(["hello"]).head(), "hello",
        "Path.head did not return the first element of the path of length 1."
    )
    
    assert_eq(Path.new([]).head(), "",
        "Path.head did not return an empty string when the path was degenerate."
    )


func test_tail():
    assert_eq(Path.new(["hello", "there", "world"]).tail().as_string(), "/there/world",
        "Path.tail did not return the last 2 elements of a path of length 3."
    )
    
    assert_true(Path.new([]).tail().degen(),
        "Path.tail did not return a degenerate path when the path was degenerate."
    )
    
    assert_true(Path.new(["hello"]).tail().degen(),
        "Path.tail did not return a degenerate path on a path of length 1."
    )


func test_base():
    assert_eq(Path.new(["hello", "there", "world"]).base().as_string(), "/hello/there",
        "Path.base did not return the first 2 elements of a path of length 3."
    )
    
    assert_true(Path.new([]).tail().degen(),
        "Path.tail did not return a degenerate path when the path was degenerate."
    )
    
    assert_true(Path.new(["hello"]).tail().degen(),
        "Path.tail did not return a degenerate path on a path of length 1."
    )


func test_last():
    assert_eq(Path.new(["hello", "there", "world"]).last(), "world",
        "Path.last did not return the last elements of the path of length 3."
    )
    
    assert_eq(Path.new([]).last(), "",
        "Path.last did not return a degenerate string when the path was degenerate."
    )
    
    assert_eq(Path.new(["hello"]).last(), "hello",
        "Path.tail did not return the last element on a path of length 1."
    )


func test_compose():
    assert_eq(Path.ROOT.compose(Path.ROOT).as_string(), "/",
        "Two empty paths composed did not result in an empty path."
    )
    
    assert_eq(Path.ROOT.compose(Path.new(["hello", "world"])).as_string(), "/hello/world",
        "An empty path did not compose correctly with a path of size 2."
    )
    assert_eq(Path.new(["hello", "world"]).compose(Path.ROOT).as_string(), "/hello/world",
        "A path of size 2 did not compose correctly with an empty path."
    )
    
    assert_eq(Path.new(["one", "two"]).compose(Path.new(["three", "four"])).as_string(), "/one/two/three/four",
        "A path of size 2 did not compose correctly with a path of size 2."
    )


func test_extend():
    assert_eq(Path.ROOT.extend("").as_string(), "/",
        "An empty path extended by nothing did not result in an empty path."
    )
    
    assert_eq(Path.ROOT.extend("hello").as_string(), "/hello",
        "An empty path was not extended correctly by a nondegenerate string."
    )
    assert_eq(Path.new(["hello", "world"]).extend("").as_string(), "/hello/world",
        "A path of size 2 was not extended correctly by degenerate string"
    )
    
    assert_eq(Path.new(["one", "two"]).extend("three").as_string(), "/one/two/three",
        "A path of size 2 was not extended correctly by a nondegenerate string."
    )


func test_as_string():
    assert_eq(Path.ROOT.as_string(), "/")
    assert_eq(Path.ROOT.as_string(false), "")
    assert_eq(Path.new(["hello"]).as_string(), "/hello")
    assert_eq(Path.new(["hello"]).as_string(false), "hello")
    assert_eq(Path.new(["hello", "there", "world"]).as_string(), "/hello/there/world")
    assert_eq(Path.new(["hello", "there", "world"]).as_string(false), "hello/there/world")


func test_as_cwd():
    assert_eq(Path.ROOT.as_cwd("hello/world").as_string(), "/hello/world",
        "Path.as_cwd failed on relative path from root directory."
    )
    assert_eq(Path.ROOT.as_cwd("/hello/world").as_string(), "/hello/world",
        "Path.as_cwd failed on absolute path from root directory."
    )
    assert_eq(Path.ROOT.as_cwd("").as_string(), "/",
        "Path.as_cwd failed on degenerate path from root directory."
    )
    assert_eq(Path.ROOT.as_cwd("/").as_string(), "/",
        "Path.as_cwd failed on absolute degenerate path from root directory."
    )
    assert_eq(Path.ROOT.as_cwd("////hello////world///").as_string(), "/hello/world",
        "Path.as_cwd failed on absolute path with many slashes from root directory."
    )
    assert_eq(Path.ROOT.as_cwd("hello////world///").as_string(), "/hello/world",
        "Path.as_cwd failed on absolute path with many slashes from root directory."
    )
    assert_eq(Path.ROOT.as_cwd("///////").as_string(), "/",
        "Path.as_cwd failed on absolute degenerate path with many slashes from root directory."
    )

    assert_eq(Path.new(["one", "two"]).as_cwd("hello/world").as_string(), "/one/two/hello/world",
        "Path.as_cwd failed on relative path from '/one/two'."
    )
    assert_eq(Path.new(["one", "two"]).as_cwd("/hello/world").as_string(), "/hello/world",
        "Path.as_cwd failed on absolute path from '/one/two'."
    )
    assert_eq(Path.new(["one", "two"]).as_cwd("").as_string(), "/one/two",
        "Path.as_cwd failed on degenerate path from '/one/two'."
    )
    assert_eq(Path.new(["one", "two"]).as_cwd("/").as_string(), "/",
        "Path.as_cwd failed on absolute degenerate path from '/one/two'."
    )
    assert_eq(Path.new(["one", "two"]).as_cwd("////hello////world///").as_string(), "/hello/world",
        "Path.as_cwd failed on absolute path with many slashes from '/one/two'."
    )
    assert_eq(Path.new(["one", "two"]).as_cwd("hello////world///").as_string(), "/one/two/hello/world",
        "Path.as_cwd failed on absolute path with many slashes from '/one/two'."
    )
    assert_eq(Path.new(["one", "two"]).as_cwd("///////").as_string(), "/",
        "Path.as_cwd failed on absolute degenerate path with many slashes from '/one/two'."
    )
