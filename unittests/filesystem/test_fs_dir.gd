extends GutTest

const Dir = GVSClassLoader.gvm.filesystem.Directory
const File = GVSClassLoader.gvm.filesystem.File

var root := Dir.new("", null)
var map: Dictionary = Dictionary()


#                     root
#        .-------------^------.
#       two                 three
#        ^        .-----.-----^----.
#      file0    file1 file2       four
#                             .----.^------.
#                           file3 file4 file5
func before_all() -> void:
    var root := self.root
    root.parent = root
    self.map["root"] = root
    var sd0 := Dir.new("two", root)
    root.subdirs.append(sd0)
    self.map["two"] = sd0
    var sd1 := Dir.new("three", root)
    root.subdirs.append(sd1)
    self.map["three"] = sd1
    var sd2 := Dir.new("four", sd1)
    sd1.subdirs.append(sd2)
    self.map["four"] = sd2
    var f0 := File.new("file0", sd0)
    sd0.files.append(f0)
    self.map["file0"] = f0
    var f1 := File.new("file1", sd1)
    sd1.files.append(f1)
    self.map["file1"] = f1
    var f2 := File.new("file2", sd1)
    sd1.files.append(f2)
    self.map["file2"] = f2
    var f3 := File.new("file3", sd2)
    sd2.files.append(f3)
    self.map["file3"] = f3
    var f4 := File.new("file4", sd2)
    sd2.files.append(f4)
    self.map["file4"] = f4
    var f5 := File.new("file5", sd2)
    sd2.files.append(f5)
    self.map["file5"] = f5


# remove the cyclic reference before freeing
func after_all() -> void:
    self.root.parent = null


func test_get_path() -> void:
    assert_eq((self.map["root"] as Dir).get_path().as_string(), "/")
    assert_eq((self.map["two"] as Dir).get_path().as_string(), "/two")
    assert_eq((self.map["three"] as Dir).get_path().as_string(), "/three")
    assert_eq((self.map["four"] as Dir).get_path().as_string(), "/three/four")
    assert_eq((self.map["file0"] as File).get_path().as_string(), "/two/file0")
    assert_eq((self.map["file1"] as File).get_path().as_string(), "/three/file1")
    assert_eq((self.map["file2"] as File).get_path().as_string(), "/three/file2")
    assert_eq((self.map["file3"] as File).get_path().as_string(), "/three/four/file3")
    assert_eq((self.map["file4"] as File).get_path().as_string(), "/three/four/file4")
    assert_eq((self.map["file5"] as File).get_path().as_string(), "/three/four/file5")


func test_local_dir() -> void:
    # Tests on root node
    assert_eq(
        (self.map["root"] as Dir).local_dir("two"),
        self.map["two"]
    )
    assert_eq(
        (self.map["root"] as Dir).local_dir("three"),
        self.map["three"]
    )
    assert_eq(
        (self.map["root"] as Dir).local_dir("four"),
        null
    )
    assert_eq(
        (self.map["root"] as Dir).local_dir("three/four"),
        null
    )
    assert_eq(
        (self.map["root"] as Dir).local_dir("/"),
        null
    )
    assert_eq(
        (self.map["root"] as Dir).local_dir("."),
        self.map["root"]
    )
    assert_eq(
        (self.map["root"] as Dir).local_dir(".."),
        self.map["root"]
    )

    # Tests for /three
    assert_eq(
        (self.map["three"] as Dir).local_dir("two"),
        null
    )
    assert_eq(
        (self.map["three"] as Dir).local_dir("/"),
        null
    )
    assert_eq(
        (self.map["three"] as Dir).local_dir("three"),
        null
    )
    assert_eq(
        (self.map["three"] as Dir).local_dir("four"),
        self.map["four"]
    )
    assert_eq(
        (self.map["three"] as Dir).local_dir("../three"),
        null
    )
    assert_eq(
        (self.map["three"] as Dir).local_dir("file1"),
        null
    )
    assert_eq(
        (self.map["three"] as Dir).local_dir("file2"),
        null
    )
    assert_eq(
        (self.map["three"] as Dir).local_dir("."),
        self.map["three"]
    )
    assert_eq(
        (self.map["three"] as Dir).local_dir(".."),
        self.map["three"]
    )
