# bot
Info:
- Max values for jump at 1080p:
```
	jump(960+720, 540) ;left/right jump close to max range
	jump(960, 540-370) ;up/down jump close to max range
	jump(960+562, 540-260) ;diagonal jump ABSOLUTE max
```

- jumping fast = disconnect
- jumping to exactly the same spots = ban in jail

- This random jump put acc into bot jail: @Edit - spamming any action in short period of time put character to jail

```
Func random_jump()
	While 1
		Sleep(650 + Random(0, 50, 1))
		Local $begin = TimerInit()
		jump(960 + Random(-562, 562, 1), 540 + Random(-260, 260, 1))
		update_cords()
		;random scatter
		scatter(960 + Random(-562, 562, 1), 540 + Random(-260, 260, 1))
		ConsoleWrite("One random jump execution time: " & TimerDiff($begin) & @CRLF);
		;ConsoleWrite("Random jump executed!" & @CRLF)
	WEnd
EndFunc
```


- TODO difference beetwen mode 0 and 2 in this mode:
```
MouseCoordMode 	Sets the way coords are used in the mouse functions, either absolute coords or coords relative to the current active window:
0 = relative coords to the active window
1 = (default) absolute screen coordinates
2 = relative coords to the client area of the active window
```