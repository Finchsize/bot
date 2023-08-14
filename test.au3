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

HotKeySet("^t", "start_hunt")
HotKeySet("^q", "exit_bot")
HotKeySet("^m", "get_cords_in_loop")
HotKeySet("^i", "get_window_handles")
HotKeySet("!i", "exit_get_window_handles")
HotKeySet("^p", "obtain_move_points")

Global $iContinueGetHandles = True
Global $iIsInBotCheck = False

$hWnd = 0x004D1344
$hWndControl = 0x000E063C
$currentXpos = 0;
$currentYpos = 0;
$sImageFileExtenstion = ".tiff";
$sImageFilePath = @ScriptDir & "\temp\cords" & $sImageFileExtenstion
; hControlPositions
$iCenterPosX = 960
$iCenterPosY = 540

$iClickCounter = 0

; current global
$iCenterPosX_global = 3857
$iCenterPosY_global = 689

; tc robins
;~ Local $leftTop[2] = [411, 713]
;~ Local $rightTop[2] = [524, 675]
;~ Local $leftBottom[2] = [451, 791]
;~ Local $rightBottom[2] = [616, 762]

; ape
Local $leftTop[2] = [610, 669]
Local $rightTop[2] = [693, 561]
Local $leftBottom[2] = [618, 754]
Local $rightBottom[2] = [803, 621]

Local $pointsToGo[4] = [$leftTop, $rightBottom, $rightTop, $leftBottom]

While 1
	Sleep(20 + Random(1, 10, 1))
WEnd

Func start_hunt()
	Local $goToPoint = 0
	Local $iArraySize = 15;
	Local $iArrayIterator = 0;
	Local $iLastSleep[$iArraySize]
	Local $preferXJump = True;
	Local $JumpOccured = False
While 1
	update_cords()
	Local $currentSleep = Random(5, 20, 1) * 20
	While _ArraySearch($iLastSleep, $currentSleep) <> -1
		$currentSleep = Random(5, 20, 1) * 20
		;ConsoleWrite("Rolled sleep: " & $currentSleep & @CRLF)
	WEnd
	$iLastSleep[$iArrayIterator] = $currentSleep
	$iArrayIterator = Mod($iArrayIterator + 1, $iArraySize)

	Local $begin = TimerInit()
	If $currentXpos == 051 And $currentYpos == 051 Then
		$iIsInBotCheck = True
		ExitLoop
	EndIf

	If ($currentXpos - 16 > ($pointsToGo[$goToPoint])[0] And $preferXJump) Then
		jump_x_up($currentSleep)
		$YJumpOccured = True
	ElseIf ($currentXpos + 16 < ($pointsToGo[$goToPoint])[0] And $preferXJump) Then
		jump_x_down($currentSleep)
		$YJumpOccured = True
	ElseIf ($currentYpos - 16 > ($pointsToGo[$goToPoint])[1]) Then
		jump_y_up($currentSleep)
		$JumpOccured = True
	ElseIf ($currentYpos + 16 < ($pointsToGo[$goToPoint])[1]) Then
		jump_y_down($currentSleep)
		$YJumpOccured = True
	ElseIf(Not $JumpOccured And $preferXJump) Then
		$goToPoint = Mod($goToPoint + 1 , 4)
	EndIf
	$preferXJump = Not $preferXJump
	$JumpOccured = False;
	ConsoleWrite("Going to point: " & $goToPoint & @CRLF)
	Sleep(Mod($currentSleep, 10))
	random_scatter()
	Sleep(1350 + $currentSleep)
	;debug
	;ConsoleWrite("Last sleep array: " & _ArrayToString($iLastSleep) & " Current sleep: " & $currentSleep & @CRLF)
	;ConsoleWrite("Hunt one cycle execution time (without wait): " & TimerDiff($begin) & @CRLF);
WEnd
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

Func random_scatter()
	scatter($iCenterPosX + Random(-50, 50, 1), $iCenterPosY + Random(-50, 50, 1))
EndFunc

; +8 on x; -8 on y
Func jump_right($currentSleep)
	jump(1440, 540, $currentSleep)
EndFunc
; -7 on x; +8/+7 on y
Func jump_left($currentSleep)
	jump(480, 540, $currentSleep)
EndFunc
; -8 on x; -8 on y
Func jump_up($currentSleep)
	jump(960, 270, $currentSleep)
