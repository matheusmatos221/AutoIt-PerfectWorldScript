#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>

Global Const $MAX_WINDOWS = 10
Global Const $TOTAL_MACROS = 10

Global $g_aWindows[10]
Global $g_iCount = 0
Global $g_iDelay = 10
Global $g_sHotkey[10]

; ================= GUI =================

Global $hGUI = GUICreate("Multi Window Manager v10 FINAL", 1350, 950)

; ================= STATUS =================

GUICtrlCreateLabel("STATUS:", 20, 15, 60, 20)
Global $lblStatus = GUICtrlCreateLabel("ESPERANDO", 80, 15, 150, 20)
GUICtrlSetColor($lblStatus, 0x00AA00)

; ================= GERENCIAMENTO =================

GUICtrlCreateGroup("Gerenciamento", 20, 40, 500, 380)

GUICtrlCreateLabel("Filtro:", 40, 80, 80, 20)
Global $inpFilter = GUICtrlCreateInput("", 120, 75, 200, 25)

GUICtrlCreateLabel("Qtd:", 340, 80, 40, 20)
Global $inpQtd = GUICtrlCreateInput("6", 380, 75, 40, 25)

Global $btnScan = GUICtrlCreateButton("Escanear", 200, 115, 120, 30)

Global $chkWin[10]
For $i = 0 To 9
    $chkWin[$i] = GUICtrlCreateCheckbox("Slot " & ($i+1), 40, 170 + ($i*20), 400, 20)
Next

GUICtrlCreateGroup("", -99, -99, 1, 1)

; ================= ENVIO DIRETO =================

GUICtrlCreateGroup("Envio Direto", 550, 40, 750, 180)

GUICtrlCreateLabel("Delay (ms):", 570, 80, 80, 20)
Global $inpDelay = GUICtrlCreateInput("10", 650, 75, 60, 25)

Global $btnSpace = GUICtrlCreateButton("SPACE", 750, 70, 100, 35)

; F1-F8
Global $btnF[8]
For $i = 0 To 7
    $btnF[$i] = GUICtrlCreateButton("F" & ($i+1), 570 + ($i*70), 120, 60, 35)
Next

; 1-9
Global $btnN[9]
For $i = 0 To 8
    $btnN[$i] = GUICtrlCreateButton(($i+1), 570 + ($i*70), 165, 60, 35)
Next

GUICtrlCreateGroup("", -99, -99, 1, 1)

; ================= MACROS =================

GUICtrlCreateGroup("Macros (10 independentes)", 20, 440, 1280, 380)

Global $inpMacro[10]
Global $inpHotkey[10]
Global $btnHotkey[10]

For $i = 0 To 9

    Local $y = 480 + ($i * 35)

    GUICtrlCreateLabel("Macro " & ($i+1) & ":", 40, $y+5, 60, 20)

    $inpMacro[$i] = GUICtrlCreateInput("", 110, $y, 350, 25)
    $inpHotkey[$i] = GUICtrlCreateInput("", 480, $y, 80, 25)
    $btnHotkey[$i] = GUICtrlCreateButton("Aplicar", 570, $y, 80, 25)

Next

; Macro 1 padrão
GUICtrlSetData($inpMacro[0], "{F2}|{F1}")
GUICtrlSetData($inpHotkey[0], "!q")
$g_sHotkey[0] = "!q"

GUICtrlCreateGroup("", -99, -99, 1, 1)

; ================= LAYOUT =================

GUICtrlCreateGroup("Layout", 550, 240, 750, 150)

Global $cmbLayout = GUICtrlCreateCombo("3x2", 570, 270, 100, 25)
GUICtrlSetData($cmbLayout, "1x1|2x2|3x2|4x2|Automático")

GUICtrlCreateLabel("Largura:", 700, 275, 60, 20)
Global $inpWidth = GUICtrlCreateInput("", 760, 270, 60, 25)

GUICtrlCreateLabel("Altura:", 840, 275, 60, 20)
Global $inpHeight = GUICtrlCreateInput("", 900, 270, 60, 25)

Global $btnLayout = GUICtrlCreateButton("Aplicar Layout", 980, 265, 150, 35)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; ================= LOG =================

GUICtrlCreateGroup("Log", 550, 820, 750, 110)

Global $txtLog = GUICtrlCreateEdit("", 570, 845, 710, 70, _
    BitOR($ES_READONLY, $WS_VSCROLL))

GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetState()

; Registrar hotkey padrão
HotKeySet($g_sHotkey[0], "Macro1")

; ================= LOOP =================

While 1

    $msg = GUIGetMsg()

    Switch $msg

        Case $GUI_EVENT_CLOSE
            Exit

        Case $btnScan
            ScanWindows()

        Case $btnLayout
            ApplyLayout()

        Case $btnSpace
            SendToAll("{SPACE}")

    EndSwitch

    For $i = 0 To 7
        If $msg = $btnF[$i] Then SendToAll("{F" & ($i+1) & "}")
    Next

    For $i = 0 To 8
        If $msg = $btnN[$i] Then SendToAll(($i+1))
    Next

    For $i = 0 To 9
        If $msg = $btnHotkey[$i] Then SetHotkey($i)
    Next

WEnd

; ================= FUNÇÕES =================

