#include <SendMessage.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
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
#include <WinAPIDlg.au3>

HotKeySet("!t", "type_validation_code")
HotKeySet("^t", "start_hunt")
HotKeySet("^q", "exit_bot")
HotKeySet("^m", "get_cords_in_loop")
HotKeySet("^i", "get_window_handles")
HotKeySet("!i", "exit_get_window_handles")
HotKeySet("^p", "obtain_move_points")
HotKeySet("{F8}", "get_current_window")

Global $iContinueGetHandles = True
Global $iIsInBotCheck = False

$hWnd = 0
$hWndControl = 0
$currentXpos = 0
$currentYpos = 0
$sImageFileExtenstion = ".tiff";
$sImageFilePath = @ScriptDir & "\temp\cords" & $sImageFileExtenstion
$sImageFilePathAntyBot = @ScriptDir & "\temp\val_code" & $sImageFileExtenstion
; hControlPositions
$iCenterPosX = 960
$iCenterPosY = 540

$iClickCounter = 0

; current global
$iCenterPosX_global = 3857
$iCenterPosY_global = 689

; ape decent hunting path
Local $p1[2] = [632, 582]
Local $p2[2] = [700, 555]
Local $p3[2] = [897, 564]
Local $p4[2] = [626, 831]
Local $p5[2] = [654, 777]
Local $p6[2] = [627, 674]


Local $pointsToGo[6] = [$p1, $p2, $p3, $p4, $p5, $p6]

While 1
	Sleep(20 + Random(1, 10, 1))
WEnd

Func get_current_window()
	Capture_Entire_Window($hWnd, @ScriptDir & "\temp\entire_screen.tiff")
	Sleep(1000)
	crop_cords_from_image(@ScriptDir & "\temp\entire_screen.tiff", @ScriptDir & "\temp\cropped_screen_transformed.tiff", 878, 950, 60, 980)
	crop_cords_from_image(@ScriptDir & "\temp\entire_screen.tiff", @ScriptDir & "\temp\entire_screen_transformed.tiff", 0, 0, 0, 0)
	WinSetOnTop($hWnd, "", $WINDOWS_NOONTOP)
EndFunc

Func type_validation_code()
	$iIsInBotCheck = True
	ConsoleWrite("AntyBot has been triggered!" & @CRLF)
	Local $windowAbsolutePosition = WinGetPos($hWnd)

	; put the window on top
	AutoItSetOption("MouseClickDelay", 80)
	WinSetOnTop($hWnd, "", $WINDOWS_ONTOP)
	WinSetState($hWnd, "", @SW_SHOW)
	WinActivate($hWnd)
	_winapi_setActiveWindow($hwnd)
	Sleep(200)

	; click on NPC
	MouseClick("left", $windowAbsolutePosition[0] + 1151, $windowAbsolutePosition[1] + 399, 1, 10)
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
	Capture_Entire_Window($hWnd, @ScriptDir & "\temp\entire_screen.tiff")
	Sleep(300)

	; capture the code value
	crop_cords_from_image(@ScriptDir & "\temp\entire_screen.tiff", @ScriptDir & "\temp\val_code.tiff", 878, 950, 60, 980)
	Sleep(300)

	; run tesseract to decode the value from image to text
	run_tesseract(@ScriptDir & "\temp\val_code", @ScriptDir & "\temp\val_code.tiff")
	Sleep(200)
	
	; click on text field
	MouseClick("left", $windowAbsolutePosition[0] + 784, $windowAbsolutePosition[1] + 126, 1, 10)
	Sleep(150)

	; open the file with code to put
	Local $hFileOpen = FileOpen(@ScriptDir & "\temp\val_code" & ".txt", $FO_READ)
	If $hFileOpen = -1 Then
			ToolTip("An error occurred when reading the file. File Path: " & @ScriptDir & "\temp\val_code" & ".txt", 30, 0)
			Return
	EndIf

	; read text file and send value to input
	Local $sOutput = FileRead($hFileOpen)
	FileClose($hFileOpen)
	Local $sOutputClean = StringReplace($sOutput, @LF, "")
	ConsoleWrite("Verification code to be send: " & $sOutputClean & @CRLF)
	Send($sOutputClean)
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
	AutoItSetOption ("MouseClickDelay", 10)
	$iIsInBotCheck = False
