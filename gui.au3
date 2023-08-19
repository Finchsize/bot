#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#Region ### START Koda GUI section ### Form=C:\Users\danie\Desktop\au3\bot\Form1.kxf
$GUI_BOT = GUICreate("Hunting Bot", 594, 445, -1, -1)
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
$BTN_GET_HANDLES = GUICtrlCreateButton("Get window handles", 24, 136, 139, 33)
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
$BTN_STOP_HUNTING = GUICtrlCreateButton("Stop hunting", 168, 16, 131, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_GET_CORDS_IN_LOOP_STOP = GUICtrlCreateButton("STOP", 168, 96, 131, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$INPUT_CLIENT_INSTANCE = GUICtrlCreateInput("", 16, 312, 137, 21)
GUICtrlSetState(-1, $GUI_DISABLE)
$BTN_ROLL_INSTANCE_NAME = GUICtrlCreateButton("Change instance name", 168, 312, 129, 25)
$LBL_BOT_INSTANCE_NAME = GUICtrlCreateLabel("Bot instance name:", 16, 288, 95, 17)
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
#include <GuiButton.au3>
#include <File.au3>

GUISetIcon(@ScriptDir & "\bot.ico")
TraySetIcon(@ScriptDir & "\bot.ico")

Global $instanceName = ""
Global $scriptTempDir = ""
Global $scriptSaveDir = ""
Global $pointsToGo[0]
Global $isInBotCheck = False
initialize()

Global $hWnd = 0
Global $hWndControl = 0
Global $clientWidth = 0
Global $clientHeight = 0

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
		Case $BTN_SAVE_CONFIGURATION
			save_configuration()
		Case $BTN_LOAD_CONFIGURATION
			load_configuration()
		Case $BTN_ADD_POINT
			add_point_manually()
		Case $BTN_ADD_POINT_AUTO
			add_point_automatically()
		Case $BTN_DELETE_POINT
			delete_point()
		Case $BTN_EDIT_POINT
			edit_point()
		Case $BTN_GAME_WINDOWS
			show_game_instances()
		Case $GUI_EVENT_CLOSE
			clean_exit()
		Case $BTN_EXIT
			clean_exit()
	EndSwitch
WEnd

Func start_hunt()
	GUICtrlSetState($BTN_START_HUNTING, $GUI_DISABLE)
	GUICtrlSetState($BTN_STOP_HUNTING, $GUI_ENABLE)

	GUICtrlSetState($BTN_START_HUNTING, $GUI_ENABLE)
	GUICtrlSetState($BTN_STOP_HUNTING, $GUI_DISABLE)
EndFunc

Func type_validation_code()
EndFunc

Func get_cords_in_loop()
	GUICtrlSetState($BTN_GET_CORDS_IN_LOOP, $GUI_DISABLE)
	GUICtrlSetState($BTN_GET_CORDS_IN_LOOP_STOP, $GUI_ENABLE)
	Local $continueLoop = True
	Local $currentXpos = 0
	Local $currentYpos = 0
	While $continueLoop
		capture_entire_window($scriptTempDir, "\cords_from_loop.tiff")
		process_image($scriptTempDir & "\cords_from_loop.tiff", $scriptTempDir & "\cords_from_loop_cropped.tiff", 69, 1798, 0, 1060)
		run_tesseract($scriptTempDir & "\cords_from_loop", $scriptTempDir & "\cords_from_loop_cropped.tiff")

		; sleep 200 for tesseract processing; check for button stop in the meantime
		For $i = 0 To 20 Step +1
			Sleep(10)
			Local $msg = GUIGetMsg()
			Switch $msg
				Case $BTN_GET_CORDS_IN_LOOP_STOP
					$continueLoop = False
			EndSwitch
		Next

		; read tesseract output
		Local $currentPointRaw = read_file_content($scriptTempDir & "\cords_from_loop.txt")
		If ($currentPointRaw == -1) Then
			ToolTip("Reading cords failed")
			ContinueLoop
		EndIf

		; clean tesseract junk
		Local $pointCleaned = StringReplace($currentPointRaw[0], ".", "")
		$pointCleaned = StringReplace($pointCleaned, @LF, "")

		; check if tesseract output is in good format
		If StringLen($pointCleaned) == 6 Then
			$currentXpos = Number(StringLeft($pointCleaned, 3))
			$currentYpos = Number(StringRight($pointCleaned, 3))
		EndIf

		; show cords
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

	Local $clientSize = WinGetClientSize($hWnd)
	$clientWidth = $clientSize[0]
	$clientHeight = $clientSize[1]

	MsgBox($MB_ICONINFORMATION, "Success!", _
		"Handles has been set. " & @CRLF & _
		"hWnd = " & $hWnd & @CRLF & _
		"hWndControl = " & $hWndControl & @CRLF & _
		"Window Width = " & $clientWidth & @CRLF & _
		"Window Height = " & $clientHeight _
	)

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

Func save_configuration()
	Local Const $filePath = $scriptSaveDir & "\points.txt"
	Local $pointsCount = _GUICtrlListBox_GetCount($LST_HUNTING_POINTS)
	Local $pointsToSave = read_points_from_list()
	Local $hFileOpen = FileOpen($filePath, $FO_OVERWRITE)
	For $point In $pointsToSave
		FileWriteLine($filePath, $point)
	Next
	FileClose($filePath)

	MsgBox($MB_TASKMODAL, "Saved", "Configuration saved")
EndFunc

Func load_configuration()
EndFunc

Func add_point_manually()
EndFunc

Func add_point_automatically()
EndFunc

Func delete_point()
	_GUICtrlListBox_DeleteString($LST_HUNTING_POINTS, _GUICtrlListBox_GetCaretIndex($LST_HUNTING_POINTS))
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
EndFunc

Func load_points_from_file()
	; read from file
	Local Const $message = "Open text file with points"
	Local $fileOpenDialogResult = FileOpenDialog($message, $scriptSaveDir, "Text (*.txt)", $FD_FILEMUSTEXIST)
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
	Local $points = read_points_from_list()
	$pointsToGo = split_points_to_array($points)
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

;-----------------------------------------------
; Functions that are not directly connected with GUI
;-----------------------------------------------

Func initialize()
	; init directories
	$instanceName = roll_new_instance_name()
	$scriptTempDir = @ScriptDir & "\temp\" & $instanceName 
	$scriptSaveDir = @ScriptDir & "\saved\" & $instanceName
	If Not FileExists($scriptTempDir) Then
		DirCreate($scriptTempDir)
	EndIf

	If Not FileExists($scriptSaveDir) Then
		DirCreate($scriptSaveDir)
	EndIf

	; init default points
	Local $points = read_points_from_list()
	$pointsToGo = split_points_to_array($points)
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
	_WinAPI_PrintWindow($hWnd, $hMemDC)
	_WinAPI_SaveHBITMAPToFile($imageOutPath & $imageOutName, $hBitmap)
EndFunc

#cs Function process image as follows:
- crop 
- set text color to white
- remove background 
- set background color to black
#ce
Func process_image($imageFilePathOld, $imageFilePathNew, $cropLeft, $cropRight, $cropTop = 0, $cropBottom = 0)
	
	_GDIPlus_Startup()

	; crop image
	Local $hImage = _GDIPlus_BitmapCreateFromFile($imageFilePathOld)
	Local $iX = _GDIPlus_ImageGetWidth($hImage)
	Local $iY = _GDIPlus_ImageGetHeight($hImage)
	Local $hImageCropped = _GDIPlus_BitmapCloneArea($hImage, $cropLeft, $cropTop, $iX-$cropLeft-$cropRight, $iY-$cropTop-$cropBottom, $GDIP_PXF32ARGB)

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
	
	;save
	_GDIPlus_BitmapUnlockBits($hImageCropped, $tPixel)
	_GDIPlus_ImageSaveToFile($hImageCropped, $imageFilePathNew)

	;clean handles etc
	_GDIPlus_ImageAttributesDispose($hIA)
    _GDIPlus_ImageDispose($hImageCropped)
	_GDIPlus_GraphicsDispose($hGraphics)
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