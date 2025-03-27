extends Object

const ClassLoader = preload("res://gvs_class_loader.gd")
const StringsUtil = ClassLoader.shared.scripts.Strings


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
    var start: int = StringsUtil.prev_f(s, index, func (c: String) -> bool: return c == " ")
    var end: int = StringsUtil.next_f(s, index, func (c: String) -> bool: return c == " ")
    if start == -1:
        start = 0
    else:
        start += 1
    if end == -1:
        end = len(s)
    else:
        end += 1

    return s.substr(start, end - start)


## Helper function to format text with BBCode markup.
## first element of text should be the title (String).
## every subsequent element should be an array of strings,
## where each array is one paragraph in full.
## the elements of each array will be joined with spaces,
## and the arrays themselves with two newlines and 4 spaces for indentation.
##
## @param text: data structure with strings to format.
## @return: formatted string with BBCode markup.
static func make_article(text: Array) -> String:
    return "[font_size=48][center][b]%s[/b][/center][/font_size]\n\n    " % text[0] + \
        "\n\n    ".join(text.slice(1).map(func (sent: Array) -> String: return " ".join(sent))) + \
        "\n\n    "


## [param text]: Array of Array[String]
static func make_paragraphs(text: Array) -> String:
    return "\n\n    ".join(text.map(func (sent: Array) -> String: return " ".join(sent))) + \
           "\n\n    "