EndFunc

Func start_hunt()
	If ($iIsInBotCheck) Then
		Return 0
	EndIf
	Local $goToPoint = 0
	Local $iSleepArraySize = 15
	Local $iSleepArrayIterator = 0
	Local $iLastSleep[$iSleepArraySize]
	Local $iRandomJumpFrequency = 5
	Local $iRandomJumpCurrentIt = 0
While 1
	update_cords()
	Sleep(200)
	If $currentXpos == 51 And $currentYpos == 51 Then
		close_npc_message_box()
		type_validation_code()
		Sleep(500)
	EndIf
	Local $currentSleep = Random(5, 20, 1) * 10
	While _ArraySearch($iLastSleep, $currentSleep) <> -1
		$currentSleep = Random(5, 20, 1) * 20
	WEnd
	$iLastSleep[$iSleepArrayIterator] = $currentSleep
	$iSleepArrayIterator = Mod($iSleepArrayIterator + 1, $iSleepArraySize)
	Sleep($currentSleep)
	ControlClick($hWnd, "", "XP2", "left")
	Sleep($currentSleep)
	$iRandomJumpCurrentIt = Mod($iRandomJumpCurrentIt + 1, $iRandomJumpFrequency)
	Local $goToPointX = ($pointsToGo[$goToPoint])[0]
	Local $goToPointY = ($pointsToGo[$goToPoint])[1]

	If($iRandomJumpCurrentIt == 0) Then
		random_jump($currentSleep)
		Sleep($currentSleep)
		;~ close_npc_message_box()
		;~ Sleep(500 + $currentSleep)
		ContinueLoop
	EndIf

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
		$goToPoint = Mod($goToPoint + 1 , UBound($pointsToGo))
	EndIf

	ConsoleWrite("Going to point: " & $goToPoint & " Cord X: " & $goToPointX & " Cord Y: " & $goToPointY & @CRLF)
	Sleep(300 + $currentSleep)
WEnd
EndFunc

; -8 on x; -8 on y
Func jump_up($currentSleep)
	jump(960 + Random(-30,30,1), 270 + Random(-30,30,1), $currentSleep)
EndFunc
; +8 on x; +8 on y
Func jump_down($currentSleep)
	jump(960 + Random(-30,30,1), 810 + Random(-30,30,1), $currentSleep)
EndFunc
; -7 on x; +8/+7 on y
Func jump_left($currentSleep)
	jump(480, 540, $currentSleep)
EndFunc
; +8 on x; -8 on y
Func jump_right($currentSleep)
	jump(1440, 540, $currentSleep)
EndFunc

Func jump_center($currentSleep)
	jump(960, 540, $currentSleep)
EndFunc

; -16 on y cord
Func jump_y_up($currentSleep)
	jump($iCenterPosX + 480 + Random(-60,0,1), $iCenterPosY - 270 + Random(0,60,1), $currentSleep)
EndFunc

; +16 on y cord
Func jump_y_down($currentSleep)
	jump($iCenterPosX - 480 + Random(0,60,1), $iCenterPosY + 270 + Random(-60,0,1), $currentSleep)
EndFunc

; -16 on x cord
Func jump_x_up($currentSleep)
	jump($iCenterPosX - 480 + Random(0,60,1), $iCenterPosY - 270 + Random(0,60,1), $currentSleep)
EndFunc

; +16 on x cord
Func jump_x_down($currentSleep)
	jump($iCenterPosX + 480 + Random(-60,0,1), $iCenterPosY + 270 + Random(-60,0,1), $currentSleep)
EndFunc

Func random_jump($currentSleep)
	jump(960 + Random(-562, 562, 1), 540 + Random(-260, 260, 1), $currentSleep)
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

