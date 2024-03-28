; Created - 11/16/2023 09:17 AM
#include C:\Users\Malek\Desktop\AutoHotkey\XPS Programs\Files\lib\DefaultHeader-v3.1.ahk
Header:
FinishHeader(0)
FinishHeader(1)
#Persistent
#If

SetTimer, NeverSleep, 5000 ; Prevent going to sleep when locked

return



NeverSleep:
Send {LShift}
if (A_TimeIdle > 1000) { ; Just in case, every 30 seconds
    Tooltip LShift failed to prevent idle
    MouseGetPos, mouseX, mouseY
    MouseMove, mouseX, mouseY, 0
    if (A_TimeIdle > 1000) {
        Tooltip Both LShift and MouseMove failed to prevent idle
    }
}
return


#If
Tooltip(time:=1500, message:="", X:="", Y:="", WhichToolTip:="")
{
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

RemoveToolTip():
ToolTip
return

; `::ExitApp

RemoveToolTip:
Tooltip
return