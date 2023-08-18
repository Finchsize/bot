#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=C:\Users\danie\Desktop\au3\bot\Form1.kxf
$SimpleGUI = GUICreate("Hunting Bot", 580, 439, -1, -1)
GUISetBkColor(0xFFFBF0)
$BTN_TYPE_VALIDATION_CODE = GUICtrlCreateButton("Auto type validation code", 24, 48, 139, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_START_HUNTING = GUICtrlCreateButton("Start hunting", 24, 8, 137, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_EXIT = GUICtrlCreateButton("Exit", 488, 400, 75, 25)
$BTN_GET_CORDS_IN_LOOP = GUICtrlCreateButton("Get cords in loop", 24, 88, 137, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_GET_WINDOW_HANDLES = GUICtrlCreateButton("Get window handles", 24, 128, 139, 33)
$BTN_CUSTOM_MOVE_POINTS = GUICtrlCreateButton("Custom move points", 24, 168, 139, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$LST_HUNTING_POINTS = GUICtrlCreateList("", 224, 72, 89, 97)
GUICtrlSetData(-1, "626, 831|627, 674|632, 582|654, 777|700, 555|897, 564")
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LABEL_HUNTING_POINTS = GUICtrlCreateLabel("Hunting points", 224, 48, 72, 17)
$BTN_DELETE_POINT = GUICtrlCreateButton("Delete Point", 320, 72, 83, 25)
$BTN_EDIT_POINT = GUICtrlCreateButton("Edit Point", 320, 104, 83, 25)
$BTN_LOAD_FROM_FILE = GUICtrlCreateButton("Load from file", 320, 136, 83, 25)
$CHECKBOX_LOGS = GUICtrlCreateCheckbox("Logs", 40, 240, 97, 17)
$INP_LOGS = GUICtrlCreateInput("", 32, 264, 521, 21)
$BTN_GAME_WINDOWS = GUICtrlCreateButton("Show open game windows", 24, 208, 139, 25)
$INPUT_GAME_NAME = GUICtrlCreateInput("Conquer", 240, 208, 139, 21)
$LABEL_CLIENT_NAME = GUICtrlCreateLabel("Client name", 168, 214, 59, 17)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>
#include <WinAPIConv.au3>
#include <WinAPIGdi.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <WinAPIFiles.au3>
#include <Array.au3>
#include <GUIConstantsEx.au3>
#include <WinAPISysWin.au3>
#include <WinAPISys.au3>
#include <Misc.au3>


GUISetIcon(@ScriptDir & "\bot.ico")
TraySetIcon(@ScriptDir & "\bot.ico")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $BTN_EXIT
			Exit
		Case $BTN_LOAD_FROM_FILE
			load_points_from_file()
		Case $BTN_GAME_WINDOWS
			show_game_instances()
		Case $BTN_GET_WINDOW_HANDLES
			get_window_handles()
		Case $BTN_START_HUNTING
			start_hunt()
	EndSwitch
WEnd

Func get_window_handles()
	show_window_info()
EndFunc

Func start_hunt()

EndFunc

Func show_game_instances()
	Local $windowsList = WinList("[REGEXPTITLE:(?i)(.*" & GUICtrlRead($INPUT_GAME_NAME) & ".*)]")
	_ArrayDisplay($windowsList)
EndFunc

Func load_points_from_file()
	Local Const $message = "Open text file with points"
	Local Const $path = @ScriptDir & "\saved" & "Text (*.txt)"
	Local $sFileOpenDialog = FileOpenDialog($message, $path, $FD_FILEMUSTEXIST)
	If @error Then
		MsgBox($MB_SYSTEMMODAL, "No file selected", "No file has been chosen points are not changed.")
	Else
		; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
		FileChangeDir(@ScriptDir)
		MsgBox($MB_SYSTEMMODAL, "", "Chosen file:" & @CRLF & $sFileOpenDialog)
	EndIf
EndFunc

Func show_window_info()
	Local $qKeyPressed = "51"
	Do
		AutoItSetOption("MouseCoordMode", 1) ; global position
		Local $windowsInfo = get_hwnd_and_titles()
		
		AutoItSetOption("MouseCoordMode", 2) ; relative cords in control
		Local $relativeMousePos = MouseGetPos()

		ToolTip("Press Q to exit" & @CRLF & _
			"Window hwnd = " & $windowsInfo[0] & @CRLF & _
			"Window ID = " & _WinAPI_GetDlgCtrlID($windowsInfo[0]) & @CRLF & _
			"Control hwnd = " & $windowsInfo[1] & @CRLF & _
			"Control ID = " & _WinAPI_GetDlgCtrlID($windowsInfo[1]) & @CRLF & _
			"Window Title = " & $windowsInfo[2] & @CRLF & _
			"Control Title = " & WinGetTitle($windowsInfo[1]) & @CRLF & _
			"Mouse X Pos global = " & $windowsInfo[3] & @CRLF & _
			"Mouse Y Pos global = " & $windowsInfo[4] & @CRLF & _
			"Mouse X Pos control = " & $relativeMousePos[0] & @CRLF & _
			"Mouse Y Pos control = " & $relativeMousePos[1])
		Sleep(50)
	Until _IsPressed($qKeyPressed)

	; cleanup
	ToolTip("")
	AutoItSetOption("MouseCoordMode", 1) ; reset to default
EndFunc

Func get_hwnd_and_titles()
	Local $mousePosition = MouseGetPos()
	If @error Then
		MsgBox($MB_ICONERROR, "Error", "Error while retrieving mouse position")
		Return
	EndIf
	Local $windowFromPoint = DllCall("user32.dll", "hwnd", "WindowFromPoint", "long", $mousePosition[0], "long", $mousePosition[1])
	If @error Then Return SetError(2, 0, 0)
	Local $topAncestor = DllCall("user32.dll", "hwnd", "GetAncestor", "hwnd", $windowFromPoint[0], "int", $GA_ROOTOWNER) ; Retrieves the owned root window by walking the chain of parent and owner windows returned by GetParent. 
	If @error Then Return SetError(3, 0, 0)
	Local $result[5] = [$topAncestor[0], $windowFromPoint[0], WinGetTitle($topAncestor[0]), $mousePosition[0], $mousePosition[1]]
	Return $result
EndFunc