Func ExecuteMacroIndex($index)
    $g_iDelay = Int(GUICtrlRead($inpDelay))
    If $g_iDelay < 0 Then $g_iDelay = 10

    GUICtrlSetColor($lblStatus, 0xFF0000)
    GUICtrlSetData($lblStatus, "EXECUTANDO")

    AddLog("Macro " & ($index+1) & " iniciada.")

    Local $macro = GUICtrlRead($inpMacro[$index])
    Local $parts = StringSplit($macro, "|")

    For $p = 1 To $parts[0]

        For $i = 0 To $g_iCount - 1

            If GUICtrlRead($chkWin[$i]) = $GUI_CHECKED Then

                WinActivate($g_aWindows[$i])
                WinWaitActive($g_aWindows[$i], "", 2)
                Sleep(20)
                Send($parts[$p])
                Sleep($g_iDelay)

            EndIf

        Next

    Next

    AddLog("Macro " & ($index+1) & " finalizada.")

    GUICtrlSetColor($lblStatus, 0x00AA00)
    GUICtrlSetData($lblStatus, "ESPERANDO")

EndFunc

; 10 wrappers
Func Macro1()
    ExecuteMacroIndex(0)
EndFunc

Func Macro2()
    ExecuteMacroIndex(1)
EndFunc

Func Macro3()
    ExecuteMacroIndex(2)
EndFunc

Func Macro4()
    ExecuteMacroIndex(3)
EndFunc

Func Macro5()
    ExecuteMacroIndex(4)
EndFunc

Func Macro6()
    ExecuteMacroIndex(5)
EndFunc

Func Macro7()
    ExecuteMacroIndex(6)
EndFunc

Func Macro8()
    ExecuteMacroIndex(7)
EndFunc

Func Macro9()
    ExecuteMacroIndex(8)
EndFunc

Func Macro10()
    ExecuteMacroIndex(9)
EndFunc

Func SetHotkey($index)

    If $g_sHotkey[$index] <> "" Then
        HotKeySet($g_sHotkey[$index])
    EndIf

    $g_sHotkey[$index] = GUICtrlRead($inpHotkey[$index])
    If $g_sHotkey[$index] = "" Then Return

    HotKeySet($g_sHotkey[$index], "Macro" & ($index+1))

    AddLog("Hotkey Macro " & ($index+1) & ": " & $g_sHotkey[$index])

EndFunc

Func SendToAll($key)

    For $i = 0 To $g_iCount - 1

        If GUICtrlRead($chkWin[$i]) = $GUI_CHECKED Then

            WinActivate($g_aWindows[$i])
            WinWaitActive($g_aWindows[$i], "", 2)
            Sleep(20)
            Send($key)

        EndIf

    Next

    AddLog("Enviado: " & $key)

EndFunc

Func ScanWindows()

    $g_iCount = 0
    Local $filter = GUICtrlRead($inpFilter)
    Local $limit = Int(GUICtrlRead($inpQtd))
    If $limit < 1 Or $limit > 10 Then $limit = 6

    Local $aList = WinList()

    For $i = 1 To $aList[0][0]

        If $g_iCount >= $limit Then ExitLoop

        If $aList[$i][0] <> "" Then
            If $filter = "" Or StringInStr($aList[$i][0], $filter) Then
                If BitAND(WinGetState($aList[$i][1]), 2) Then
                    $g_aWindows[$g_iCount] = $aList[$i][1]
                    GUICtrlSetData($chkWin[$g_iCount], $aList[$i][0])
                    GUICtrlSetState($chkWin[$g_iCount], $GUI_CHECKED)
                    $g_iCount += 1
                EndIf
            EndIf
        EndIf
    Next

    AddLog("Janelas detectadas: " & $g_iCount)

EndFunc

Func ApplyLayout()

    Local $cols = 3
    Local $rows = 2

    Switch GUICtrlRead($cmbLayout)
        Case "1x1"
            $cols = 1
            $rows = 1
        Case "2x2"
            $cols = 2
            $rows = 2
        Case "3x2"
            $cols = 3
            $rows = 2
        Case "4x2"
            $cols = 4
            $rows = 2
        Case "Automático"
            $cols = Ceiling(Sqrt($g_iCount))
            $rows = Ceiling($g_iCount / $cols)
    EndSwitch

    Local $w = GUICtrlRead($inpWidth)
    Local $h = GUICtrlRead($inpHeight)

    If $w = "" Then $w = Int(@DesktopWidth / $cols)
    If $h = "" Then $h = Int(@DesktopHeight / $rows)

    Local $index = 0

    For $r = 0 To $rows - 1
        For $c = 0 To $cols - 1

            If $index >= $g_iCount Then ExitLoop

            WinMove($g_aWindows[$index], "", _
                $c*$w, $r*$h, $w, $h)

            $index += 1

        Next
    Next

    AddLog("Layout aplicado.")

EndFunc

Func UpdateStatus($running)
    If $running Then
        GUICtrlSetData($lblStatus, "EXECUTANDO")
        GUICtrlSetColor($lblStatus, 0xFF0000)
    Else
        GUICtrlSetData($lblStatus, "PRONTO")
        If $g_sTheme = "Dark" Then
            GUICtrlSetColor($lblStatus, 0x00FF00)
        Else
            GUICtrlSetColor($lblStatus, 0x006600)
        EndIf
    EndIf
EndFunc

Func AddLog($text)

    GUICtrlSetData($txtLog, GUICtrlRead($txtLog) & @CRLF & _
        "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $text)

EndFunc
