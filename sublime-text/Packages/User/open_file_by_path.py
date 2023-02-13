import sublime, sublime_plugin

def open_file(window, filename):
  window.open_file(filename, sublime.ENCODED_POSITION)

class OpenFileByPathCommand(sublime_plugin.WindowCommand):
  def run(self):
    def done_callback(filename):
      open_file(self.window, filename)

    self.window.show_input_panel("Open File by Path: ", "", done_callback, None, None)