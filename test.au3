#include <SendMessage.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIConv.au3>
#include <WinAPIGdi.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>

HotKeySet("t", "jump");
HotKeySet("q", "exit_bot");
HotKeySet("m", "get_cords");

$hWnd = 0x0033083A
$hWndControl = 0x0063308
$currentXpos = 0;
$currentYpos = 0;

While 1
	Sleep(200)
WEnd

Func start_hunt()

EndFunc

Func jump()
	Sleep(50)
	Local $xCordClick = 791
	Local $yCordClick = 289
	Local $wParam = 0x0008 ; hold ctrl
	Local $lParam = _WinAPI_MakeLong($xCordClick,$yCordClick)
	_SendMessage($hWndControl, $WM_LBUTTONDOWN, $wParam, $lParam)
	_SendMessage($hWndControl, $WM_LBUTTONUP, $wParam, $lParam)
EndFunc

Func get_cords()
		Local $sImageFileExtenstion = ".tiff";
		Local $sImageFilePath = @ScriptDir & "\temp\cords" & $sImageFileExtenstion
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
	
	
	;tesseract
	Local $TesseractExePath = "C:\Program Files\Tesseract-OCR\tesseract.exe"
	$ResultTextPath = @ScriptDir & "\out"
	Local $iPID = Run($TesseractExePath & " " &  $sImageFilePath & " stdout nobatch digits" , "" , @SW_HIDE, $STDERR_MERGED)
	Local $sOutput = ""
	Local $retries = 0;
	Do
		If $retries > 30 Then ExitLoop
		$retries += 1
		Sleep(10)
		$sOutput &= StdoutRead($iPID)
	Until @error
	
	ProcessClose($iPID)
	
	Local $sOutputClean = StringReplace($sOutput, ".", "")
	;Todo better trim right - need to remove white space and new line
	$sOutputClean = StringTrimRight($sOutputClean, 2);
	If StringLen($sOutputClean) == 6 Then
		Local $sCordX = StringLeft($sOutputClean, 3)
		Local $sCordY = StringRight($sOutputClean, 3)
		ToolTip("Position x: " & $sCordX  & @CRLF & "Position y: " & $sCordY, 0, 30, "Raw position in game: " & $sOutput)
	Else
		ToolTip("Not found ", 0, 30, "Position not found" & StringLen($sOutput))
	EndIf
	
	ConsoleWrite("Function Capture_Window execution time: " & TimerDiff($begin) & @CRLF);
EndFunc 

Func exit_bot()
	Exit
EndFunc