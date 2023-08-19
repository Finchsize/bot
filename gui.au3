#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=C:\Users\danie\Desktop\au3\bot\Form1.kxf
$GUI_BOT = GUICreate("Hunting Bot", 615, 445, -1, -1)
GUISetBkColor(0xFFFBF0)
$GROUP_HUNTING = GUICtrlCreateGroup("Hunting Points", 320, 8, 249, 385, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER), $WS_EX_TRANSPARENT)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_TYPE_VALIDATION_CODE = GUICtrlCreateButton("Auto type validation code", 24, 56, 139, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_START_HUNTING = GUICtrlCreateButton("Start hunting", 24, 16, 137, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_EXIT = GUICtrlCreateButton("Exit", 488, 400, 75, 25)
$BTN_GET_CORDS_IN_LOOP = GUICtrlCreateButton("Get cords in loop", 24, 96, 137, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_GET_WINDOW_HANDLES = GUICtrlCreateButton("Get window handles", 24, 136, 139, 33)
$LST_HUNTING_POINTS = GUICtrlCreateList("", 336, 35, 89, 344)
GUICtrlSetData(-1, "626,831|627,674|632,582|654,777|700,555|897,564")
GUICtrlSetBkColor(-1, 0xFFFFFF)
$BTN_DELETE_POINT = GUICtrlCreateButton("Delete Point", 440, 104, 107, 25)
$BTN_EDIT_POINT = GUICtrlCreateButton("Edit Point", 440, 136, 107, 25)
$BTN_LOAD_FROM_FILE = GUICtrlCreateButton("Load from file", 440, 168, 107, 25)
$BTN_GAME_WINDOWS = GUICtrlCreateButton("Show open game windows", 16, 408, 139, 25)
$INPUT_GAME_NAME = GUICtrlCreateInput("Conquer", 232, 408, 139, 21)
$LABEL_CLIENT_NAME = GUICtrlCreateLabel("Client name", 160, 414, 59, 17)
$BTN_SAVE_CONFIGURATION = GUICtrlCreateButton("Save configuration", 16, 344, 139, 25)
$BTN_LOAD_CONFIGURATION = GUICtrlCreateButton("Load configuration", 16, 376, 139, 25)
$BTN_ADD_POINT = GUICtrlCreateButton("Add Point", 440, 40, 107, 25)
$BTN_ADD_POINT_AUTO = GUICtrlCreateButton("Add Point - AUTO", 440, 72, 107, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
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
			clean_exit()
		Case $BTN_EXIT
			clean_exit()
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
		Case $BTN_EDIT_POINT
			edit_point()
	EndSwitch
WEnd

Func delete_point()
	_GUICtrlListBox_DeleteString($LST_HUNTING_POINTS, _GUICtrlListBox_GetCaretIndex($LST_HUNTING_POINTS))
EndFunc

Func edit_point()
	Local $selectedItemIndex = _GUICtrlListBox_GetCurSel($LST_HUNTING_POINTS)
	Local $currentValue = _GUICtrlListBox_GetText($LST_HUNTING_POINTS, $selectedItemIndex)
	Local $newValue = InputBox("Change cords", "Enter value as xxx,xxx example: 555,555", $currentValue)
	_GUICtrlListBox_BeginUpdate($LST_HUNTING_POINTS)
	_GUICtrlListBox_ReplaceString($LST_HUNTING_POINTS, $selectedItemIndex, $newValue)
	_GUICtrlListBox_EndUpdate($LST_HUNTING_POINTS)
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

	MsgBox($MB_TASKMODAL, "Saved", "Configuration saved")
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
	Local $hwndArray = show_info_tooltip()
	If ($hwndArray[0] == 0) Then
		MsgBox($MB_ICONERROR, "Error", "No window selected")
		Return
	EndIf
	$hWnd = $hwndArray[0]
	$hWndControl = $hwndArray[1]

	MsgBox($MB_ICONINFORMATION, "Success!", _
		"Handles has been set. " & @CRLF & _
		"hWnd = " & $hWnd & @CRLF & _
		"hWndControl = " & $hWndControl _
	)

	GUICtrlSetState($BTN_START_HUNTING, $GUI_ENABLE)
	GUICtrlSetState($BTN_TYPE_VALIDATION_CODE, $GUI_ENABLE)
	GUICtrlSetState($BTN_GET_CORDS_IN_LOOP, $GUI_ENABLE)
	GUICtrlSetState($BTN_ADD_POINT_AUTO, $GUI_ENABLE)
EndFunc

Func start_hunt()

EndFunc

Func load_points_from_file()
	Local Const $message = "Open text file with points"
	Local Const $path = @ScriptDir & "\saved"
	Local $fileOpenDialogResult = FileOpenDialog($message, $path, "Text (*.txt)", $FD_FILEMUSTEXIST)
	If @error Then
		MsgBox($MB_ICONERROR, "No file selected", "No file has been chosen points are not changed.")
	Else
		MsgBox($MB_TASKMODAL, "", "Chosen file:" & @CRLF & $fileOpenDialogResult)
	EndIf
	; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
	FileChangeDir(@ScriptDir)
EndFunc

; if save button pressed return array[0] = hWnd array[1] = hControlWnd, otheriwse $array[2] = [0,0]
Func show_info_tooltip()
	Local $qKeyPressed = "51"
	Local $sKeyPressed = "53"
	Local $continueLoop = True
	Local $result[2] = [0,0]
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
		For $i = 0 To 30 Step +1
			If _IsPressed($sKeyPressed) Then
				$result[0] = $windowsInfo[0]
				$result[1] = $windowsInfo[1]
				$continueLoop = False
				ExitLoop
			ElseIf _IsPressed($qKeyPressed) Then
				$continueLoop = False
				ExitLoop
			EndIf
			Sleep(10)
		Next
		
	WEnd

	; cleanup
	ToolTip("")
	AutoItSetOption("MouseCoordMode", 1) ; reset to default

	Return $result
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
	_DebugArrayDisplay($windowsList, "Select", "1:", BitOR($ARRAYDISPLAY_NOROW, $ARRAYDISPLAY_COLALIGNLEFT), "|", "Client Title|Hwnd", 1000, $hUserFunction)
EndFunc

Func save_hwnd_from_array_display($aArray_2D, $aSelected)
	If ($aSelected[0] == 0) Then
		MsgBox($MB_ICONERROR, "Error", "No row selected." & @CRLF & "Row must be selected!")
		Return 0
	EndIf
	Local $selectedIndex = $aSelected[1] - 1
	Local $selectedHwnd = $aArray_2D[$selectedIndex][1]
	MsgBox($MB_TASKMODAL, "Selected", "Selected hWnd: " & $selectedHwnd)
	Return 0
EndFunc

Func clean_exit()
	ToolTip("")
	Exit
EndFunc