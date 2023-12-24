LabelName := "Header"
if isLabel(LabelName) {
	Gosub %LabelName%
	return
} else {
	FinishHeader()
	MsgBox Don't Forget to make a "Header:" Label!
}
return


FinishHeader(exclusions := "00000000") { ; Header Lines to exclude
	; MsgBox exclusions = %exclusions%
	; Basic Presets
	if (exclusions == 2) {
		exclusions := "00110100"	; Exclude "Reload Script"
	} else if (exclusions == 3) {
		exclusions := "00001000"	; Exclude "Edit with N++"
	} else if (exclusions == 4) {
		exclusions := "11000000"	; Add additional Items to Top Menu (1/2)
	} else if (exclusions == 5) {
		exclusions := "00111111"	; Add additional Items to Top Menu (2/2)
	} else if (exclusions == 6) {	
		exclusions := "00100000"	; Exclude Single Click for Default
	}
	/*
	else if (exclusions == 7) {
		exclusions := ""	; Exclude 
	} else if (exclusions == 8) {
		exclusions := ""	; Exclude 
	} else if (exclusions == 9) {
		
	}
	*/
	
	
	MAX := 8
	count := 1
	if (StrLen(exclusions) < MAX) {
		LoopCount := MAX - StrLen(exclusions)
		Loop, %LoopCount% {
			exclusions = 0%exclusions%
		}
	} else if (StrLen(exclusions) > MAX) {
		MsgBox Default Header Error: Exclusions Parameter Must NOT have more than %MAX% characters`n`nHeader Value set to default (00000000)
		exclusions := "00000000"
	} else if (StrLen(exclusions) != MAX) {
		MsgBox Default Header Error: Exclusions Parameter is of an incorrect type/size.`n`nexclusion = %exclusion%
	}
	
	
	Loop, %MAX% {
		current := MAX - count + 1
		CurrentValue := SubStr(exclusions, current, 1)
		if (CurrentValue == 0) {
			switch count
			{
				Case 1:
					#SingleInstance Force
				Case 2:
					Menu, Tray, NoStandard
				Case 3:
					Menu, Tray, Add, Reload Script, Reloader
				Case 4:
					if (A_IsCompiled != 1) {
						Menu, Tray, Add, Edit with N++, Editor
					}
				Case 5:
					Menu, Tray, Default, Reload Script
				Case 6:
					Menu, Tray, Click, 1
				Case 7:
					Menu, Tray, Add
				Case 8:
					Menu, Tray, Standard
				Default:
					MsgBox Default Header Error: Default Case Selected?\n\ncase = %case%
			}
		}
		count++
	}
}

MsgBox Default Header Error:`n`nThis MsgBox is to Prevent a Reload Loop

Reloader:
Run "%A_ScriptFullPath%" ; Reload
return


Editor:
Run notepad++.exe "%A_ScriptFullPath%"
return