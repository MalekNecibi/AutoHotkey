; Created - 04/09/2020 04:28 PM
; Malek Necibi
; Zoom Recording Remap

#include %A_ScriptDir%\Files\lib\DefaultHeader-v3.ahk
Header:
Menu, tray, icon, .\Files\Images\Zoom.ico
FinishHeader(0)
FinishHeader(1)

SetTitleMatchMode, 2
SetKeyDelay, 20

#If WinActive("- Zoom - Google Chrome")

Space::ZoomClick("left")
k::SendInput {Media_Play_Pause}
f::
	ZoomClick()
	Send {Tab 7}{Space}
	ZoomClick()
	return

<::
	ZoomClick()
	SendInput {Tab 5}{Space}{Down}{Enter}
	ZoomClick()
	return

>::
	ZoomClick()
	SendInput {Tab 5}{Space}{Down 2}{Enter}
	ZoomClick()
	return

?::
	ZoomClick()
	SendInput {Tab 5}{Space}{Down 3}{Enter}
	ZoomClick()
	return

c::
	ZoomClick()
	SendInput {Tab 6}{Space}
	ZoomClick()
	return


ZoomClick(side = "right", n = 1)
{
	MouseClick, %side%, A_ScreenWidth/2, A_ScreenHeight/2, n, 0
}