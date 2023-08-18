#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=C:\Users\danie\Desktop\au3\bot\Form1.kxf
$SimpleGUI_1 = GUICreate("Hunting Bot", 583, 445, -1, -1)
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
$LST_HUNTING_POINTS = GUICtrlCreateList("", 216, 72, 89, 97)
GUICtrlSetData(-1, "626, 831|627, 674|632, 582|654, 777|700, 555|897, 564")
GUICtrlSetBkColor(-1, 0xFFFFFF)
$LABEL_HUNTING_POINTS = GUICtrlCreateLabel("Hunting points", 224, 48, 72, 17)
$BTN_DELETE_POINT = GUICtrlCreateButton("Delete Point", 320, 72, 83, 25)
$BTN_EDIT_POINT = GUICtrlCreateButton("Edit Point", 320, 104, 83, 25)
$BTN_LOAD_FROM_FILE = GUICtrlCreateButton("Load from file", 320, 136, 83, 25)
$BTN_GAME_WINDOWS = GUICtrlCreateButton("Show open game windows", 16, 408, 139, 25)
$INPUT_GAME_NAME = GUICtrlCreateInput("Conquer", 232, 408, 139, 21)
$LABEL_CLIENT_NAME = GUICtrlCreateLabel("Client name", 160, 414, 59, 17)
$BTN_SAVE_CONFIGURATION = GUICtrlCreateButton("Save configuration", 24, 240, 139, 25)
$BTN_LOAD_CONFIGURATION = GUICtrlCreateButton("Load configuration", 24, 272, 139, 25)
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
#include <GuiListView.au3>
#include <String.au3>
#include <Debug.au3>

GUISetIcon(@ScriptDir & "\bot.ico")
TraySetIcon(@ScriptDir & "\bot.ico")

$hWnd = 0
$hWndControl = 0

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
		Case $BTN_SAVE_CONFIGURATION
			save_configuration()
		Case $BTN_DELETE_POINT
			delete_point()	
	EndSwitch
WEnd

Func delete_point()
	_GUICtrlListBox_DeleteString($LST_HUNTING_POINTS, _GUICtrlListBox_GetCaretIndex($LST_HUNTING_POINTS))
EndFunc

Func save_configuration()
	Local $pointsCount = _GUICtrlListBox_GetCount($LST_HUNTING_POINTS)
	Local $pointsToSave = obtain_points_from_lst_ctrl()
	Local Const $filePath = @ScriptDir & "\saved\points.txt"
	Local $hFileOpen = FileOpen($filePath, $FO_OVERWRITE)
	For $point In $pointsToSave
		FileWriteLine($filePath, $point)
	Next
	FileClose($filePath)

	MsgBox($MB_SYSTEMMODAL, "Saved", "Configuration saved")
EndFunc

Func obtain_points_from_lst_ctrl()
	Local $pointsCount = _GUICtrlListBox_GetCount($LST_HUNTING_POINTS)
	Local $points[$pointsCount]
	For $i = 0 To $pointsCount-1 Step +1
		$points[$i] = _GUICtrlListBox_GetText($LST_HUNTING_POINTS, $i)
	Next
	Return $points
EndFunc

Func get_window_handles()
	show_info_tooltip()
EndFunc

Func start_hunt()

EndFunc

Func load_points_from_file()
	Local Const $message = "Open text file with points"
	Local Const $path = @ScriptDir & "\saved"
	Local $fileOpenDialogResult = FileOpenDialog($message, $path, "Text (*.txt)", $FD_FILEMUSTEXIST)
	If @error Then
		MsgBox($MB_TASKMODAL, "No file selected", "No file has been chosen points are not changed.")
	Else
		MsgBox($MB_TASKMODAL, "", "Chosen file:" & @CRLF & $fileOpenDialogResult)
	EndIf
	; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
	FileChangeDir(@ScriptDir)
EndFunc

