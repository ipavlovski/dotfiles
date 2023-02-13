import sublime, sublime_plugin, subprocess
from subprocess import check_output

settings = {}
env = "tmux"

def get_selection(self):
    # save current position
    (row, col) = self.view.rowcol(self.view.sel()[0].begin())

    # get selection
    selection = ""
    for region in self.view.sel():
        if region.empty():
            selection += self.view.substr(self.view.line(region)) + "\n"
            advanceCursor(self, region)
    else:
        selection += self.view.substr(region) + "\n"

    # return to original selection
    target = self.view.text_point(row, col)
    self.view.sel().clear()
    self.view.sel().add(sublime.Region(target))
    self.view.show(target)

    # strip an extra new line that somehow makes it way there
    if selection[-2:] == '\n\n':
        selection = selection[:-1]        

    return selection

def advanceCursor(self, region):
    (row, col) = self.view.rowcol(region.begin())

    # Make sure not to go past end of next line
    nextline = self.view.line(self.view.text_point(row + 1, 0))
    if nextline.size() < col:
        loc = self.view.text_point(row + 1, nextline.size())
    else:
        loc = self.view.text_point(row + 1, col)

    # Remove the old region and add the new one
    self.view.sel().subtract(region)
    self.view.sel().add(sublime.Region(loc, loc))

def print_warning():
    subprocess.call(["notify-send", "JS-REPL DIDNT WORK"])  


def send_to_tmux(selection):
    tmux_output = subprocess.check_output(["tmux", "display-message", "-p", "-F", "'#{pane_in_mode}'"]).decode().rstrip()
    if tmux_output == "'1'":
        subprocess.call(["tmux", "send-keys", "C-m"])
    
    #progpath = settings.get('paths').get('tmux')
    progpath = "/usr/bin/tmux"
    subprocess.call([progpath, 'set-buffer', selection])
    subprocess.call([progpath, 'paste-buffer', '-d'])

def clear_tmux():
    progpath = "/usr/bin/tmux"
    subprocess.call([progpath, "send-keys", "C-l"])

def send_to_chromium(selection):
    progpath = "/usr/bin/chrome-console-log"
    subprocess.call([progpath, 'log', selection])

def clear_chromium():
    progpath = "/usr/bin/chrome-console-log"
    subprocess.call([progpath, "clear"])



class JsReplSend(sublime_plugin.TextCommand):
    global env

    def run(self, edit):
        # global settings
        # settings = sublime.load_settings('SendText.sublime-settings')

        selection =  get_selection(self)
        # only proceed if selection is not empty
        if(selection == "" or selection == "\n"):
            return

        if env == "tmux":
            send_to_tmux(selection)
        elif env == "chromium":
            send_to_chromium(selection.rstrip())
        else:
            print_warning()



class JsReplClear(sublime_plugin.TextCommand):
    global env

    def run(self, edit):
        if env == "tmux":
            clear_tmux()
        elif env == "chromium":
            clear_chromium()
        else:
            print_warning()

class JsReplOpenChrome(sublime_plugin.TextCommand):
    def run(self, edit):

        progpath = "chromium"
        port = "44717"
        userdir = check_output(["mktemp", "-t", "chrome-user-XXXXXXXXX", "-d"], universal_newlines=True).rstrip()
        subprocess.Popen([progpath, "--remote-debugging-port=" + port, "--user-data-dir=" + userdir])

class JsReplSetEnv(sublime_plugin.WindowCommand):
    def run(self):

        def done_callback(val):
          global env
          env = val

        msg = "Change environment [ tmux | chromium ]: "
        self.window.show_input_panel(msg, "", done_callback, None, None)
