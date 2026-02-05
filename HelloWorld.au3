#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         Matheus Matos

	 Script Function:
		Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <GUIConstantsEx.au3>

initGUI()

Func initGUI()
	;Create a GUI
	Local $mainGUI = GUICreate("mainGUI", 800, 1200)
	;Create controls to the GUI
	Local $btn
	;Display the GUI
	GUISetState(@SW_SHOW, $mainGUI)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				ExitLoop
		EndSwitch
	WEnd
EndFunc
