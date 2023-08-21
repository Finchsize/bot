#include <GDIPlus.au3>
#include <array.au3>


;~ While 1
;~ 	Sleep(20)
	perform_ocr()
	ConsoleWrite(@CRLF)
	Exit
;~ WEnd


Func perform_ocr()
	_GDIPlus_Startup()

	$filePath = "C:\Users\danie\Desktop\Cords_ss\cords_from_loop_cropped26.tiff"
	Local $hImage = _GDIPlus_BitmapCreateFromFile($filePath)
	Local $iX = _GDIPlus_ImageGetWidth($hImage)
	Local $iY = _GDIPlus_ImageGetHeight($hImage)
	Local $hImageConverted = _GDIPlus_BitmapCloneArea($hImage, 0, 0, $iX, $iY, $GDIP_PXF32ARGB)

	Local $iWidth = _GDIPlus_ImageGetWidth($hImageConverted)
	Local $iHeight = _GDIPlus_ImageGetHeight($hImageConverted)
	Local $tLock = _GDIPlus_BitmapLockBits($hImageConverted, 0, 0, $iWidth, $iHeight,  $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $iScan0 = DllStructGetData($tLock, "Scan0") ;get scan0 (pixel data) from locked bitmap
	Local $tPixel = DllStructCreate("int color[" & $iWidth * $iHeight & "];", $iScan0)

	ConsoleWrite("Width: " & $iWidth & " Heigh: " & $iHeight & @CRLF)

	; put colors from 1D array into 2D array
	Local $pixelColors[$iHeight][$iWidth]
	Local $colIndex = 0
	Local $rowIndex = 0
	; $tPixel.color for some reason starts from 1 ...
	For $i = 1 To $iWidth * $iHeight
		Local $pixelColor = $tPixel.color(($i))
		$pixelColors[$rowIndex][$colIndex] = $pixelColor
		$colIndex += 1
		If (Mod($i, $iWidth) == 0) Then
			$rowIndex += 1
			$colIndex = 0
		EndIf
	Next

	; show array
	For $rowIndex = 0 To UBound($pixelColors, $UBOUND_ROWS) - 1 Step +1
		For $colIndex = 0 To UBound($pixelColors, $UBOUND_COLUMNS) - 1 Step +1
			Local $isBlack = Int($pixelColors[$rowIndex][$colIndex] == 0xFF000000)
			If ($isBlack == 0) Then
				ConsoleWrite("O ")
			Else
				ConsoleWrite(". ")
			EndIf
		Next
		ConsoleWrite(@CRLF)
	Next

	ConsoleWrite(@CRLF)

	Local $digitMarginLeft = 1
	Local $digitMarginRight = 1
	Local $digitMaxWidth = 5
	Local $digitWidthCombined = 7
	Local $result[6]
	Local $commaStartedAtIndex = 0

	; skip first row start with 1 there are only black pixels there
	For $rowIndex = 1 To UBound($pixelColors, $UBOUND_ROWS) - 1 Step +1
		For $colIndex = 0 To UBound($pixelColors, $UBOUND_COLUMNS) - 1 Step +1
			Local $currentPixelOfDigit = Mod($colIndex, $digitWidthCombined)
			If($commaStartedAtIndex <> 0 And $colIndex > $commaStartedAtIndex) Then
				$currentPixelOfDigit = Mod($colIndex + 4, $digitWidthCombined) ; TODO Dynamic comma size. AND why 4 ?! Currently Comma has 1 column + 1 margin on left + 1 margin on right
			EndIf
			; skip margin pixels
			If ($currentPixelOfDigit <= $digitMarginLeft - 1 Or $currentPixelOfDigit >= $digitWidthCombined - $digitMarginRight) Then
				ContinueLoop
			EndIf
			Local $isBlack = $pixelColors[$rowIndex][$colIndex] == 0xFF000000
			; skip comma and its margin - check the bottom pixel of given column to find it ($iHeight - 1  -> max for row Index)
			If ($colIndex <> 0 And $colIndex <> $iWidth - 1 _ ; don't check first and last cols - they can't be commas
				And ( _
					$pixelColors[$iHeight - 1][$colIndex + 1] == 0xFFFFFFFF _ ; remove left comma margin
					Or $pixelColors[$iHeight - 1][$colIndex] == 0xFFFFFFFF _ ; remove comma itself
					Or $pixelColors[$iHeight - 1][$colIndex - 1] == 0xFFFFFFFF _ ; remove right comma margin
					) _
				) Then
				If ($commaStartedAtIndex == 0) Then $commaStartedAtIndex = $colIndex
				ContinueLoop
			EndIf

			Local $isBlack = Int($pixelColors[$rowIndex][$colIndex] == 0xFF000000)
			If (Not $isBlack) Then
				ConsoleWrite("O ")
			Else
				ConsoleWrite(". ")
			EndIf
		Next
		ConsoleWrite(@CRLF)
	Next


	;clean handles etc
	;~ _GDIPlus_ImageAttributesDispose($hIA)
    _GDIPlus_ImageDispose($hImageConverted)
	;~ _GDIPlus_GraphicsDispose($hGraphics)
	_GDIPlus_ImageDispose($hImage)
    _GDIPlus_Shutdown()
EndFunc