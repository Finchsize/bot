# bot
Info:
- Max values for jump at 1080p:
```
	jump(960+720, 540) ;left/right jump close to max range
	jump(960, 540-370) ;up/down jump close to max range
	jump(960+562, 540-260) ;diagonal jump ABSOLUTE max
```

- jumping fast = disconnect
- This is sending to jail:
```
	Local $wParam = 0x0008
	_SendMessage($hWndControl, $WM_LBUTTONDOWN, $wParam, $lParam)
	_SendMessage($hWndControl, $WM_LBUTTONUP, $wParam, $lParam)
```
And this:
```
	Local $MK_LBUTTON = 0x0001
	Local $lParam = _WinAPI_MakeLong($xCordClick, $yCordClick)
	_WinAPI_PostMessage($hWndControl, $WM_LBUTTONDOWN, $MK_LBUTTON, $lParam)
	Sleep($currentSleep)
	_WinAPI_PostMessage($hWndControl, $WM_LBUTTONUP, 0, $lParam)
```
And this:
```
	ControlClick($hWnd, "", $hWndControl, "left", 1, $xCordClick, $yCordClick)
```


- TODO difference beetwen mode 0 and 2 in this mode:
```
MouseCoordMode 	Sets the way coords are used in the mouse functions, either absolute coords or coords relative to the current active window:
0 = relative coords to the active window
1 = (default) absolute screen coordinates
2 = relative coords to the client area of the active window
```