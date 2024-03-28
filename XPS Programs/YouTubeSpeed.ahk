; Created - 11/10/2020 10:07 PM
#include %A_ScriptDir%\Files\lib\DefaultHeader-v3.ahk
Header:
FinishHeader(0)
FinishHeader(1)
Menu, Tray, Icon, %A_ScriptDir%\Files\Images\YouTube.ico
SetTitleMatchMode, 2


; Script forces 'rewind seconds' shortcuts to ignore playback speed
; Instead shortcuts (left, right, j, l) will still mean (-5, +5, -10, +10) respectively

; Script suspended when playback speed < 1, uncomment around line ~60 to enable that

; Launch This Script when a Chrome Youtube Video is open
; It will reset the playback speed to 1x
; move it back up to desired playback speed using '<' or '>'

WinYoutube := "YouTube - Google Chrome"




Speed := 0
startedActive := WinActive(WinYoutube)
WinActivate, %WinYoutube%
if (WinActive(WinYoutube)) {
	Send +{. 7}+{, 4}
	ToolTip, YouTube Playback Speed Reset : 1x`r`nUse < or > to change it
	SetTimer, RemoveToolTip, -1500
	if (!startedActive) {
		Send !{Esc}	; Uncomment to keep the Youtube page in focus
	}

} else {
	MsgBox, 6, YouTubeSpeed Error: (%WinYoutube%), ERROR: Couldn't Find YouTube Window`nWould you like to try modifying the WinYoutube variable?, 15
	IfMsgBox Cancel
		ExitApp
	IfMsgBox TryAgain
		Reload
	IfMsgBox Continue
		Edit
		; Run, 
	IfMsgBox Timeout
		ExitApp
}
return

#If WinActive(WinYoutube)
j::
l::
Left::
Right::
	if (Speed > 0) {
		SendInput +{, %Speed%}{%A_ThisHotkey%}+{. %Speed%} 
	
	} else {
		Send {%A_ThisHotkey%}
	
	; This works, but disabled out of personal preference
;	} else {
;		tempSpeed := -Speed
;		Send +{. %tempSpeed%}{%A_ThisHotkey%}+{, %tempSpeed%}
	}
return

<::
	Send <
	(Speed != -3) ? Speed -= 1 : 
	return

>::
	Send >
	(Speed != 4) ? Speed += 1 : 
	return

RemoveToolTip:
ToolTip
return