class_name utils_strings
extends Object


## Find the index of the next character satisfying `functor` in a string.
##
## @param s: the string to search for characters satisfying `functor`.
## @param start: index to start searching at.
## @param functor: A test for the character you want.
static func next_f(s: String, start: int, functor: Callable) -> int:
    var limit: int = len(s)
    while ((start != limit) and (not functor.call(s[start]))):
        start += 1

    if start == limit:
        return -1
    return start


## Find the index of the previous character satisfying `functor` in a string.
##
## @param s: the string to search for characters satisfying `functor`.
## @param start: index to start searching at.
## @param functor: A test for the character you want.
static func prev_f(s: String, start: int, functor: Callable) -> int:
    while ((start != -1) and (not functor.call(s[start]))):
        start -= 1
    return start


## Extract a word containing the character at index `index`.
##
## @param 
static func extract_word(s: String, index: int) -> String:
    # empty string means no word
    if s[index] == " ":
        return ""

    # Get bounds of word
    var start: int = utils_strings.prev_f(s, index, func (c): return c == " ")
    var end: int = utils_strings.next_f(s, index, func (c): return c == " ")
    if start == -1:
        start = 0
    else:
        start += 1
    if end == -1:
        end = len(s)
    else:
        end += 1

    return s.substr(start, end - start)
