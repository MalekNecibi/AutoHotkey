#include %A_ScriptDir%\Files\lib\DefaultHeader-v3.ahk
Header:
FinishHeader("FHRE")
FinishHeader("SX")

#InputLevel 1 ; Allow access to keys in other scripts
return

; Key Remaps
F1::
	SoundSet, 0
	SendInput {Volume_Down}
	return

F3::
	SoundSet, 100
	SendInput {Volume_Up}
	return

^+#Up::Volume_Up
^+#Down::Volume_Down
^+#Space::Media_Play_Pause
^+#Right::Media_Next
^+#Left::Media_Prev