Func jump($xCordClick, $yCordClick, $currentSleep)
	$iClickCounter = $iClickCounter + 1
	Sleep($currentSleep)
	;debug
	;~ ConsoleWrite("Cunter: " & $iClickCounter & @CRLF)
	$currentClickCountCycle = Mod($iClickCounter, 50)
	If($currentClickCountCycle > 46 ) Then
		ToolTip("Mouse will be taken in: " & 50 - $currentClickCountCycle)
	EndIf

	; anty bot jail protection - one real click after 99 jumps
	If $currentClickCountCycle == 0 Then
		ToolTip("Mouse will be taken in: 0")
		Local $currentMousePos = MouseGetPos()
		Sleep(20)
		WinSetOnTop($hWnd, "", $WINDOWS_ONTOP)
		MouseClick($MOUSE_CLICK_LEFT, 3857 + 50 , 689 + 50)
		ConsoleWrite("REAL CLICK AT: " & $iClickCounter & @CRLF)
		WinSetOnTop($hWnd, "", $WINDOWS_NOONTOP)
		MouseMove($currentMousePos[0], $currentMousePos[1] ,0)
		ToolTip("")
		Return
	EndIf
	
	Local $MK_CONTROL = 0x0008
	Local $MK_LBUTTON = 0x0001
	Local $lParam = _WinAPI_MakeLong($xCordClick, $yCordClick)
	
	_WinAPI_PostMessage($hWndControl, $WM_LBUTTONDOWN, $MK_CONTROL, $lParam)
	Sleep($currentSleep)
	$lParam = _WinAPI_MakeLong($currentSleep - 50, $currentSleep - 100)
	_WinAPI_PostMessage($hWndControl, $WM_LBUTTONUP, $MK_CONTROL, $lParam)

	; no bot ban
	;MouseClick($MOUSE_CLICK_LEFT, $xCordClick, $yCordClick)

EndFunc

Func scatter($xCordClick, $yCordClick)
	Local $wParam = 0x0008 ; hold ctrl
	Local $lParam = _WinAPI_MakeLong($xCordClick,$yCordClick)
	_SendMessage($hWndControl, $WM_RBUTTONDOWN, $wParam , $lParam)
	Sleep(Random(30, 80, 1))
	_SendMessage($hWndControl, $WM_RBUTTONUP, $wParam , $lParam)
EndFunc

Func update_cords()
	Capture_Window($hWnd, 292, 20, $sImageFilePath, 70, 170)
EndFunc

Func get_cords_in_loop()
	While 1
		Capture_Window($hWnd, 292, 20, $sImageFilePath, 70, 170)
		ToolTip("X: " & $currentXpos & " Y: " & $currentYpos)
		Sleep(500)
	WEnd
EndFunc

Func Capture_Entire_Window($hWnd, $sImageFilePath)
	Local $hDC_Capture = _WinAPI_GetDC($hWnd)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, 1920, 1080)
	_WinAPI_SelectObject($hMemDC, $hBitmap)
	_WinAPI_PrintWindow($hWnd, $hMemDC, False)
	_WinAPI_SaveHBITMAPToFile($sImageFilePath, $hBitmap)
EndFunc

Func crop_cords_from_image($sSourceImage, $sImageFilePathNew, $cropLeft, $cropRight, $cropTop, $cropBottom)
	_GDIPlus_Startup()
	$hImage = _GDIPlus_BitmapCreateFromFile($sSourceImage)
	;change format
	$iX = _GDIPlus_ImageGetWidth($hImage)
	$iY = _GDIPlus_ImageGetHeight($hImage)
	$hImageCropped = _GDIPlus_BitmapCloneArea($hImage, $cropLeft, $cropTop, $iX-$cropLeft-$cropRight, $iY-$cropTop-$cropBottom, $GDIP_PXF32ARGB)

	; replace cords text colors
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

	For $i = 1 To $iWidth * $iHeight
	  If $tPixel.color(($i)) <> 0xFFFFFFFF Then $tPixel.color(($i)) = 0xFF000000
	Next
	
	_GDIPlus_BitmapUnlockBits($hImageCropped, $tPixel)
	_GDIPlus_ImageSaveToFile($hImageCropped, $sImageFilePathNew)

	;delete gdi plus handles
	_GDIPlus_ImageAttributesDispose($hIA)
    _GDIPlus_ImageDispose($hImageCropped)
	_GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_ImageDispose($hImage)
    _GDIPlus_Shutdown()
	
EndFunc

