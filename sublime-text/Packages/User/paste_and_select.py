import sublime
import sublime_plugin


class PasteAndSelectCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        before_selections = [sel for sel in self.view.sel()]
        self.view.run_command('paste')
        after_selections = [sel for sel in self.view.sel()]
        new_selections = list()
        delta = 0
        for before, after in zip(before_selections, after_selections):
            new = sublime.Region(before.begin() + delta, after.end())
            delta = after.end() - before.end()
            new_selections.append(new)
        self.view.sel().clear()
        self.view.sel().add_all(new_selections)
