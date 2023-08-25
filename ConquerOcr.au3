#include <GDIPlus.au3>
#include <array.au3>

Func compare_images($filePath_1, $filePath_2)
	Local $begin = TimerInit()

	_GDIPlus_Startup()
	Local $hImage_1 = _GDIPlus_BitmapCreateFromFile($filePath_1)
	Local $iX_1 = _GDIPlus_ImageGetWidth($hImage_1)
	Local $iY_1 = _GDIPlus_ImageGetHeight($hImage_1)
	Local $hImageConverted_1 = _GDIPlus_BitmapCloneArea($hImage_1, 0, 0, $iX_1, $iY_1, $GDIP_PXF32ARGB)

	Local $iWidth_1 = _GDIPlus_ImageGetWidth($hImageConverted_1)
	Local $iHeight_1 = _GDIPlus_ImageGetHeight($hImageConverted_1)
	Local $tLock_1 = _GDIPlus_BitmapLockBits($hImageConverted_1, 0, 0, $iWidth_1, $iHeight_1,  $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $iScan0_1 = DllStructGetData($tLock_1, "Scan0") ;get scan0 (pixel data) from locked bitmap
	Local $tPixel_1 = DllStructCreate("int color[" & $iWidth_1 * $iHeight_1 & "];", $iScan0_1)

	Local $hImage_2 = _GDIPlus_BitmapCreateFromFile($filePath_2)
	Local $iX_2 = _GDIPlus_ImageGetWidth($hImage_2)
	Local $iY_2 = _GDIPlus_ImageGetHeight($hImage_2)
	Local $hImageConverted_2 = _GDIPlus_BitmapCloneArea($hImage_2, 0, 0, $iX_2, $iY_2, $GDIP_PXF32ARGB)

	Local $iWidth_2 = _GDIPlus_ImageGetWidth($hImageConverted_2)
	Local $iHeight_2 = _GDIPlus_ImageGetHeight($hImageConverted_2)
	Local $tLock_2 = _GDIPlus_BitmapLockBits($hImageConverted_2, 0, 0, $iWidth_2, $iHeight_2,  $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $iScan0_2 = DllStructGetData($tLock_2, "Scan0") ;get scan0 (pixel data) from locked bitmap
	Local $tPixel_2 = DllStructCreate("int color[" & $iWidth_2 * $iHeight_2 & "];", $iScan0_2)

	Local $result = True

	For $i = 1 To $iWidth_1 * $iHeight_1
		If $tPixel_1.color(($i)) <> $tPixel_2.color(($i)) Then
			$result = False
			ExitLoop
		EndIf
	Next

	_GDIPlus_BitmapUnlockBits($hImageConverted_1, $tLock_1)
	_GDIPlus_BitmapUnlockBits($hImageConverted_1, $tPixel_1)
    _GDIPlus_ImageDispose($hImageConverted_1)
	_GDIPlus_ImageDispose($hImage_1)

	_GDIPlus_BitmapUnlockBits($hImageConverted_2, $tLock_2)
	_GDIPlus_BitmapUnlockBits($hImageConverted_2, $tPixel_2)
    _GDIPlus_ImageDispose($hImageConverted_2)
	_GDIPlus_ImageDispose($hImage_2)

    _GDIPlus_Shutdown()

	Return $result
EndFunc

Func perform_ocr($filePath)

	_GDIPlus_Startup()

	Local $hImage = _GDIPlus_BitmapCreateFromFile($filePath)
	Local $iX = _GDIPlus_ImageGetWidth($hImage)
	Local $iY = _GDIPlus_ImageGetHeight($hImage)
	Local $hImageConverted = _GDIPlus_BitmapCloneArea($hImage, 0, 0, $iX, $iY, $GDIP_PXF32ARGB)

	Local $iWidth = _GDIPlus_ImageGetWidth($hImageConverted)
	Local $iHeight = _GDIPlus_ImageGetHeight($hImageConverted)
	Local $tLock = _GDIPlus_BitmapLockBits($hImageConverted, 0, 0, $iWidth, $iHeight,  $GDIP_ILMREAD, $GDIP_PXF32ARGB)
	Local $iScan0 = DllStructGetData($tLock, "Scan0") ;get scan0 (pixel data) from locked bitmap
	Local $tPixel = DllStructCreate("int color[" & $iWidth * $iHeight & "];", $iScan0)

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

	;clean handles etc
	_GDIPlus_BitmapUnlockBits($hImageConverted, $tLock)
	_GDIPlus_BitmapUnlockBits($hImageConverted, $tPixel)
    _GDIPlus_ImageDispose($hImageConverted)
	_GDIPlus_ImageDispose($hImage)
    _GDIPlus_Shutdown()

	Local $digitMarginLeft = 1
	Local $digitMarginRight = 1
	Local $digitMaxWidth = 5
	Local $digitWidthCombined = 7
	Local $result[0]
	Local $commaStartedAtIndex = 0
	Local $rowIndex = 1 ; only first row is needed to find all digits

	For $colIndex = 0 To UBound($pixelColors, $UBOUND_COLUMNS) - 1 Step +1
		
		; set current digit position
		Local $currentPixelOfDigit = Mod($colIndex, $digitWidthCombined)
		Local $currentIndexOfDigit = Int($colIndex / $digitWidthCombined)

		; do adjustments due to comma in string
		If($commaStartedAtIndex <> 0 And $colIndex > $commaStartedAtIndex) Then
			$currentPixelOfDigit = Mod($colIndex + 4, $digitWidthCombined)
			Local $currentIndexOfDigit = Int(($colIndex - 4) / $digitWidthCombined)
		EndIf

		; skip margin pixels
		If ($currentPixelOfDigit <= $digitMarginLeft - 1 Or $currentPixelOfDigit >= $digitWidthCombined - $digitMarginRight) Then
			ContinueLoop
		EndIf

		; check if current pixel is black or white
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

		; find 0
		If ($currentPixelOfDigit == 1 And $isBlack _ ; 1st black pixel
			And $pixelColors[$rowIndex][$colIndex + 1] == 0xFFFFFFFF _ ; 2nd white pixel
			And $pixelColors[$rowIndex][$colIndex + 2] == 0xFFFFFFFF _ ; 3rd white pixel
			And $pixelColors[$rowIndex][$colIndex + 3] == 0xFFFFFFFF _ ; 4rd white pixel
			And $pixelColors[$iHeight - 4][$colIndex] == 0xFFFFFFFF _ ; check pixel in left column to eliminate number 9 and 3
			And $pixelColors[$iHeight - 6][$colIndex + 1] == 0xFF000000 _ ; check pixel to eliminate number 6 and 8
			And $rowIndex == 1 _; this check is only for first row
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 0
		EndIf

		; find 1
		If ($currentPixelOfDigit == 3 And Not $isBlack _ ; 3rd white pixel
				And $pixelColors[$rowIndex][$colIndex - 1] == 0xFF000000 _ ; black on left side
				And $pixelColors[$rowIndex][$colIndex + 1] == 0xFF000000 _ ; black on right side
				And $rowIndex == 1 _; this check is only for first row
				) Then
				Redim $result[UBound($result) + 1]
				$result[$currentIndexOfDigit] = 1
		EndIf

		; find 2
		If ($currentPixelOfDigit == 1 And $isBlack _ ; 1st black pixel
			And $pixelColors[$rowIndex][$colIndex + 1] == 0xFFFFFFFF _ ; 2nd white pixel
			And $pixelColors[$rowIndex][$colIndex + 2] == 0xFFFFFFFF _ ; 3rd white pixel
			And $pixelColors[$rowIndex][$colIndex + 3] == 0xFFFFFFFF _ ; 4rd white pixel
			And $pixelColors[$iHeight - 2][$colIndex] == 0xFFFFFFFF _ ; left bottom corner is white pixel
			And $rowIndex == 1 _; this check is only for first row
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 2
		EndIf

		; find 3
		If ($rowIndex == 1 _; this check is only for first row
			And $currentPixelOfDigit == 1 And $isBlack _ ; 1st black pixel
			And $pixelColors[$rowIndex][$colIndex + 1] == 0xFFFFFFFF _ ; 2nd white pixel
			And $pixelColors[$rowIndex][$colIndex + 2] == 0xFFFFFFFF _ ; 3rd white pixel
			And $pixelColors[$rowIndex][$colIndex + 3] == 0xFFFFFFFF _ ; 4rd white pixel
			And $pixelColors[$rowIndex + 2][$colIndex] == 0xFF000000 _ ; check pixel in left column to eliminate number 6,8,9,0
			And $pixelColors[$iHeight - 2][$colIndex] == 0xFF000000 _ ; check pixel to eliminate number 2
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 3
		EndIf

		; find 4
		If ($currentPixelOfDigit == 4 And Not $isBlack _ ; 4th white pixel
			And $pixelColors[$rowIndex][$colIndex - 1] == 0xFF000000 _ ; black on left side
			And $pixelColors[$rowIndex][$colIndex + 1] == 0xFF000000 _ ; black on right side
			And $rowIndex == 1 _; this check is only for first row
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 4
		EndIf

		; find 5
		If ($rowIndex == 1 _; this check is only for first row
			And $currentPixelOfDigit == 1 And $isBlack _ ; 1st black pixel
			And $pixelColors[$rowIndex][$colIndex + 1] == 0xFFFFFFFF _ ; 2nd white pixel
			And $pixelColors[$rowIndex][$colIndex + 4] == 0xFFFFFFFF _ ; 5th white pixel
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 5
		EndIf

		; find 6
		If ($rowIndex == 1 _; this check is only for first row
			And $currentPixelOfDigit == 1 And $isBlack _ ; 1st black pixel
			And $pixelColors[$rowIndex][$colIndex + 1] == 0xFFFFFFFF _ ; 2nd white pixel
			And $pixelColors[$rowIndex][$colIndex + 2] == 0xFFFFFFFF _ ; 3rd white pixel
			And $pixelColors[$rowIndex][$colIndex + 3] == 0xFFFFFFFF _ ; 4rd white pixel
			And $pixelColors[$rowIndex][$colIndex + 4] == 0xFF000000 _ ; 5th black pixel
			And $pixelColors[$rowIndex + 3][$colIndex + 2] == 0xFFFFFFFF _ ; check unique 6 number white pixel
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 6
		EndIf

		; find 7
		If ($currentPixelOfDigit == 1 And Not $isBlack _ ; 1st white pixel
			And $rowIndex == 1 _; this check is only for first row
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 7
		EndIf

		; find 8
		If ($rowIndex == 1 _; this check is only for first row
			And $currentPixelOfDigit == 1 And $isBlack _ ; 1st black pixel
			And $pixelColors[$rowIndex][$colIndex + 1] == 0xFFFFFFFF _ ; 2nd white pixel
			And $pixelColors[$rowIndex][$colIndex + 2] == 0xFFFFFFFF _ ; 3rd white pixel
			And $pixelColors[$rowIndex][$colIndex + 3] == 0xFFFFFFFF _ ; 4rd white pixel
			And $pixelColors[$rowIndex][$colIndex + 4] == 0xFF000000 _ ; 5th black pixel
			And $pixelColors[$rowIndex + 4][$colIndex + 1] == 0xFFFFFFFF _ ; find white bar in 8 digit
			And $pixelColors[$rowIndex + 4][$colIndex + 2] == 0xFFFFFFFF _ ; find white bar in 8 digit
			And $pixelColors[$rowIndex + 4][$colIndex + 3] == 0xFFFFFFFF _ ; find white bar in 8 digit
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 8
		EndIf

		; find 9
		If ($rowIndex == 1 _; this check is only for first row
			And $currentPixelOfDigit == 1 And $isBlack _ ; 1st black pixel
			And $pixelColors[$rowIndex][$colIndex + 1] == 0xFFFFFFFF _ ; 2nd white pixel
			And $pixelColors[$rowIndex][$colIndex + 2] == 0xFFFFFFFF _ ; 3rd white pixel
			And $pixelColors[$rowIndex][$colIndex + 3] == 0xFFFFFFFF _ ; 4rd white pixel
			And $pixelColors[$rowIndex + 5][$colIndex + 1] == 0xFFFFFFFF _ ; check unique 9 number white pixel
			) Then
			Redim $result[UBound($result) + 1]
			$result[$currentIndexOfDigit] = 9
		EndIf
	Next

	Return _ArrayToString($result, "")
EndFunc