EndFunc
; +8 on x; +8 on y
Func jump_down($currentSleep)
	jump(960, 810, $currentSleep)
EndFunc

Func jump_center($currentSleep)
	jump(960, 540, $currentSleep)
EndFunc

Func jump($xCordClick, $yCordClick, $currentSleep)
	$iClickCounter = $iClickCounter + 1
	Sleep($currentSleep)
	;debug
	ConsoleWrite("Cunter: " & $iClickCounter & @CRLF)
	$currentClickCountCycle = Mod($iClickCounter, 100)
	If($currentClickCountCycle > 96 ) Then
		ToolTip("Mouse will be taken in: " & 100 - $currentClickCountCycle)
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
	_SendMessage($hWndControl, $WM_RBUTTONUP, $wParam , $lParam)
EndFunc

Func update_cords()
	Capture_Window($hWnd, 292, 20, $sImageFilePath)
EndFunc

Func get_cords_in_loop()
	While 1
		Capture_Window($hWnd, 292, 20, $sImageFilePath)
		ToolTip("X: " & $currentXpos & " Y: " & $currentYpos)
		Sleep(500)
	WEnd
EndFunc

Func Capture_Window($hWnd, $w, $h, $sImageFilePath)
	;for debug
	$begin = TimerInit()

	;capture cords
    ;winapi part
	Local $hDC_Capture = _WinAPI_GetDC($hWnd)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $w, $h)
	_WinAPI_SelectObject($hMemDC, $hBitmap)
	_WinAPI_PrintWindow($hWnd, $hMemDC, False)
	$afterWinApi = TimerInit()
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
	$cropLeft = 70
	$cropRight = 170
	$hImageCropped = _GDIPlus_BitmapCloneArea($hImage, $cropLeft, 0, $iX-$cropLeft-$cropRight, $iY, $GDIP_PXF32ARGB)
	
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
	
	;delete gdu plus handles
	_GDIPlus_ImageAttributesDispose($hIA)
    _GDIPlus_ImageDispose($hImageCropped)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hGraphics)
    _GDIPlus_Shutdown()

	Local $ResultTextPath = @ScriptDir & "\temp\cords"
	read_cords_from_text_file($ResultTextPath)
	run_tesseract($ResultTextPath)
	;for debug
	;ConsoleWrite("Function Capture_Window execution time: " & TimerDiff($begin) & @CRLF);
	;ConsoleWrite("Function Capture_Window execution time: " & TimerDiff($afterWinApi) & @CRLF);
	
EndFunc 

Func run_tesseract($ResultTextPath)
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
		$currentXpos = StringLeft($sOutputClean, 3)
		$currentYpos = StringRight($sOutputClean, 3)
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
		If ($iIsInBotCheck) Then
			ConsoleWrite("Window hwnd = " & $a_info[0] & @CRLF & _
			"Control hwnd = " & $a_info[1] & @CRLF & _
			"Window Title = " & $a_info[2] & @CRLF & _
			"Control Title = " & WinGetTitle($a_info[1]) & @CRLF & _
			"Mouse X Pos global = " & $a_info[3] & @CRLF & _
			"Mouse Y Pos global = " & $a_info[4] & @CRLF & _
			"Mouse X Pos control = " & MouseGetPos()[0] & @CRLF & _
			"Mouse Y Pos control = " & MouseGetPos()[1])
		EndIf
		ToolTip("Window hwnd = " & $a_info[0] & @CRLF & _
			"Control hwnd = " & $a_info[1] & @CRLF & _
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

Func exit_bot()
	Exit
EndFunc

Func obtain_move_points()
	Local $qKeyPressed = "51"
	Local $enterButtonPressed = "0D"
	Local $currentPoint = 0
	Local $redrawTooltip = 0
	Do
		Capture_Window($hWnd, 292, 20, $sImageFilePath)
		If(Mod($redrawTooltip, 10) == 0) Then
			ToolTip("Press Enter to set a travel point: " & $currentPoint + 1 & @CRLF & _
					"Press Q to finish")
		EndIf

		If(_IsPressed($enterButtonPressed)) Then
			ReDim $pointsToGo[$currentPoint + 1]
			Local $newPoint = [$currentXpos, $currentXpos]
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

Func anty_bot_click()

EndFunc
