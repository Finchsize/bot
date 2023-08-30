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
$CHBOX_RANDOM_CORDS = GUICtrlCreateCheckbox("Random order", 448, 200, 97, 25)
$BTN_SAVE_CORDS_TO_FILE = GUICtrlCreateButton("Save...", 440, 232, 107, 25)
GUICtrlCreateGroup("", -99, -99, 1, 1)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_TYPE_VALIDATION_CODE = GUICtrlCreateButton("Auto type validation code", 24, 56, 139, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_START_HUNTING = GUICtrlCreateButton("Start hunting", 24, 16, 137, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_EXIT = GUICtrlCreateButton("Exit", 488, 400, 75, 25)
$BTN_GET_CORDS_IN_LOOP = GUICtrlCreateButton("Get cords in loop", 24, 96, 137, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_GET_HANDLES = GUICtrlCreateButton("Get window handles", 24, 136, 139, 33)
$LST_HUNTING_POINTS = GUICtrlCreateList("", 336, 35, 89, 344, BitOR($LBS_NOTIFY,$WS_VSCROLL,$WS_BORDER))
GUICtrlSetBkColor(-1, 0xFFFFFF)
$BTN_DELETE_POINT = GUICtrlCreateButton("Delete Point", 440, 104, 107, 25)
$BTN_EDIT_POINT = GUICtrlCreateButton("Edit Point", 440, 136, 107, 25)
$BTN_LOAD_FROM_FILE = GUICtrlCreateButton("Load from file", 440, 168, 107, 25)
$BTN_ADD_POINT = GUICtrlCreateButton("Add Point", 440, 40, 107, 25)
$BTN_ADD_POINT_AUTO = GUICtrlCreateButton("Add Point - AUTO", 440, 72, 107, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_STOP_HUNTING = GUICtrlCreateButton("Stop hunting", 168, 16, 131, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_GET_CORDS_IN_LOOP_STOP = GUICtrlCreateButton("STOP", 168, 96, 131, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$INPUT_CLIENT_INSTANCE = GUICtrlCreateInput("", 16, 312, 137, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_ROLL_INSTANCE_NAME = GUICtrlCreateButton("Change instance name", 168, 312, 129, 25)
$LBL_BOT_INSTANCE_NAME = GUICtrlCreateLabel("Bot instance name:", 16, 288, 95, 17)
$LABEL_HWND_INFO = GUICtrlCreateLabel(" Use ""Get Window handles"" to start hunting...", 26, 176, 246, 104, -1, $WS_EX_CLIENTEDGE)
$LBL_CHARACTER_NAME = GUICtrlCreateLabel("Character Name:", 16, 344, 84, 17)
$INPUT_CHARACTER_NAME = GUICtrlCreateInput("", 16, 368, 137, 21)
$BTN_TEST = GUICtrlCreateButton("Test", 16, 400, 145, 33)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###


#include <FileConstants.au3>
#include <MsgBoxConstants.au3>
#include <SendMessage.au3>
#include <WindowsConstants.au3>
#include <WinAPIConv.au3>
#include <WinAPIGdi.au3>
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
#include <GuiButton.au3>
#include <File.au3>
#include <ConquerOcr.au3>

GUISetIcon(@ScriptDir & "\bot.ico")
TraySetIcon(@ScriptDir & "\bot.ico")

Global $randomSleepArraySize = 15
Global $randomJumpFrequency = 3
Global $instanceName = ""
Global $scriptTempDir = ""
Global $pointsToGo[0]
Global $isInBotCheck = False

; cords in hWndControl for 1920x1080 TODO: make it generic
Global $iCenterPosX = 960
Global $iCenterPosY = 540

; is being use to perform a real click from time to time to prevent bot jail
$jumpCounter = 0
$realJumpFrequency = 45

Global $hWnd = 0
Global $hWndControl = 0
Global $clientWidth = 0
Global $clientHeight = 0

; retrieve parents for control
;~ Local $parent1 = _WinAPI_GetParent($hWndControl)
;~ ConsoleWrite($parent1 & @CRLF)
;~ Local $parent2 = _WinAPI_GetParent($parent1)
;~ ConsoleWrite($parent2 & @CRLF)
;~ Local $parent3 = _WinAPI_GetParent($parent2)
;~ ConsoleWrite($parent3 & @CRLF)
;~ Local $parent4 = _WinAPI_GetParent($parent3)
;~ ConsoleWrite($parent4 & @CRLF)

initialize()

While 1
	$msg = GUIGetMsg()
	Switch $msg
		Case $BTN_START_HUNTING
			start_hunt()
		Case $BTN_TYPE_VALIDATION_CODE
			type_validation_code()
		Case $BTN_GET_CORDS_IN_LOOP
			get_cords_in_loop()
		Case $BTN_GET_HANDLES
			get_window_handles()
		Case $BTN_LOAD_FROM_FILE
			load_points_from_file()
		Case $BTN_ROLL_INSTANCE_NAME
			roll_new_instance_name()
		Case $BTN_SAVE_CORDS_TO_FILE
			save_points_to_file()
		Case $BTN_ADD_POINT
			add_point_manually()
		Case $BTN_ADD_POINT_AUTO
			add_point_automatically()
		Case $BTN_DELETE_POINT
			delete_point()
		Case $BTN_EDIT_POINT
			edit_point()
		Case $GUI_EVENT_CLOSE
			clean_exit()
		Case $BTN_EXIT
			clean_exit()
		Case $BTN_TEST
			test()
	EndSwitch
WEnd

Func test()
	ConsoleWrite("Is ded : " & is_character_dead() & @CRLF)
	Return 
EndFunc

Func start_hunt()
	GUICtrlSetState($BTN_START_HUNTING, $GUI_DISABLE)
	GUICtrlSetState($BTN_STOP_HUNTING, $GUI_ENABLE)
	If ($isInBotCheck) Then
		Return
	EndIf
	
	Local $sleepArrayIterator = 0
	Local $lastSleepArray[$randomSleepArraySize]
	Local $randomJumpCurrentIt = 0
	Local $continueLoop = True
	Local $currentXpos = 0
	Local $currentYpos = 0
	Local $isDeadIterator = 0
	Local $checkDeadStatusFrequency = 10

	While $continueLoop
		Local $currentSelectedPointIndex = _GUICtrlListBox_GetCaretIndex($LST_HUNTING_POINTS)

		If($currentSelectedPointIndex == 0) Then
			_GUICtrlListBox_SetCurSel($LST_HUNTING_POINTS, 0)
			$currentSelectedPointIndex = 0
		EndIf

		; check if character is dead
		If (Mod($isDeadIterator, $checkDeadStatusFrequency) == 0 And is_character_dead()) Then
			ConsoleWrite("Character is dead" & @CRLF)
			Local $beginDead = TimerInit()
			While (TimerDiff($beginDead) < 21000 )
				For $i = 0 To 10 Step +1
					Sleep(10)
					Local $msg = GUIGetMsg()
					Switch $msg
						Case $BTN_STOP_HUNTING
							_GUICtrlButton_SetText($BTN_STOP_HUNTING, "Stopping...")
							GUICtrlSetState($BTN_STOP_HUNTING, $GUI_DISABLE)
							$continueLoop = False
					EndSwitch
				Next
			WEnd
			;press revive here
			ConsoleWrite("Revive here clicked" & @CRLF)
			ControlClick($hWnd, "", "XP2", "left")
			Sleep(100)
			If(is_character_dead()) Then
				ConsoleWrite("Character still dead, waiting 1 more second to retry revive" & @CRLF)
				Sleep(1000)
				ControlClick($hWnd, "", "XP2", "left")
			EndIf
			ContinueLoop
		Else
			$isDeadIterator = Mod($isDeadIterator, $checkDeadStatusFrequency)
		EndIf

		; check if stop loop was pressed during waiting
		If (Not $continueLoop) Then
			ExitLoop
		EndIf
		
		; prepare random sleep time
		Local $currentSleep = Random(5, 20, 1) * 10
		While _ArraySearch($lastSleepArray, $currentSleep) <> -1
			$currentSleep = Random(5, 20, 1) * 20
		WEnd
		$lastSleepArray[$sleepArrayIterator] = $currentSleep
		$sleepArrayIterator = Mod($sleepArrayIterator + 1, $randomSleepArraySize)

		For $i = 0 To $currentSleep / 10 Step +1
			Sleep(10)
			Local $msg = GUIGetMsg()
			Switch $msg
				Case $BTN_STOP_HUNTING
					_GUICtrlButton_SetText($BTN_STOP_HUNTING, "Stopping...")
					GUICtrlSetState($BTN_STOP_HUNTING, $GUI_DISABLE)
					$continueLoop = False
			EndSwitch
		Next

		; get current cords
		capture_entire_window($scriptTempDir, "\cords_from_hunting.tiff")
		process_image($scriptTempDir & "\cords_from_hunting.tiff", $scriptTempDir & "\cords_from_hunting_cropped.tiff", 73, 1802, 4, 1065)
		Local $currentCords = perform_ocr($scriptTempDir & "\cords_from_hunting_cropped.tiff")

		If StringLen($currentCords) == 6 Then
			$currentXpos = Number(StringLeft($currentCords, 3))
			$currentYpos = Number(StringRight($currentCords, 3))
		EndIf

		; validation code area check
		If $currentXpos == 51 And $currentYpos == 51 Then
			close_npc_message_box()
			type_validation_code()
			For $i = 0 To 50 Step +1
				Sleep(10)
				Local $msg = GUIGetMsg()
				Switch $msg
					Case $BTN_STOP_HUNTING
						_GUICtrlButton_SetText($BTN_STOP_HUNTING, "Stopping...")
						GUICtrlSetState($BTN_STOP_HUNTING, $GUI_DISABLE)
						$continueLoop = False
				EndSwitch
			Next
			ContinueLoop
		EndIf
		
		; try to turn on cyclone
		ControlClick($hWnd, "", "XP2", "left")
		
		For $i = 0 To $currentSleep / 10 Step +1
			Sleep(10)
			Local $msg = GUIGetMsg()
			Switch $msg
				Case $BTN_STOP_HUNTING
					_GUICtrlButton_SetText($BTN_STOP_HUNTING, "Stopping...")
					GUICtrlSetState($BTN_STOP_HUNTING, $GUI_DISABLE)
					$continueLoop = False
			EndSwitch
		Next

		; perform random jump if needed
		$randomJumpCurrentIt = Mod($randomJumpCurrentIt + 1, $randomJumpFrequency)
		If($randomJumpCurrentIt == 0) Then
			random_jump($currentSleep)
			ContinueLoop
		EndIf
		
		; get jump + scatter points from array
		Local $goToPointX = ($pointsToGo[$currentSelectedPointIndex])[0]
		Local $goToPointY = ($pointsToGo[$currentSelectedPointIndex])[1]

		ConsoleWrite("Going to X: " & $goToPointX & " Y: " & $goToPointY & @CRLF)

		; straight jump
		If($currentXpos - 8 > $goToPointX And $currentYpos - 8 > $goToPointY) Then
			jump_up($currentSleep)
			Sleep(Mod($currentSleep, 50))
			scatter_up()
		ElseIf($currentXpos + 8 < $goToPointX And $currentYpos + 8 < $goToPointY) Then
			jump_down($currentSleep)
			Sleep(Mod($currentSleep, 50))
			scatter_down()
		ElseIf($currentXpos - 8 > $goToPointX And $currentYpos + 8 < $goToPointY) Then
			jump_left($currentSleep)
			Sleep(Mod($currentSleep, 50))
			scatter_left()
		ElseIf($currentXpos + 8 < $goToPointX And $currentYpos - 8 > $goToPointY) Then
			jump_right($currentSleep)
			Sleep(Mod($currentSleep, 50))
			scatter_right()
		;diagonal jump
		ElseIf ($currentXpos - 16 > $goToPointX) Then
			jump_x_up($currentSleep)
			Sleep(Mod($currentSleep, 50))
			scatter_x_up()
		ElseIf ($currentXpos + 16 < $goToPointX) Then
			jump_x_down($currentSleep)
			Sleep(Mod($currentSleep, 50))
			scatter_x_down()
		ElseIf ($currentYpos - 16 > $goToPointY) Then
			jump_y_up($currentSleep)
			Sleep(Mod($currentSleep, 50))
			scatter_y_up()
		ElseIf ($currentYpos + 16 < $goToPointY) Then
			jump_y_down($currentSleep)
			Sleep(Mod($currentSleep, 50))
			scatter_y_down()
		Else
			$cordsCount = _GUICtrlListBox_GetCount($LST_HUNTING_POINTS)
			If(GuiCtrlRead($CHBOX_RANDOM_CORDS) == $GUI_CHECKED) Then
				_GUICtrlListBox_SetCurSel($LST_HUNTING_POINTS, _
				Mod( _
					Random(0, $cordsCount, 1),  _
					$cordsCount  _
					) _
				)
			Else
				_GUICtrlListBox_SetCurSel($LST_HUNTING_POINTS, _
					Mod( _
						_GUICtrlListBox_GetCaretIndex($LST_HUNTING_POINTS) + 1, _
						$cordsCount  _
						) _
					)
			EndIf
		EndIf

		For $i = 0 To 40 Step +1
			Sleep(10)
			Local $msg = GUIGetMsg()
			Switch $msg
				Case $BTN_STOP_HUNTING
					_GUICtrlButton_SetText($BTN_STOP_HUNTING, "Stopping...")
					GUICtrlSetState($BTN_STOP_HUNTING, $GUI_DISABLE)
					$continueLoop = False
			EndSwitch
		Next
	WEnd


	ToolTip("")
	GUICtrlSetState($BTN_START_HUNTING, $GUI_ENABLE)
	_GUICtrlButton_SetText($BTN_STOP_HUNTING, "Stop hunting")
EndFunc

Func type_validation_code()
	ConsoleWrite("AntyBot has been triggered!" & @CRLF)
	$isInBotCheck = True
	While(is_mouse_locked())
		Sleep(10)
	WEnd
	lock_mouse()

	; wait two seconds so other bots can finish their jumps etc
	Local $begin = TimerInit()
	For $i = 0 To 100 Step +1
		Sleep(20)
		ToolTip("Mouse will be taken by antybot in: " & (2000 - TimerDiff($begin))/1000 & " seconds.")
	Next
	ToolTip("")
	
	Local $hOldWndActive = WinGetHandle("[active]")
	Local $oldMousePos = MouseGetPos()
	close_npc_message_box()
	
	Local $windowAbsolutePosition = WinGetPos($hWnd)

	; put the window on top
	AutoItSetOption("MouseClickDelay", 80)
	WinSetOnTop($hWnd, "", $WINDOWS_ONTOP)
	WinSetState($hWnd, "", @SW_SHOW)
	WinActivate($hWnd)
	_winapi_setActiveWindow($hwnd)

	; click on NPC
	MouseClick("left", $windowAbsolutePosition[0] + 1151, $windowAbsolutePosition[1] + 399, 1, 0)
	Sleep(200)
	#cs NPC click without mouse - WIP
	Local $MK_CONTROL = 0x0008
	Local $MK_LBUTTON = 0x0001
	Local $lParam = _WinAPI_MakeLong($windowAbsolutePosition[0] + 1151, $windowAbsolutePosition[1] + 399)
	_WinAPI_PostMessage($hWndControl, $WM_LBUTTONDOWN, $MK_CONTROL, $lParam)
	Sleep(100)
	$lParam = _WinAPI_MakeLong(1151 - 5,399 - 2)
	_WinAPI_PostMessage($hWndControl, $WM_LBUTTONUP, $MK_CONTROL, $lParam)
	#ce
	
	; capture entire screen
	capture_entire_window($scriptTempDir, "\entire_screen_anytbot.tiff")
	Sleep(200)

	; capture the code value
	process_image($scriptTempDir & "\entire_screen_anytbot.tiff", $scriptTempDir & "\cropped_antybot.tiff", 882, 950, 64, 1005)
	Sleep(200)

	; run tesseract to decode the value from image to text
	Local $validationCode = perform_ocr($scriptTempDir & "\cropped_antybot.tiff")
	Sleep(200)
	
	; click on text field
	MouseClick("left", $windowAbsolutePosition[0] + 784, $windowAbsolutePosition[1] + 126, 1, 10)
	Sleep(200)

	; send value to input
	ConsoleWrite("Verification code to be send: " & $validationCode & @CRLF)
	Send($validationCode)
	Sleep(200)

	; click on OK button
	MouseClick("left", $windowAbsolutePosition[0] + 859, $windowAbsolutePosition[1] + 129, 1, 10)
	Sleep(200)

	; click on NPC
	MouseClick("left", $windowAbsolutePosition[0] + 1151, $windowAbsolutePosition[1] + 399, 1, 10)
	Sleep(200)

	; click on tp to the same place
	MouseClick("left", $windowAbsolutePosition[0] + 1049, $windowAbsolutePosition[1] + 132, 1, 10)
	Sleep(200)

	; cleanup
	WinSetOnTop($hWnd, "", $WINDOWS_NOONTOP)
	AutoItSetOption("MouseClickDelay", 10)

	; return PC to user - put old window as active
	MouseMove($oldMousePos[0], $oldMousePos[1], 0)
	WinSetOnTop($hOldWndActive, "", $WINDOWS_ONTOP)
	WinSetState($hOldWndActive, "", @SW_SHOW)
	WinActivate($hOldWndActive)
	_winapi_setActiveWindow($hOldWndActive)
	WinSetOnTop($hOldWndActive, "", $WINDOWS_NOONTOP)

	; change flag so other functions know character left anty bot
	$iIsInBotCheck = False
	unlock_mouse()
EndFunc

Func get_cords_in_loop()
	GUICtrlSetState($BTN_GET_CORDS_IN_LOOP, $GUI_DISABLE)
	GUICtrlSetState($BTN_GET_CORDS_IN_LOOP_STOP, $GUI_ENABLE)
	Local $continueLoop = True
	Local $currentXpos = 0
	Local $currentYpos = 0
	While $continueLoop
		capture_entire_window($scriptTempDir, "\cords_from_loop.tiff")
		process_image($scriptTempDir & "\cords_from_loop.tiff", $scriptTempDir & "\cords_from_loop_cropped.tiff", 73, 1802, 4, 1065)
		Local $currentCords = perform_ocr($scriptTempDir & "\cords_from_loop_cropped.tiff")

		If StringLen($currentCords) == 6 Then
			$currentXpos = Number(StringLeft($currentCords, 3))
			$currentYpos = Number(StringRight($currentCords, 3))
		EndIf

		; do some sleep
		For $i = 0 To 5 Step +1
			Sleep(10)
			Local $msg = GUIGetMsg()
			Switch $msg
				Case $BTN_GET_CORDS_IN_LOOP_STOP
					$continueLoop = False
			EndSwitch
		Next

		ToolTip("X: " & $currentXpos & " Y: " & $currentYpos, 0, 30)
	WEnd
	ToolTip("")
	GUICtrlSetState($BTN_GET_CORDS_IN_LOOP, $GUI_ENABLE)
	GUICtrlSetState($BTN_GET_CORDS_IN_LOOP_STOP, $GUI_DISABLE)
EndFunc

Func get_window_handles()
	Local $hwndArray = show_info_tooltip()
	If ($hwndArray[0] == 0) Then
		MsgBox($MB_ICONERROR, "Error", "No window selected")
		Return
	EndIf
	$hWnd = $hwndArray[0]
	$hWndControl = $hwndArray[1]
	Local $windowTitle = $hwndArray[2]

	Local $clientSize = WinGetClientSize($hWnd)
	$clientWidth = $clientSize[0]
	$clientHeight = $clientSize[1]

	GUICtrlSetData($LABEL_HWND_INFO, _
	" Window Title = " & $windowTitle & @CRLF & _
	" hWnd = " & $hWnd & @CRLF & _
	" hWndControl = " & $hWndControl & @CRLF & _
	" Window Width = " & $clientWidth & @CRLF & _
	" Window Height = " & $clientHeight)

	GUICtrlSetState($BTN_START_HUNTING, $GUI_ENABLE)
	GUICtrlSetState($BTN_TYPE_VALIDATION_CODE, $GUI_ENABLE)
	GUICtrlSetState($BTN_GET_CORDS_IN_LOOP, $GUI_ENABLE)
	GUICtrlSetState($BTN_ADD_POINT_AUTO, $GUI_ENABLE)
EndFunc

Func roll_new_instance_name()
	$result = ""
	Dim $space[3]
	$digits = 8
	For $i = 1 To $digits
		$space[0] = Chr(Random(65, 90, 1)) ;A-Z
		$space[1] = Chr(Random(97, 122, 1)) ;a-z
		$space[2] = Chr(Random(48, 57, 1)) ;0-9
		$result &= $space[Random(0, 2, 1)]
	Next
	GUICtrlSetData($INPUT_CLIENT_INSTANCE, $result)
	Return $result 
EndFunc

Func add_point_manually()
	Local $newValue = InputBox("Add cord", "Enter value as xxx,xxx example: 555,555", "")
	_GUICtrlListBox_BeginUpdate($LST_HUNTING_POINTS)
	_GUICtrlListBox_AddString($LST_HUNTING_POINTS, $newValue)
	_GUICtrlListBox_EndUpdate($LST_HUNTING_POINTS)
	
	$pointsToGo = split_points_to_array(read_points_from_list())
EndFunc

Func save_points_to_file()
	Local $pointsCount = _GUICtrlListBox_GetCount($LST_HUNTING_POINTS)
	Local $pointsToSave = read_points_from_list()
	Local $newFilePath = FileSaveDialog("Save to file", @ScriptDir & "\default_cords", "Text (*.txt)")
	Local $hFileOpen = FileOpen($newFilePath, $FO_OVERWRITE)
	For $point In $pointsToSave
		FileWriteLine($newFilePath, $point)
	Next
	FileClose($newFilePath)
	MsgBox($MB_TASKMODAL, "Saved", "Hunting points saved to: " & @CRLF & $newFilePath)
EndFunc

Func add_point_automatically()
	Local $currentXpos = 0
	Local $currentYpos = 0
	capture_entire_window($scriptTempDir, "\cords_from_auto_obtain.tiff")
	process_image($scriptTempDir & "\cords_from_auto_obtain.tiff", $scriptTempDir & "\cords_from_auto_obtain_cropped.tiff", 73, 1802, 4, 1065)
	Local $currentCords = perform_ocr($scriptTempDir & "\cords_from_auto_obtain_cropped.tiff")

	If StringLen($currentCords) == 6 Then
		$currentXpos = Number(StringLeft($currentCords, 3))
		$currentYpos = Number(StringRight($currentCords, 3))
	EndIf

	_GUICtrlListBox_BeginUpdate($LST_HUNTING_POINTS)
	_GUICtrlListBox_AddString($LST_HUNTING_POINTS, $currentXpos & "," & $currentYpos)
	_GUICtrlListBox_EndUpdate($LST_HUNTING_POINTS)

	$pointsToGo = split_points_to_array(read_points_from_list())
EndFunc

Func delete_point()
	_GUICtrlListBox_DeleteString($LST_HUNTING_POINTS, _GUICtrlListBox_GetCaretIndex($LST_HUNTING_POINTS))

	$pointsToGo = split_points_to_array(read_points_from_list())
EndFunc

Func edit_point()
	Local $selectedItemIndex = _GUICtrlListBox_GetCurSel($LST_HUNTING_POINTS)
	If ($selectedItemIndex == -1) Then
		MsgBox($MB_ICONINFORMATION, "No point selected", "Select point from list to modify it")
		Return
	EndIf
	Local $currentValue = _GUICtrlListBox_GetText($LST_HUNTING_POINTS, $selectedItemIndex)
	Local $newValue = InputBox("Change cords", "Enter value as xxx,xxx example: 555,555", $currentValue)
	_GUICtrlListBox_BeginUpdate($LST_HUNTING_POINTS)
	_GUICtrlListBox_ReplaceString($LST_HUNTING_POINTS, $selectedItemIndex, $newValue)
	_GUICtrlListBox_EndUpdate($LST_HUNTING_POINTS)

	$pointsToGo = split_points_to_array(read_points_from_list())
EndFunc

Func load_points_from_file()
	; read from file
	Local Const $message = "Open text file with points"
	Local $fileOpenDialogResult = FileOpenDialog($message, @ScriptDir & "\default_cords", "Text (*.txt)", $FD_FILEMUSTEXIST)
	If @error Then
		MsgBox($MB_ICONERROR, "No file selected", "No file has been chosen points are not changed.")
		FileChangeDir(@ScriptDir)
		Return
	EndIf
	; Change the working directory (@WorkingDir) back to the location of the script directory as FileOpenDialog sets it to the last accessed folder.
	FileChangeDir(@ScriptDir)
	Local $cordsFromFile = read_file_content($fileOpenDialogResult)
	If ($cordsFromFile == -1) Then
		MsgBox($MB_ICONERROR, "Reading cords failed", "Please check if file is in correct format.")
		Return
	EndIf

	; put into list in GUI
	_GUICtrlListBox_BeginUpdate($LST_HUNTING_POINTS)
	_GUICtrlListBox_ResetContent($LST_HUNTING_POINTS)
	For $point In $cordsFromFile
		_GUICtrlListBox_AddString($LST_HUNTING_POINTS, $point)
	Next
	_GUICtrlListBox_EndUpdate($LST_HUNTING_POINTS)

	; put into list in script
	$pointsToGo = split_points_to_array(read_points_from_list())
EndFunc

; if save button pressed return array[0] = hWnd array[1] = hControlWnd, otheriwse $array[2] = [0,0]
Func show_info_tooltip()
	Local $qKeyPressed = "51"
	Local $sKeyPressed = "53"
	Local $continueLoop = True
	Local $result[3] = [0,0,""]
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
				$result[2] = $windowsInfo[2]
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

;-----------------------------------------------
; Functions that are not directly connected with GUI
;-----------------------------------------------

Func initialize()
	; init directories
	$instanceName = roll_new_instance_name()
	$scriptTempDir = @ScriptDir & "\temp\" & $instanceName 
	If Not FileExists($scriptTempDir) Then
		DirCreate($scriptTempDir)
	EndIf

	; init default points
	$pointsToGo = split_points_to_array(read_points_from_list())
EndFunc

Func split_points_to_array($points)
	Local $result[UBound($points)]
	For $i = 0 To UBound($points)-1 Step +1
		Local $pointArray = StringSplit($points[$i], ",", $STR_NOCOUNT)
		Local $point = [$pointArray[0], $pointArray[1]]
		$result[$i] = $point
	Next
	Return $result 
EndFunc

Func read_points_from_list()
	Local $pointsCount = _GUICtrlListBox_GetCount($LST_HUNTING_POINTS)
	Local $points[$pointsCount]
	For $i = 0 To $pointsCount-1 Step +1
		$points[$i] = _GUICtrlListBox_GetText($LST_HUNTING_POINTS, $i)
	Next
	Return $points
EndFunc

Func capture_entire_window($imageOutPath, $imageOutName)
	Local $hDC_Capture = _WinAPI_GetDC($hWnd)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $clientWidth, $clientHeight)
	
	_WinAPI_SelectObject($hMemDC, $hBitmap)
	; this instruction is freezing client
	_WinAPI_PrintWindow($hWnd, $hMemDC)
	_WinAPI_SaveHBITMAPToFile($imageOutPath & $imageOutName, $hBitmap)

	; unfreeze screen
	Local $MK_CONTROL = 0x0008
	Local $MK_LBUTTON = 0x0001
	Local $lParam = _WinAPI_MakeLong(960, 540)
	_WinAPI_PostMessage($hWndControl, $WM_MOUSEMOVE, $MK_CONTROL, $lParam)

	; cleanup
	_WinAPI_ReleaseDC($hWnd, $hDC_Capture)
	_WinAPI_ReleaseDC(0, $hMemDC)
	_WinAPI_DeleteDC($hMemDC)
	_WinAPI_DeleteObject($hBitmap)

EndFunc

#cs Function process image as follows:
- crop 
- set text color to white
- remove background 
- set background color to black
#ce
Func process_image($imageFilePathOld, $imageFilePathNew, $cropLeft, $cropRight, $cropTop = 0, $cropBottom = 0, $replace_colors = True)
	
	_GDIPlus_Startup()

	; crop image
	Local $hImage = _GDIPlus_BitmapCreateFromFile($imageFilePathOld)
	Local $iX = _GDIPlus_ImageGetWidth($hImage)
	Local $iY = _GDIPlus_ImageGetHeight($hImage)
	Local $hImageCropped = _GDIPlus_BitmapCloneArea($hImage, $cropLeft, $cropTop, $iX-$cropLeft-$cropRight, $iY-$cropTop-$cropBottom, $GDIP_PXF32ARGB)
	If ($replace_colors) Then
		; set text color to white
		Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hImageCropped)
		Local $aRemapTable[3][2]
		$aRemapTable[0][0] = 2
		$aRemapTable[1][0] = 0xFF7F7F7F ;Old Color - letters shadow
		$aRemapTable[1][1] = 0xFF000000 ;New Color - letters shadow deleted
		$aRemapTable[2][0] = 0xFFFFFF00 ;Old Color - letters color (yellow)
		$aRemapTable[2][1] = 0xFFFFFFFF ;New Color - letter color (white)
		Local $hIA = _GDIPlus_ImageAttributesCreate()
		_GDIPlus_ImageAttributesSetRemapTable($hIA, $aRemapTable)
		_GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hImageCropped, 0, 0, $iX, $iY, 0, 0, $iX, $iY, $hIA)
		
		Local $iWidth = _GDIPlus_ImageGetWidth($hImageCropped)
		Local $iHeight = _GDIPlus_ImageGetHeight($hImageCropped)
		Local $tLock = _GDIPlus_BitmapLockBits($hImageCropped, 0, 0, $iWidth, $iHeight,  BitOR($GDIP_ILMWRITE, $GDIP_ILMREAD), $GDIP_PXF32ARGB)
		Local $tPixel = DllStructCreate("int color[" & $iWidth * $iHeight & "];", $tLock.scan0)
	
		; set background color to black
		For $i = 1 To $iWidth * $iHeight
		  If $tPixel.color(($i)) <> 0xFFFFFFFF Then $tPixel.color(($i)) = 0xFF000000
		Next

		_GDIPlus_GraphicsDispose($hGraphics)
		_GDIPlus_BitmapUnlockBits($hImageCropped, $tPixel)
		_GDIPlus_ImageAttributesDispose($hIA)
	EndIf
	
	;save
	_GDIPlus_ImageSaveToFile($hImageCropped, $imageFilePathNew)

	;clean handles etc
    _GDIPlus_ImageDispose($hImageCropped)
	_GDIPlus_ImageDispose($hImage)
    _GDIPlus_Shutdown()
EndFunc

; if fail return -1, success return an array of items
Func read_file_content($fullPath)
	Local $hFileOpen = FileOpen($fullPath, $FO_READ)
	If $hFileOpen = -1 Then
			Return -1
	EndIf
	Local $sOutput
	_FileReadToArray($hFileOpen, $sOutput, $FRTA_NOCOUNT)
	FileClose($hFileOpen)
	Return $sOutput
EndFunc

Func run_tesseract($ResultTextPath, $sImageFilePath)
	Local $TesseractExePath = @ScriptDir & "\Tesseract-OCR\tesseract.exe"
	Local $iPID = Run($TesseractExePath & " " &  $sImageFilePath & " " & $ResultTextPath &" nobatch digits" , "" , @SW_HIDE, $RUN_CREATE_NEW_CONSOLE)
	StdioClose($iPID)
EndFunc

Func close_npc_message_box()
	ControlClick($hWnd, "", "C")
EndFunc

Func random_jump($currentSleep)
	jump(960 + Random(-231, 321, 1), 540 + Random(-130, 30, 1), $currentSleep)
EndFunc

; -8 on x; -8 on y
Func jump_up($currentSleep)
	jump(960 + Random(-15,15,1), 270 + Random(-15,15,1), $currentSleep)
EndFunc

; +8 on x; +8 on y
Func jump_down($currentSleep)
	jump(960 + Random(-15,15,1), 810 + Random(-15,15,1), $currentSleep)
EndFunc

; -7 on x; +8/+7 on y
Func jump_left($currentSleep)
	jump(480, 540, $currentSleep)
EndFunc

; +8 on x; -8 on y
Func jump_right($currentSleep)
	jump(1440, 540, $currentSleep)
EndFunc

; -16 on y cord
Func jump_y_up($currentSleep)
	jump($iCenterPosX + 480 + Random(-45,0,1), $iCenterPosY - 270 + Random(0,45,1), $currentSleep)
EndFunc

; +16 on y cord
Func jump_y_down($currentSleep)
	jump($iCenterPosX - 480 + Random(0,45,1), $iCenterPosY + 270 + Random(-45,0,1), $currentSleep)
EndFunc

; -16 on x cord
Func jump_x_up($currentSleep)
	jump($iCenterPosX - 480 + Random(0,45,1), $iCenterPosY - 270 + Random(0,45,1), $currentSleep)
EndFunc

; +16 on x cord
Func jump_x_down($currentSleep)
	jump($iCenterPosX + 480 + Random(-45,0,1), $iCenterPosY + 270 + Random(-45,0,1), $currentSleep)
EndFunc

Func scatter_up()
	scatter(960, 270)
EndFunc

Func scatter_down()
	scatter(960, 810)
EndFunc

Func scatter_left()
	scatter(480, 540)
EndFunc

Func scatter_right()
	scatter(1440, 540)
EndFunc

Func scatter_y_up()
	scatter($iCenterPosX + 480, $iCenterPosY - 270)
EndFunc

Func scatter_y_down()
	scatter($iCenterPosX - 480, $iCenterPosY + 270)
EndFunc

Func scatter_x_up()
	scatter($iCenterPosX - 480, $iCenterPosY - 270)
EndFunc

Func scatter_x_down()
	scatter($iCenterPosX + 480, $iCenterPosY)
EndFunc

Func random_scatter()
	scatter($iCenterPosX + Random(-50, 50, 1), $iCenterPosY + Random(-50, 50, 1))
EndFunc

; jump with anty bot protection in mind, will perform real click from time to time
Func jump($xCordClick, $yCordClick, $currentSleep)
	$jumpCounter += 1
	Sleep($currentSleep)
	$currentClickCountCycle = Mod($jumpCounter, $realJumpFrequency)
	If($currentClickCountCycle > $realJumpFrequency - 4 ) Then
		ToolTip("Mouse will be taken in: " & $realJumpFrequency - $currentClickCountCycle)
	EndIf

	; anty bot jail protection
	If ($currentClickCountCycle == 0) Then
		While (is_mouse_locked())
			Sleep(10)
		WEnd
		lock_mouse()
		Local $hOldWndActive = WinGetHandle("[active]")
		Local $oldMousePos = MouseGetPos()
		ToolTip("Mouse will be taken in: 0")
		
		; put game on top and perform real click
		WinSetOnTop($hWnd, "", $WINDOWS_ONTOP)
		Local $windowAbsolutePosition = WinGetPos($hWnd)
		MouseClick($MOUSE_CLICK_LEFT, $windowAbsolutePosition[0] + 1151, $windowAbsolutePosition[1] + 399, 1, 10)
		ConsoleWrite("REAL CLICK AT: " & $jumpCounter & @CRLF)
		WinSetOnTop($hWnd, "", $WINDOWS_NOONTOP)

		; return PC to user - put old window as active
		MouseMove($oldMousePos[0], $oldMousePos[1], 0)
		WinSetOnTop($hOldWndActive, "", $WINDOWS_ONTOP)
		WinSetState($hOldWndActive, "", @SW_SHOW)
		WinActivate($hOldWndActive)
		_winapi_setActiveWindow($hOldWndActive)
		WinSetOnTop($hOldWndActive, "", $WINDOWS_NOONTOP)

		; cleanup
		ToolTip("")
		unlock_mouse()
		Sleep(300)
		Return
	EndIf
	
	; perform control click
	Local $MK_CONTROL = 0x0008
	Local $MK_LBUTTON = 0x0001
	Local $lParam = _WinAPI_MakeLong($xCordClick, $yCordClick)
	
	_WinAPI_PostMessage($hWndControl, $WM_LBUTTONDOWN, $MK_CONTROL, $lParam)
	Sleep($currentSleep)
	$lParam = _WinAPI_MakeLong($currentSleep - 20, $currentSleep - 20)
	_WinAPI_PostMessage($hWndControl, $WM_LBUTTONUP, $MK_CONTROL, $lParam)
	Sleep($currentSleep)
EndFunc

Func scatter($xCordClick, $yCordClick)
	Local $wParam = 0x0008 ; hold ctrl
	Local $lParam = _WinAPI_MakeLong($xCordClick, $yCordClick)
	_SendMessage($hWndControl, $WM_RBUTTONDOWN, $wParam , $lParam)
	Sleep(Random(30, 80, 1))
	_SendMessage($hWndControl, $WM_RBUTTONUP, $wParam , $lParam)
	Sleep(Random(30, 80, 1))
EndFunc

Func lock_mouse()
	If(Not is_mouse_locked()) Then
		Local Const $filePath = @ScriptDir & "\temp\mouse_taken.lock"
		_FileCreate($filePath)
	Else
		Sleep(10)
		lock_mouse()
	EndIf
EndFunc

Func unlock_mouse()
	Local Const $filePath = @ScriptDir & "\temp\mouse_taken.lock"
	FileDelete($filePath)
EndFunc


Func is_mouse_locked()
	Local Const $filePath = @ScriptDir & "\temp\mouse_taken.lock"
	; return 1 if file exists 0 otherwise
	Return FileExists($filePath) == 1
EndFunc

Func is_character_dead()
	capture_entire_window($scriptTempDir, "\dead_entire_screen.tiff")
	Sleep(100)
	process_image($scriptTempDir & "\dead_entire_screen.tiff", $scriptTempDir & "\dead_cropped.tiff" , 1820, 51, 930, 135, False)
	Return compare_images("C:\Users\danie\Desktop\au3\bot\utils\revive_button_cropped.tiff", $scriptTempDir & "\dead_cropped.tiff")
EndFunc