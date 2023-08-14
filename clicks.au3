#cs
Currently monitors Left Clicks
Press ALT+a to generate a fake Left Mouse Click
#ce

#include <WinAPI.au3>
#include <WindowsConstants.au3>
#include <StructureConstants.au3>

HotKeySet("{ESC}", "Terminate")
HotKeySet("!a", "SendInput")
OnAutoItExitRegister("Cleanup")

Global Const $tagMSLLHOOKSTRUCT = 'int x;int y;DWORD mouseData;DWORD flags;DWORD time;ULONG_PTR dwExtraInfo'

Global $hModule = _WinAPI_GetModuleHandle(0)

Global $hMouseProc = DllCallbackRegister("LowLevelMouseProc", "long", "int;wparam;lparam")
Global $pMouseProc = DllCallbackGetPtr($hMouseProc)
Global $hMouseHook = _WinAPI_SetWindowsHookEx($WH_MOUSE_LL, $pMouseProc, $hModule)

Global $iCheck = $WM_LBUTTONUP

While 1
Sleep(10)
WEnd

; http://msdn.microsoft.com/en-us/library/ms644986(v=vs.85).aspx
Func LowLevelMouseProc($nCode, $wParam, $lParam)

    If $nCode >= 0 And ($wParam = $iCheck ) Then

            ; http://msdn.microsoft.com/en-us/library/ms644970(v=vs.85).aspx
            Local $MSLLHOOKSTRUCT = DllStructCreate($tagMSLLHOOKSTRUCT, $lParam)
            Local $x = DllStructGetData($MSLLHOOKSTRUCT, 1)
            Local $y = DllStructGetData($MSLLHOOKSTRUCT, 2)
            ConsoleWrite('Click at (' & $x & ', ' & $y & ')  ' & "Real? " & (DllStructGetData($MSLLHOOKSTRUCT, 'flags' ) = 0) & @CRLF)

    EndIf

    Return _WinAPI_CallNextHookEx($hMouseHook, $nCode, $wParam, $lParam)

EndFunc

Func SendInput()
MouseClick('left')
EndFunc

Func Cleanup()
    _WinAPI_UnhookWindowsHookEx($hMouseHook)
    DllCallbackFree($hMouseProc)
EndFunc

Func Terminate()
    Exit
EndFunc