#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <ButtonConstants.au3>

Global Const $MAX_WINDOWS = 10
Global $g_aWindows[10]
Global $g_iCount = 0
Global $g_iDelay = 100
Global $g_sHotkey = "!q" ; ALT+Q padrão

; ================= GUI =================

Global $hGUI = GUICreate("Multi Window Manager v8 - Stable", 1050, 750)

; ---------- GERENCIAMENTO ----------
GUICtrlCreateGroup("Gerenciamento", 20, 20, 480, 330)

GUICtrlCreateLabel("Filtro (Título):", 40, 60, 100, 20)
Global $inpFilter = GUICtrlCreateInput("", 150, 55, 200, 25)

GUICtrlCreateLabel("Qtd (1-10):", 360, 60, 80, 20)
Global $inpQtd = GUICtrlCreateInput("6", 440, 55, 40, 25)

Global $btnScan = GUICtrlCreateButton("Escanear Janelas", 150, 95, 200, 30)

Global $chkWin[10]
For $i = 0 To 9
    $chkWin[$i] = GUICtrlCreateCheckbox("Slot " & ($i+1), 60, 140 + ($i*20), 400, 20)
Next

GUICtrlCreateGroup("", -99, -99, 1, 1)

; ---------- ENVIO ----------
GUICtrlCreateGroup("Envio de Comandos", 520, 20, 500, 330)

GUICtrlCreateLabel("Delay (ms):", 540, 60, 80, 20)
Global $inpDelay = GUICtrlCreateInput("100", 620, 55, 60, 25)

GUICtrlCreateLabel("Hotkey:", 700, 60, 60, 20)
Global $inpHotkey = GUICtrlCreateInput("!q", 760, 55, 80, 25)
Global $btnHotkey = GUICtrlCreateButton("Aplicar", 850, 55, 80, 25)

; Botões F1-F8
Global $btnF[8]
For $i = 0 To 7
    $btnF[$i] = GUICtrlCreateButton("F" & ($i+1), 540 + ($i*55), 110, 50, 35)
Next

; Botões 1-9
Global $btnN[9]
For $i = 0 To 8
    $btnN[$i] = GUICtrlCreateButton(($i+1), 540 + ($i*55), 170, 50, 35)
Next

GUICtrlCreateLabel("Macro (ex: {F2}|1|{SPACE})", 540, 230, 200, 20)
Global $inpMacro = GUICtrlCreateInput("{F2}|1|{SPACE}", 540, 255, 250, 25)
Global $btnMacro = GUICtrlCreateButton("Executar Macro", 810, 250, 150, 35)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; ---------- LAYOUT ----------
GUICtrlCreateGroup("Layout", 20, 370, 480, 140)

Global $cmbLayout = GUICtrlCreateCombo("3x2", 40, 400, 120, 25)
GUICtrlSetData($cmbLayout, "1x1|2x2|3x2|4x2|Automático")

Global $btnLayout = GUICtrlCreateButton("Aplicar Layout", 200, 395, 150, 35)

GUICtrlCreateGroup("", -99, -99, 1, 1)

; ---------- LOG ----------
GUICtrlCreateGroup("Log", 520, 370, 500, 320)

Global $btnClear = GUICtrlCreateButton("Limpar", 540, 400, 100, 30)
Global $txtLog = GUICtrlCreateEdit("", 540, 440, 460, 230, _
    BitOR($ES_READONLY, $WS_VSCROLL))

GUICtrlCreateGroup("", -99, -99, 1, 1)

GUISetState()

; Registrar hotkey padrão
HotKeySet($g_sHotkey, "ExecuteMacro")

; ================= LOOP =================

While 1

    $msg = GUIGetMsg()

    Switch $msg

        Case $GUI_EVENT_CLOSE
            Exit

        Case $btnScan
            ScanWindows()

        Case $btnMacro
            ExecuteMacro()

        Case $btnLayout
            ApplyLayout()

        Case $btnClear
            GUICtrlSetData($txtLog, "")

        Case $btnHotkey
            SetHotkey()

    EndSwitch

    ; F1-F8
    For $i = 0 To 7
        If $msg = $btnF[$i] Then
            SendToAll("{F" & ($i+1) & "}")
        EndIf
    Next

    ; 1-9
    For $i = 0 To 8
        If $msg = $btnN[$i] Then
            SendToAll(($i+1))
        EndIf
    Next

WEnd

; ================= FUNÇÕES =================

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

; ---------------------------------------

Func SendToAll($key)

    $g_iDelay = Int(GUICtrlRead($inpDelay))

    For $i = 0 To $g_iCount - 1

        If GUICtrlRead($chkWin[$i]) = $GUI_CHECKED Then

            WinActivate($g_aWindows[$i])
            WinWaitActive($g_aWindows[$i], "", 2)

            Sleep(50)
            Send($key)
            Sleep($g_iDelay)

        EndIf

    Next

    AddLog("Enviado: " & $key)

EndFunc

; ---------------------------------------

Func ExecuteMacro()

    Local $macro = GUICtrlRead($inpMacro)
    Local $parts = StringSplit($macro, "|")

    For $i = 1 To $parts[0]
        SendToAll($parts[$i])
    Next

    AddLog("Macro executada.")

EndFunc

; ---------------------------------------

Func ApplyLayout()

    Local $layout = GUICtrlRead($cmbLayout)
    Local $cols = 3
    Local $rows = 2

    Switch $layout
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

    Local $w = Int(@DesktopWidth / $cols)
    Local $h = Int(@DesktopHeight / $rows)
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

; ---------------------------------------

Func SetHotkey()

    HotKeySet($g_sHotkey) ; remove antiga

    Local $nova = GUICtrlRead($inpHotkey)
    If $nova = "" Then
        AddLog("Hotkey inválida.")
        Return
    EndIf

    $g_sHotkey = $nova
    HotKeySet($g_sHotkey, "ExecuteMacro")

    AddLog("Nova hotkey definida: " & $g_sHotkey)

EndFunc

; ---------------------------------------

Func AddLog($text)

    GUICtrlSetData($txtLog, GUICtrlRead($txtLog) & @CRLF & _
        "[" & @HOUR & ":" & @MIN & ":" & @SEC & "] " & $text)

EndFunc
