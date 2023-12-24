#SingleInstance Ignore
#include %A_ScriptDir%\Files\lib\DefaultHeader-v3.ahk
Header:
Menu, Tray, Add, Exit NoInput, ExitNI
Menu, Tray, Default, Exit NoInput
FinishHeader("FRX")

#If
TOGGLE_HOTKEY=>^Esc
; ______________________________________________________________________________
;
#MaxHotkeysPerInterval 100
#HotkeyInterval 1
#Persistent
#NoEnv ; Avoids checking empty variables to see if they are environment variables
; install the toggle hotkey
Hotkey,%TOGGLE_HOTKEY%,ToggleLockState
SetTimer, DontSleep, 5000 ; Prevent going to sleep when locked
SetTimer, ExitNI, 600000 ; After 10 minutes unlocked, quit program
EnvGet, AHK, AHK
if AHK {
	FreeIcon := AHK . "\XPS Programs\Files\Images\Input-Green.png"
	LockedIcon := AHK . "\XPS Programs\Files\Images\Input-Red.png"
}
LockState := "Off"

Gosub, ToggleLockState ; Start in locked state

SetTimer, RemoveToolTip, -10000

return
; ______________________________________________________________________________
;
ToggleLockState:
LockState := (LockState == "On" ? "Off" : "On")
BlockKeyboardInputs(LockState)
SystemCursor(LockState)
BlockMouseClicks(LockState)
if (LockState == "On") {
	MouseGetPos, mouseX, mouseY
	BlockInput MouseMove
	ToolTip, Locked (Hint: >^F0)
	Menu, Tray, Icon, %LockedIcon%
	SetTimer, ExitNI, Off
} else {
	BlockInput,MouseMoveOff
	ToolTip, Free
	Menu, Tray, Icon, %FreeIcon%
	SetTimer, ExitNI, On
}
SetTimer, RemoveToolTip, -2500
Return


; ******************************************************************************
; Function:
;    BlockKeyboardInputs(state="On") disables all keyboard key presses,
;   but Control, Shift, Alt (thus a hotkey based on these keys can be used to unblock the keyboard)
;
; Param
;   state [in]: On or Off
;
BlockKeyboardInputs(state = "On")
{
   static keys
   keys=Space,Enter,Tab,Esc,BackSpace,Del,Ins,Home,End,PgDn,PgUp,Up,Down,Left,Right,CtrlBreak,ScrollLock,PrintScreen,CapsLock
,Pause,AppsKey,LWin,LWin,NumLock,Numpad0,Numpad1,Numpad2,Numpad3,Numpad4,Numpad5,Numpad6,Numpad7,Numpad8,Numpad9,NumpadDot
,NumpadDiv,NumpadMult,NumpadAdd,NumpadSub,NumpadEnter,NumpadIns,NumpadEnd,NumpadDown,NumpadPgDn,NumpadLeft,NumpadClear
,NumpadRight,NumpadHome,NumpadUp,NumpadPgUp,NumpadDel,Media_Next,Media_Play_Pause,Media_Prev,Media_Stop,Volume_Down,Volume_Up
,Volume_Mute,Browser_Back,Browser_Favorites,Browser_Home,Browser_Refresh,Browser_Search,Browser_Stop,Launch_App1,Launch_App2
,Launch_Mail,Launch_Media,F1,F2,F3,F4,F5,F6,F7,F8,F9,F10,F11,F12,F13,F14,F15,F16,F17,F18,F19,F20,F21,F22,LAlt,RAlt,LShift,RShift,LCtrl,RCtrl,LWin,RWin
,1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z
,²,&,é,',(,-,è,_,ç,à,),=,$,£,ù,*,~,#,{,[,|,``,\,^,@,],},;,:,!,?,.,/,§,<,>,vkBC
   Loop,Parse,keys, `,
      Hotkey, *%A_LoopField%, KeyboardDummyLabel, %state% UseErrorLevel
   Return
; hotkeys need a label, so give them one that do nothing
KeyboardDummyLabel:
Return
}

; ******************************************************************************
; Function:
;    BlockMouseClicks(state="On") disables all mouse clicks
;
; Param
;   state [in]: On or Off
;
BlockMouseClicks(state = "On")
{
   static keys="RButton,LButton,MButton,WheelUp,WheelDown"
   SystemCursor(-1)
   Loop,Parse,keys, `,
      Hotkey, *%A_LoopField%, MouseDummyLabel, %state% UseErrorLevel
   Return

; hotkeys need a label, so give them one that do nothing
MouseDummyLabel:
Return

}
SystemCursor(OnOff=1)   ; INIT = "I","Init"; OFF = 0,"Off"; TOGGLE = -1,"T","Toggle"; ON = others
{
   static AndMask, XorMask, $, h_cursor
      ,c0,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13  ; system cursors
        , b1,b2,b3,b4,b5,b6,b7,b8,b9,b10,b11,b12,b13  ; blank cursors
        , h1,h2,h3,h4,h5,h6,h7,h8,h9,h10,h11,h12,h13  ; handles of default cursors
   if (OnOff = "Init" or OnOff = "I" or $ = "")       ; init when requested or at first call
   {
      $ = h                                           ; active default cursors
      VarSetCapacity( h_cursor,4444, 1 )
      VarSetCapacity( AndMask, 32*4, 0xFF )
      VarSetCapacity( XorMask, 32*4, 0 )
      system_cursors = 32512,32513,32514,32515,32516,32642,32643,32644,32645,32646,32648,32649,32650
      StringSplit c, system_cursors, `,
      Loop %c0%
      {
         h_cursor   := DllCall( "LoadCursor", "uint",0, "uint",c%A_Index% )
         h%A_Index% := DllCall( "CopyImage",  "uint",h_cursor, "uint",2, "int",0, "int",0, "uint",0 )
         b%A_Index% := DllCall("CreateCursor","uint",0, "int",0, "int",0
                             , "int",32, "int",32, "uint",&AndMask, "uint",&XorMask )
      }
   }
   if (OnOff = 0 or OnOff = "Off" or $ = "h" and (OnOff < 0 or OnOff = "Toggle" or OnOff = "T"))
      $ = b       ; use blank cursors
   else
      $ = h       ; use the saved cursors

   Loop %c0%
   {
      h_cursor := DllCall( "CopyImage", "uint",%$%%A_Index%, "uint",2, "int",0, "int",0, "uint",0 )
      DllCall( "SetSystemCursor", "uint",h_cursor, "uint",c%A_Index% )
   }
}

RemoveToolTip:
SetTimer, RemoveToolTip, Off
ToolTip
Return

#If
; SendLevel 2
>!Esc::
	if (LockState == "Off") {
		ExitApp
	}
	return

DontSleep:
if (LockState == "On") {
	Send {LShift}
	if (A_TimeIdle > 1000) { ; Just in case, every 30 seconds
		Tooltip LShift failed to prevent idle
		MouseMove, mouseX, mouseY, 0
		if (A_TimeIdle > 1000) {
			Tooltip Both LShift and MouseMove failed to prevent idle
		}
	}
}
return

ExitNI:
LockState := "On"
Gosub, ToggleLockState
ExitApp