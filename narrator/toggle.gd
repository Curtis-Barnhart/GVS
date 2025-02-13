extends Button


# wait... can't the grab focus function be immediately connected without
# this intermediate function??? TODO
func accept_focus():
    self.grab_focus()
