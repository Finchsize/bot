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

HotKeySet("^t", "start_hunt")
HotKeySet("^q", "exit_bot")
HotKeySet("^m", "get_cords_in_loop")
HotKeySet("^p", "jump_center")
HotKeySet("^r", "random_jump")
HotKeySet("^i", "get_window_handles")
HotKeySet("!i", "exit_get_window_handles")

Global $iContinueGetHandles = True
Global $iIsInBotCheck = False

$hWnd = 0x004D1344
$hWndControl = 0x000E063C
$currentXpos = 0;
$currentYpos = 0;
$sImageFileExtenstion = ".tiff";
$sImageFilePath = @ScriptDir & "\temp\cords" & $sImageFileExtenstion

While 1
	Sleep(20 + Random(1, 10, 1))
WEnd

Func exit_get_window_handles()
	ToolTip("")
	$iContinueGetHandles = False
EndFunc

Func get_window_handles()
	$iContinueGetHandles = True
	While $iContinueGetHandles
		AutoItSetOption("MouseCoordMode", 1)
		$a_info = _Mouse_Win_GetInfo()
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
			"Mouse X Pos control = " & MouseGetPos()[1])
		EndIf
		ToolTip("Window hwnd = " & $a_info[0] & @CRLF & _
			"Control hwnd = " & $a_info[1] & @CRLF & _
			"Window Title = " & $a_info[2] & @CRLF & _
			"Control Title = " & WinGetTitle($a_info[1]) & @CRLF & _
			"Mouse X Pos global = " & $a_info[3] & @CRLF & _
			"Mouse Y Pos global = " & $a_info[4] & @CRLF & _
			"Mouse X Pos control = " & MouseGetPos()[0] & @CRLF & _
			"Mouse X Pos control = " & MouseGetPos()[1])
		Sleep(500)
	WEnd
EndFunc

Func _Mouse_Win_GetInfo()
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

Func start_hunt()
	Local $isGoingLeft = true;
While 1
	Sleep(1000 + Random(10, 500, 1))
	update_cords()

	;random jump and cyclone
	If Random(1, 3, 1) == 3 Then
		random_jump()
		ContinueLoop
	EndIf

	If($isGoingLeft) Then
		jump_left()
	Else
		jump_right()
	EndIf

	If $currentXpos > 900 AND $currentYpos > 550 Then
		$isGoingLeft = True
	EndIf
	ConsoleWrite("isGoingLeftLeft: " & $isGoingLeft & @CRLF)

	If $currentXpos < 630 And $currentYpos > 840 Then
		$isGoingLeft = False
	EndIf
	ConsoleWrite("isGoingLeftLeft: " & $isGoingLeft & @CRLF)

WEnd
EndFunc

Func random_jump()
	While 1
		Sleep(850 + Random(0, 50, 1))
		Local $begin = TimerInit()
		update_cords()
		If $currentXpos == 051 And $currentYpos == 051 Then
			$iIsInBotCheck = True
			ExitLoop
		EndIf
		jump(960 + Random(-562, 562, 1), 540 + Random(-260, 260, 1))
		;random scatter
		Sleep(100 + Random(10, 100, 1))
		scatter(960 + Random(-562, 562, 1), 540 + Random(-260, 260, 1))
		ConsoleWrite("One random jump execution time: " & TimerDiff($begin) & @CRLF);
		;ConsoleWrite("Random jump executed!" & @CRLF)
	WEnd
EndFunc

Func jump_right()
	jump(1440, 540)
	;jump(1274 + Random(0, 200, 1), 637 + Random(0, 200, 1))
	;Sleep(100 + Random(0, 50, 1))
	;scatter(1274 + Random(0, 120, 1), 637 + Random(0, 120, 1))
EndFunc

Func jump_left()
	jump(480, 540)
	;jump(675 - Random(0, 200, 1), 661 + Random(0, 200, 1))
	;Sleep(100 + Random(0, 50, 1))
	;scatter(675 + Random(0, 120, 1), 661 + Random(0, 120, 1))