Func Capture_Window($hWnd, $w, $h, $sImageFilePath, $cropLeft, $cropRight, $nTop = 0, $ResultTextPath = @ScriptDir & "\temp\cords")
    ;winapi part
	Local $hDC_Capture = _WinAPI_GetDC($hWnd)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $w, $h)
	_WinAPI_SelectObject($hMemDC, $hBitmap)
	_WinAPI_PrintWindow($hWnd, $hMemDC, False)

	;copy to gdi plus
	_GDIPlus_Startup()
	$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	
	;release all winapi handles
	_WinAPI_ReleaseDC($hWnd, $hDC_Capture)
	_WinAPI_DeleteObject($hDC_Capture)
	_WinAPI_DeleteDC($hMemDC)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hDC_Capture)
	
	;crop image
	$iX = _GDIPlus_ImageGetWidth($hImage)
	$iY = _GDIPlus_ImageGetHeight($hImage)
	$hImageCropped = _GDIPlus_BitmapCloneArea($hImage, $cropLeft, $nTop, $iX-$cropLeft-$cropRight, $iY-$nTop, $GDIP_PXF32ARGB)
	
	; replace cords text colors
    Local $hGraphics = _GDIPlus_ImageGetGraphicsContext($hImageCropped)
	Local $aRemapTable[3][2]
    $aRemapTable[0][0] = 2
    $aRemapTable[1][0] = 0xFF7F7F7F ;Old Color - letters shadow
    $aRemapTable[1][1] = 0xFF000000 ;New Color - letters shadow deleted 
    $aRemapTable[2][0] = 0xFFFFFF00 ;Old Color - letters color (yellow)
    $aRemapTable[2][1] = 0xFFFFFFFF ;New Color - letter color (white)
	Local $hIA = _GDIPlus_ImageAttributesCreate()
    _GDIPlus_ImageAttributesSetRemapTable($hIA, $aRemapTable)
	_GDIPlus_GraphicsDrawImageRectRect($hGraphics, $hImageCropped, 0, 0, $w, $h, 0, 0, $w, $h, $hIA)
	
	Local $iWidth = _GDIPlus_ImageGetWidth($hImageCropped)
	Local $iHeight = _GDIPlus_ImageGetHeight($hImageCropped)
	Local $tLock = _GDIPlus_BitmapLockBits($hImageCropped, 0, 0, $iWidth, $iHeight,  BitOR($GDIP_ILMWRITE, $GDIP_ILMREAD), $GDIP_PXF32ARGB)
	Local $tPixel = DllStructCreate("int color[" & $iWidth * $iHeight & "];", $tLock.scan0)

	For $i = 1 To $iWidth * $iHeight
	  If $tPixel.color(($i)) <> 0xFFFFFFFF Then $tPixel.color(($i)) = 0xFF000000
	Next
	
	_GDIPlus_BitmapUnlockBits($hImageCropped, $tPixel)
	_GDIPlus_ImageSaveToFile($hImageCropped, $sImageFilePath)
	
	;delete gdi plus handles
	_GDIPlus_ImageAttributesDispose($hIA)
    _GDIPlus_ImageDispose($hImageCropped)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_Shutdown()

	run_tesseract($ResultTextPath, $sImageFilePath)
	Sleep(150)
	read_cords_from_text_file($ResultTextPath)
EndFunc 

Func run_tesseract($ResultTextPath, $sImageFilePath)
	Local $TesseractExePath = "C:\Program Files\Tesseract-OCR\tesseract.exe"
	Local $iPID = Run($TesseractExePath & " " &  $sImageFilePath & " " & $ResultTextPath &" nobatch digits" , "" , @SW_HIDE, $RUN_CREATE_NEW_CONSOLE)
	StdioClose($iPID)
EndFunc

Func read_cords_from_text_file($ResultTextPath)
	Local $hFileOpen = FileOpen($ResultTextPath & ".txt", $FO_READ)
	If $hFileOpen = -1 Then
			ToolTip("An error occurred when reading the file. File Path: " & $ResultTextPath & ".txt", 30, 0)
			Return
	EndIf
	Local $sOutput = FileRead($hFileOpen)
	FileClose($hFileOpen)
	Local $sOutputClean = StringReplace($sOutput, ".", "")
	$sOutputClean = StringReplace($sOutputClean, @LF, "")
	If StringLen($sOutputClean) == 6 Then
		$currentXpos = Number(StringLeft($sOutputClean, 3))
		$currentYpos = Number(StringRight($sOutputClean, 3))
		;for debugging position processing
		;ToolTip("Position x: " & $currentXpos  & @CRLF & "Position y: " & $currentYpos, 0, 30, "Raw position in game: " & $sOutput)
	;~ Else
		;~ ToolTip("Not found ", 0, 30, "Position not found" & StringLen($sOutput))
	EndIf
