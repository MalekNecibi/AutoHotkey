#SingleInstance Force
Menu, tray, NoStandard
Menu, tray, Add, Reload Script, Reloader
Menu, tray, Default, Reload Script
Menu, tray, add
Menu, tray, Standard
SetTitleMatchMode, 1

; Startup Mute
SoundSet, 0
Send {Volume_Down}
OrigVol := 50
Return
;---------------------------------------
F1::
{
SoundGet, IfVol
IfGreaterOrEqual, IfVol, 0.1
	{
	IfLessOrEqual, IfVol, 99.9
		{
		SoundGet, OrigVol
		}
	}
SoundSet, 0
Send, {Volume_Down}
}
Return
;---------------------------------------
F2::
{
SoundGet, IfVol
IfGreaterOrEqual, IfVol, 0.1
	{
	IfLessOrEqual, IfVol, 99.9
		{
		SoundGet, OrigVol
		}
	}
OrigVol := Round(OrigVol)
Send {Volume_Up}
SoundSet, %OrigVol%
}
Return
;---------------------------------------
F3::
{
SoundGet, IfVol
IfGreaterOrEqual, IfVol, 0.1
	{
	IfLessOrEqual, IfVol, 99.9
		{
		SoundGet, OrigVol
		}
	}
SoundSet, 100
Send, {Volume_Up}
}
Return
;---------------------------------------
^+#Up::Volume_Up
;---------------------------------------
^+#Down::Volume_Down
;---------------------------------------

^+#Space::Media_Play_Pause

^+#Right::Media_Next

^+#Left::Media_Prev

^+#s::
	{
	IfWinExist, Spotify Lyrics
		WinActivate
	IfWinNotExist, Spotify Lyrics
		{
		Run %Malek%\SpotifyLyrics.exe
		WinWait, Spotify Lyrics
			Sleep 100
			WinActivate
		}
	Return
	}	

Return
Reloader:
Reload