Func show_info_tooltip()
	Local $qKeyPressed = "51"
	Local $sKeyPressed = "53"
	Local $continueLoop = True
	While $continueLoop
		AutoItSetOption("MouseCoordMode", 1) ; global position
		Local $windowsInfo = get_window_info()
		Local $globalMousePos = MouseGetPos()
		
		AutoItSetOption("MouseCoordMode", 2) ; relative cords in control
		Local $relativeMousePos = MouseGetPos()

		ToolTip("Press Q to exit" & @CRLF & _
			"Press S to save handles" & @CRLF & _
			"Window hwnd = " & $windowsInfo[0] & @CRLF & _
			"Window ID = " & $windowsInfo[4] & @CRLF & _
			"Control hwnd = " & $windowsInfo[1] & @CRLF & _
			"Control ID = " & $windowsInfo[5] & @CRLF & _
			"Window Title = " & $windowsInfo[2] & @CRLF & _
			"Control Title = " & $windowsInfo[3] & @CRLF & _
			"Mouse X Pos global = " & $globalMousePos[0] & @CRLF & _
			"Mouse Y Pos global = " & $globalMousePos[1] & @CRLF & _
			"Mouse X Pos control = " & $relativeMousePos[0] & @CRLF & _
			"Mouse Y Pos control = " & $relativeMousePos[1])
		Sleep(50)
		If _IsPressed($sKeyPressed) Then
			$hWnd = $windowsInfo[0]
			$hWndControl = $windowsInfo[1]
			$continueLoop = False
		ElseIf _IsPressed($qKeyPressed) Then
			$continueLoop = False
		EndIf
	WEnd

	; cleanup
	ToolTip("")
	AutoItSetOption("MouseCoordMode", 1) ; reset to default
EndFunc

#cs 
Return array 
- [0] -> top window handle
- [1] -> control handle
- [2] -> top window title
- [3] -> control title
- [4] -> top window ID
- [5] -> control ID
#ce
Func get_window_info()
	Local $mousePosition = MouseGetPos()
	If @error Then
		MsgBox($MB_ICONERROR, "Error", "Error while retrieving mouse position")
		Return
	EndIf
	Local $windowFromPoint = DllCall("user32.dll", "hwnd", "WindowFromPoint", "long", $mousePosition[0], "long", $mousePosition[1])
	If @error Then Return SetError(2, 0, 0)
	Local $topAncestor = DllCall("user32.dll", "hwnd", "GetAncestor", "hwnd", $windowFromPoint[0], "int", $GA_ROOTOWNER) ; Retrieves the owned root window by walking the chain of parent and owner windows returned by GetParent. 
	If @error Then Return SetError(3, 0, 0)
	Local $result[6] = [ _
		$topAncestor[0], _
		$windowFromPoint[0], _ 
		WinGetTitle($topAncestor[0]),  _
		WinGetTitle($windowFromPoint[0]), _
		_WinAPI_GetDlgCtrlID($topAncestor[0]), _
		_WinAPI_GetDlgCtrlID($windowFromPoint[0])  _
		]
	Return $result
EndFunc

Func show_game_instances()
	Local $windowsList = WinList("[REGEXPTITLE:(?i)(.*" & GUICtrlRead($INPUT_GAME_NAME) & ".*)]")
	Local $hUserFunction = save_hwnd_from_array_display
	_DebugArrayDisplay($windowsList, "Select", "1:", $ARRAYDISPLAY_NOROW, "|", "Client Title|Hwnd", 1000, $hUserFunction)
EndFunc

Func save_hwnd_from_array_display($aArray_2D, $aSelected)
	If ($aSelected[0] == 0) Then
		MsgBox($MB_ICONERROR, "Error", "No row selected." & @CRLF & "Row must be selected!")
		Return
	EndIf
	Local $selectedIndex = $aSelected[1] - 1
	Local $selectedHwnd = $aArray_2D[$selectedIndex][1]
	MsgBox($MB_TASKMODAL, "Selected", "Selected hWnd: " & $selectedHwnd)
EndFunc