EndFunc

Func exit_get_window_handles()
	AutoItSetOption("MouseCoordMode", 1)
	ToolTip("")
	$iContinueGetHandles = False
EndFunc

Func get_window_handles()
	$iContinueGetHandles = True
	While $iContinueGetHandles
		AutoItSetOption("MouseCoordMode", 1)
		$a_info = mouse_Win_GetInfo()
		If @error Then Exit
		AutoItSetOption("MouseCoordMode", 2)
		Local $relativeMousePos = MouseGetPos()
		$hWnd = $a_info[0]
		$hWndControl = $a_info[1]
		ToolTip("Window hwnd = " & $a_info[0] & @CRLF & _
			"Window ID = " & _WinAPI_GetDlgCtrlID($a_info[0]) & @CRLF & _
			"Control hwnd = " & $a_info[1] & @CRLF & _
			"Control ID = " & _WinAPI_GetDlgCtrlID($a_info[1]) & @CRLF & _
			"Window Title = " & $a_info[2] & @CRLF & _
			"Control Title = " & WinGetTitle($a_info[1]) & @CRLF & _
			"Mouse X Pos global = " & $a_info[3] & @CRLF & _
			"Mouse Y Pos global = " & $a_info[4] & @CRLF & _
			"Mouse X Pos control = " & MouseGetPos()[0] & @CRLF & _
			"Mouse Y Pos control = " & MouseGetPos()[1])
		Sleep(500)
	WEnd
EndFunc

Func mouse_Win_GetInfo()
	Local $a_mpos = MouseGetPos()
	If @error Then Return SetError(1, 0, 0)
	Local $a_wfp = DllCall("user32.dll", "hwnd", "WindowFromPoint", "long", $a_mpos[0], "long", $a_mpos[1])
	If @error Then Return SetError(2, 0, 0)
	Local $a_ga = DllCall("user32.dll", "hwnd", "GetAncestor", "hwnd", $a_wfp[0], "int", 3); $GW_ROOTOWNER = 3
	If @error Then Return SetError(3, 0, 0)
	Local $a_ret[5] = [$a_ga[0], $a_wfp[0], WinGetTitle($a_ga[0]), $a_mpos[0], $a_mpos[1]]
	;~ for debug
	;~ ConsoleWrite("a_ga: " & _ArrayToString($a_ga) & @CRLF)
	;~ ConsoleWrite("a_wfp: " & _ArrayToString($a_wfp) & @CRLF)
	Return $a_ret
EndFunc

Func obtain_move_points()
	Local $qKeyPressed = "51"
	Local $enterButtonPressed = "0D"
	Local $currentPoint = 0
	Local $redrawTooltip = 0
	Do
		Capture_Window($hWnd, 292, 20, $sImageFilePath, 70, 170)
		If(Mod($redrawTooltip, 10) == 0) Then
			ToolTip("Press Enter to set a travel point: " & $currentPoint + 1 & @CRLF & _
					"Press Q to finish")
		EndIf

		If(_IsPressed($enterButtonPressed)) Then
			ReDim $pointsToGo[$currentPoint + 1]
			Local $newPoint = [$currentXpos, $currentYpos]
			$pointsToGo[$currentPoint] = $newPoint
			ConsoleWrite("Set point: " & $currentPoint + 1 & " at: " & _ArrayToString($pointsToGo[$currentPoint]) & @CRLF)
			$currentPoint += 1
			While _IsPressed($enterButtonPressed)
				Sleep(10)
			WEnd
		EndIf
		Sleep(10)
		$redrawTooltip += 1
	Until _IsPressed($qKeyPressed)
	ToolTip("")
EndFunc

Func close_npc_message_box()
	ControlClick($hWnd, "", "C")
EndFunc

Func exit_bot()
	ToolTip("")
	Exit
EndFunc
