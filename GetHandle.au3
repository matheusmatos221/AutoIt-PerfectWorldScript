#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         myName

	 Script Function:
		Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here



Main()


Func Main()
	;Pausa execução do script até que determinada tela apareça e retorna o handle
	Local $hWnd = WinWaitActive("[TITLE:The Classic PW 1.2.6;CLASS:ElementClient Window]")
	ConsoleWrite($hWnd& @CRLF)
	;Local $handle = ControlGetHandle("[TITLE:"The Classic PW 1.2.6;CLASS:ElementClient Window]","")
	;MsgBox(1,"title",$hWnd)
EndFunc

