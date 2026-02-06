#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         myName

	 Script Function:
		Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

;#include <MsgBoxConstants.au3>

GetHWndList()


Func GetHWnd()
	;Pausa execução do script até que determinada tela apareça e retorna o handle
	Local $hWnd = WinWait("[TITLE:The Classic PW 1.2.6;CLASS:ElementClient Window]")
	ConsoleWrite("Obteve o handler: " & $hWnd & @CRLF)
EndFunc


Func GetHWndClick()
	;Pausa execução do script até que determinada tela apareça e retorna o handle
	Local $hWnd = WinWaitActive("[TITLE:The Classic PW 1.2.6;CLASS:ElementClient Window]")
	ConsoleWrite($hWnd& @CRLF)
EndFunc


Func GetHWndList()
    ; Retrieve a list of window handles.
    Global $aList = WinList("[TITLE:The Classic PW 1.2.6;CLASS:ElementClient Window]")

#cs
    ; Loop through the array displaying only visable windows with a title.
    For $i = 1 To $aList[0][0]
        If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
            MsgBox($MB_SYSTEMMODAL, "", "Title: " & $aList[$i][0] & @CRLF & "Handle: " & $aList[$i][1])
        EndIf
    Next
#ce
#cs
    ; Loop through the array displaying only visable windows with a title.
    For $i = 1 To $aList[0][0]
        If $aList[$i][0] <> "" And BitAND(WinGetState($aList[$i][1]), 2) Then
            ConsoleWrite($aList[$i][1] & @CRLF)
        EndIf
    Next
#ce
EndFunc