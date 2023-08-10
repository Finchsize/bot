#include <SendMessage.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIConv.au3>
#include <WinAPIGdi.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <WinAPIFiles.au3>

HotKeySet("t", "start_hunt")
HotKeySet("q", "exit_bot")
HotKeySet("m", "get_cords_in_loop")
HotKeySet("w", "jump_up")
HotKeySet("a", "jump_left")
HotKeySet("d", "jump_right")
HotKeySet("s", "jump_down")
HotKeySet("p", "jump_center")
HotKeySet("r", "random_jump")

$hWnd = 0x000C063C
$hWndControl = 0x000C013E0
$currentXpos = 0;
$currentYpos = 0;
$sImageFileExtenstion = ".tiff";
$sImageFilePath = @ScriptDir & "\temp\cords" & $sImageFileExtenstion

While 1
	Sleep(20 + Random(1, 10, 1))
WEnd

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
	;jump(960+720, 540) left/right jump close to max range
	;jump(960, 540-370) up/down jump close to max range
	;jump(960+562, 540-260) diagonal jump ABSOLUTE max
	While 1
		Sleep(200 + Random(0, 300, 1))
		jump(960 + Random(-562, 562, 1), 540 + Random(-260, 260, 1))
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
	$begin = TimerInit()
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
	ConsoleWrite("Function Capture_Window execution time: " & TimerDiff($begin) & @CRLF);
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