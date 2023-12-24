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
	switch (exclusions) {
		case 2:
			exclusions := "00110100"	; Exclude "Reload Script"
		case 3:
			exclusions := "00001000"	; Exclude "Edit with N++"
		case 4:
			exclusions := "11000000"	; Add additional Items to Top Menu (1/2)
		case 5:
			exclusions := "00111111"	; Add additional Items to Top Menu (2/2)
		case 6:
			exclusions := "00100000"	; Exclude Single Click for Default
	}
	; MsgBox 
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
	
	; MsgBox 1
	Loop, %MAX% {
		current := MAX - count + 1
		; MsgBox % exclusions
		CurrentValue := SubStr(exclusions, current, 1)
		Mb := CurrentValue*count
		; MsgBox CurrentValue = %CurrentValue%, %count%
		if (CurrentValue == 0) {
			switch (count)
			{
				Case 1:
					#SingleInstance Force
					MsgBox Case 1
					return
				Case 2:
					Menu, Tray, NoStandard
					MsgBox Case 2
					return
				Case 3:
					Menu, Tray, Add, Reload Script, Reloader
					MsgBox Case 3
					return
				Case 4:
					if (A_IsCompiled != 1) {
						Menu, Tray, Add, Edit with N++, Editor
					}
					MsgBox Case 4
					return
				Case 5:
					Menu, Tray, Default, Reload Script
					MsgBox Case 5
					return
				Case 6:
					Menu, Tray, Click, 1
					MsgBox Case 6
					return
				Case 7:
					Menu, Tray, Add
					MsgBox Case 7
					return
				Case 8:
					Menu, Tray, Standard
					MsgBox Case 8
					return
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