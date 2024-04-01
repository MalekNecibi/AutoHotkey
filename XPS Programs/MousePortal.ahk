; Created - 03/28/2024 11:40 AM
#include C:\Users\Malek\Desktop\AutoHotkey\XPS Programs\Files\lib\DefaultHeader-v3.1.ahk
Header:
FinishHeader(0)
FinishHeader(1)

; Optional:
; Edit DPI Configuration at AutoHotkey.exe executable level
; Under Properties, Compatability, Settings, click "Change high DPI Settings"
; Enable the bottom checkbox under "High DPI scaling override"
; Leave the default Dropdown option of "Application"
; Click OK, then Apply, then OK
; Comment out the instamces below of DllCall(SetThreadDpiAwarenessContext, -4)

SetTitleMatchMode, 2
#Persistent
; Ignore DPI scaling (prevents inconsistent pixel rounding)

MousePortal_Configure(,,wrap=true)

return

!`::MsgBox % CursorCoords


; When mouse pointer is in top-left or bottom-right corner of any display,
; teleport mouse to next or previous display respectively (wraparound optional)
MousePortal_Configure(wParam=0, lParam=0, wrap=false) {
    ; width := lParam & 0xffff  
    ; height := (lParam >> 16) & 0xffff
    
    global displays, _MousePortal_WRAP, CursorCoords
    ; Static (only executes first time function called)
    if ("" == _MousePortal_WRAP) {
        _MousePortal_WRAP := wrap
        OnMessage(0x7E, "MousePortal_Configure")   ; WM_DISPLAYCHANGE ; Notify when display state changes
        VarSetCapacity(CursorCoords, 4+4, 0)
    }
    
    SetTimer, MousePortal, Off
    DllCall("SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")
    if (0 != wParam and 0 != lParam) {
        ; Automatically called by OS message
        Sleep 2500  ; Wait for updated display settings to finalize
        SplashTextOn, 400, 60, Splash, Configuring MousePortal...
    } else {
        ; Manually Called
    }
    
    
    displays := []  ; fresh Array of Dicts[Direction:Pixel]
    SysGet, numDisplays, 80 ; SM_CMONITORS ; Get number of displays
    Loop, % numDisplays {   ; Get pixel boundaries for each display
        SysGet, _display, Monitor, %A_Index%
        ; Mouse can't actually reach display limit
        display := { Top:_displayTop, Right:_displayRight-1, Bottom:_displayBottom-1, Left:_displayLeft}
        displays[A_Index] := display
    }
    
    ; Only enable portal with minimum 2 displays
    if (numDisplays > 1) {
        SetTimer, MousePortal, 50
    }
    
    SetTimer, SplashText_Hide, -500 ; notify that new DPI being configured
}


MousePortal:
; ToolTip % "DPI type: " DllCall("GetThreadDpiAwarenessContext", "Ptr", "Int")

; If a new "thread" created elsewhere (e.g. MsgBox) DPI awareness resets
DllCall("SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")
DllCall("user32.dll\GetCursorPos", Int, &CursorCoords)
x := NumGet(CursorCoords, 0, "Int")
y := NumGet(CursorCoords, 4, "Int")

; TODO : only precise check if x,y on permiters
Loop, % displays.Length()  {
    ; Compute indexes of the next and previous display
    ; -1 then +1 compensate for 1-indexing
    ; +numDisplays to force positive mod result
    numDisplays := displays.Length()
    _prev := 1 + mod(A_Index-1+numDisplays - 1, numDisplays)
    _now  := 1 + mod(A_Index-1+numDisplays + 0, numDisplays)
    _next := 1 + mod(A_Index-1+numDisplays + 1, numDisplays)
    
    ; from Top Right corner
    if (x == displays[_now].Right) and (y == displays[_now].Top) {
        if  (_next >= _now) or _MousePortal_WRAP {
            newX := displays[_next].Left
            newY := displays[_next].Bottom
        }
    
    } else if (x == displays[_now].Left) and (y == displays[_now].Bottom) {
        ; from Bottom Left corner
        if (_prev <= _now) or _MousePortal_WRAP {
            newX := displays[_prev].Right
            newY := displays[_prev].Top
        }
    
    } else {
        continue
    }

    DllCall("SetCursorPos", "Int", newX, "Int", newY) ; Teleport
    break
}
return





#If
Tooltip(time:=1500, message:="", X:="", Y:="", WhichToolTip:="") {
    if time is not number   ; If Var is Type doesn't allow inline bracing
    {
        ; Throw error, but still show Tooltip message (Recursive Call)
        Tooltip(,"Tooltip() WARNING: Invalid Time Provided (" time ")`r`n" . message, X, Y, WhichToolTip)
    
    } else {
        Tooltip, %message%, %X%, %Y%, %WhichToolTip%
        if (time >= 0) {    ; Persist if time is negative
            SetTimer, RemoveToolTip(), % -1 * time
        }
    }
}

SplashText_Hide:
SplashTextOff
return


RemoveToolTip():
ToolTip
return

; `::ExitApp

RemoveToolTip:
Tooltip
return