EndFunc

Func jump_up()
	jump(960, 270)
EndFunc

Func jump_down()
	jump(960, 810)
EndFunc

func jump_center()
	jump(960, 540)
EndFunc

Func jump($xCordClick, $yCordClick)
	Local $wParam = 0x0008 ; hold ctrl
	Local $lParam = _WinAPI_MakeLong($xCordClick,$yCordClick)
	_SendMessage($hWndControl, $WM_LBUTTONDOWN, $wParam, $lParam)
	_SendMessage($hWndControl, $WM_LBUTTONUP, $wParam, $lParam)
EndFunc

Func scatter($xCordClick, $yCordClick)
	Local $lParam = _WinAPI_MakeLong($xCordClick,$yCordClick)
	_SendMessage($hWndControl, $WM_RBUTTONDOWN, 0 , $lParam)
	_SendMessage($hWndControl, $WM_RBUTTONUP, 0 , $lParam)
EndFunc

Func update_cords()
	Capture_Window($hWnd, 292, 20, $sImageFilePath)
EndFunc

Func get_cords_in_loop()
	While 1
		Capture_Window($hWnd, 292, 20, $sImageFilePath)
		Sleep(500)
	WEnd
EndFunc

Func Capture_Window($hWnd, $w, $h, $sImageFilePath)
	;for debug
	;$begin = TimerInit()

	;capture cords
    _GDIPlus_Startup()
	Local $hDC_Capture = _WinAPI_GetDC($hWnd)
	Local $hMemDC = _WinAPI_CreateCompatibleDC($hDC_Capture)
	Local $hBitmap = _WinAPI_CreateCompatibleBitmap($hDC_Capture, $w, $h)
	Local $hObject = _WinAPI_SelectObject($hMemDC, $hBitmap)
	_WinAPI_PrintWindow($hWnd, $hMemDC)
	$hImage = _GDIPlus_BitmapCreateFromHBITMAP($hBitmap)
	
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
	Local	$iHeight = _GDIPlus_ImageGetHeight($hImageCropped)
	Local $tLock = _GDIPlus_BitmapLockBits($hImageCropped, 0, 0, $iWidth, $iHeight,  BitOR($GDIP_ILMWRITE, $GDIP_ILMREAD), $GDIP_PXF32ARGB)
	Local $tPixel = DllStructCreate("int color[" & $iWidth * $iHeight & "];", $tLock.scan0)

	For $i = 1 To $iWidth * $iHeight
	  If $tPixel.color(($i)) <> 0xFFFFFFFF Then $tPixel.color(($i)) = 0xFF000000
	Next
	
	;unlock and save
	_GDIPlus_BitmapUnlockBits($hImageCropped, $tPixel)
	_GDIPlus_ImageSaveToFile($hImageCropped, $sImageFilePath)
	
	;delete handles
	_WinAPI_DeleteDC($hMemDC)
	_WinAPI_ReleaseDC($hWnd, $hDC_Capture)
	_WinAPI_DeleteObject($hBitmap)
    _GDIPlus_ImageDispose($hImageCropped)
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_ImageDispose($hGraphics)
    _GDIPlus_Shutdown()

	Local $ResultTextPath = @ScriptDir & "\temp\cords"
	read_cords_from_text_file($ResultTextPath)
	run_tesseract($ResultTextPath)
	;for debug
	;ConsoleWrite("Function Capture_Window execution time: " & TimerDiff($begin) & @CRLF);
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
		ToolTip("Position x: " & $currentXpos  & @CRLF & "Position y: " & $currentYpos, 0, 30, "Raw position in game: " & $sOutput)
	Else
		ToolTip("Not found ", 0, 30, "Position not found" & StringLen($sOutput))
	EndIf
EndFunc

Func exit_bot()
	Exit
EndFunc