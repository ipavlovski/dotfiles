import sublime, sublime_plugin

class MoveToSpaceCommand( sublime_plugin.TextCommand ):
    def run( self, edit, mode ):

        view = self.view
        selections = self.view.sel()

        if len( selections ) == 0:
            return

        newSelections = []

        for selection in selections:

            spacePoint = None

            if mode.lower() == "forward":

                spacePoint = self.view.find( "[^ ] " , selection.end() ).a

                if spacePoint != -1:
                    newSelections.append( sublime.Region( spacePoint + 1, spacePoint + 1 ) )

            elif mode.lower() == "backward":

                spaceRegions = self.view.find_all( " [^ ]")
                spaceRegion_Count = len( spaceRegions )

                for index in range( 0, spaceRegion_Count ):
                    if spaceRegions[ index ].b < selection.begin():
                        spacePoint = spaceRegions[ index ].a
                    elif spaceRegions[ index ].b >= selection.begin() \
                    and  spacePoint != None:
                        newSelections.append( sublime.Region( spacePoint + 1, spacePoint + 1 ) )
                        break

        if len( newSelections ) > 0:
            view.sel().clear()
            view.sel().add_all( newSelections )