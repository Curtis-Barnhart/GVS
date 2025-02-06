class_name IOQueue
extends RefCounted

var data: PackedStringArray = []


func is_empty() -> bool:
    if self.data.is_empty():
        return true
    return false


func find(str: String) -> int:
    var index: int = 0
    
    for message in self.data:
        var contain: int = message.find(str)
        if contain == -1:
            index += len(message)
            continue
        else:
            return index + contain
    
    return -1


func write(str: String) -> void:
    self.data.push_back(str)


func read_until(str: String) -> String:
    var found: int = self.find(str)
    if found == -1:
        return ""
    return self.unchecked_read(found + len(str))
    

func read(ct: int = 1) -> String:
    assert(ct > 0)
    
    if self.size() < ct:
        return ""
    
    var str_buf: PackedStringArray = []
    return self.unchecked_read(ct)


func size() -> int:
    var acc: int = 0
    for str in self.data:
        acc += len(str)
    return acc


func unchecked_read(ct: int = 1) -> String:
    assert(ct > 0)
    var str_buf: PackedStringArray = []
    while ct > 0:
        if self.is_empty():
            break
        
        if len(self.data[0]) > ct:
            str_buf.push_back(self.data[0].substr(0, ct))
            self.data[0] = self.data[0].substr(ct)
        else:
            str_buf.push_back(self.data[0])
            self.data.remove_at(0)
    
    return "".join(str_buf)
