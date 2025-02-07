class_name IOQueue
extends RefCounted

var data: PackedStringArray = []


func is_empty() -> bool:
    if self.data.is_empty():
        return true
    return false


func find(message: String) -> int:
    var index: int = 0
    
    for element in self.data:
        var contain: int = element.find(message)
        if contain == -1:
            index += len(element)
            continue
        else:
            return index + contain
    
    return -1


func write(message: String) -> void:
    self.data.push_back(message)


func read_until(message: String) -> String:
    var found: int = self.find(message)
    if found == -1:
        return ""
    return self.unchecked_read(found + len(message))
    

func read(count: int = 1) -> String:
    assert(count > 0)
    
    if self.size() < count:
        return ""
    
    return self.unchecked_read(count)


func size() -> int:
    var acc: int = 0
    for message in self.data:
        acc += len(message)
    return acc


func unchecked_read(count: int = 1) -> String:
    assert(count > 0)
    var str_buf: PackedStringArray = []
    while count > 0:
        if self.is_empty():
            break
        
        if len(self.data[0]) > count:
            str_buf.push_back(self.data[0].substr(0, count))
            self.data[0] = self.data[0].substr(count)
        else:
            str_buf.push_back(self.data[0])
            self.data.remove_at(0)
    
    return "".join(str_buf)
