@tool
class_name VimStatusLine
extends LineEdit

var ed
var set_up : bool = false
var last_command : String = ""

func _enter_tree():
    if not set_up:
        set_up = true

        text_submitted.connect(_on_text_submitted)
        focus_entered.connect(_on_focus_entered)
        focus_exited.connect(_on_focus_exited)
        gui_input.connect(_on_gui_input)

        # We do our best to hide what's going on under the hood
        flat = true
        expand_to_text_length = true
        add_theme_stylebox_override("focus", StyleBoxEmpty.new())
        mouse_filter = Control.MOUSE_FILTER_IGNORE
        text = "Evil-mode active"

func _on_text_submitted(new_text:String):
    text = new_text if new_text not in [":", ""] else last_command

    match text:
        ":w":
            var keystroke = InputEventKey.new()
            keystroke.keycode = KEY_S
            keystroke.ctrl_pressed = true
            ed.simulate_press_key(keystroke)
        ":wq":
            var keystroke = InputEventKey.new()
            keystroke.keycode = KEY_Q
            keystroke.ctrl_pressed = true
            ed.simulate_press_key(keystroke)
        ":p":
            var keystroke = InputEventKey.new()
            keystroke.keycode = KEY_F5
            ed.simulate_press_key(keystroke)
        ":ps":
            var keystroke = InputEventKey.new()
            keystroke.keycode = KEY_F6
            ed.simulate_press_key(keystroke)
        _:
            if new_text.substr(1).is_valid_int():
                var line: int = (new_text.substr(1) as int)-1
                ed.jump_to(line, ed.find_first_non_white_space_character(line))
            else:
                printerr("Unimplemented command: ", text.substr(1))
    last_command = text
    release_focus()

func _on_focus_entered():
    placeholder_text = last_command
    editable = true
    caret_column = len(text)

func _on_focus_exited():
    text = " " # For some reason setting the string to "" does nothing
    ed.code_editor.grab_focus()

func _on_gui_input(event):
    if event is InputEventKey:
        if event.keycode == KEY_ESCAPE:
            release_focus()
