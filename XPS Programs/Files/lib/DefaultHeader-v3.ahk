; DefaultHeader-v3.ahk
; Malek Necibi
; 05/01/2020

LabelName := "Header"
if isLabel(LabelName) {
	Gosub %LabelName%
	return
} else {
	FinishHeader("S")
	MsgBox Don't Forget to make a "Header:" Label!
}
return


FinishHeader(input := "") { ; Header Lines to exclude
	
	; options = ["F", "H", "R", "E", "C", "X", "S"]
	
	if (input = 0)
		input := "FHREC"
	
	if (input = 1)
		input := "SX"
	
	
	Loop, parse, input
	{
		switch A_LoopField {
			case "F":
				#SingleInstance, Force
				continue
				
			case "H":
				Menu, Tray, NoStandard
				continue
				
			case "R":
				Menu, Tray, Add, Reload Script, Reloader
				Menu, Tray, Default, Reload Script
				continue
				
			case "E":
				if !A_IsCompiled
					Menu, Tray, Add, Edit with N++, Editor
				continue
				
			case "C":
				Menu, Tray, Click, 1
				continue
			
			
			case "X":
				Menu, Tray, Add
				Menu, Tray, Add, ExitApp, Exitter
				continue
				
			case "S":
				if !A_IsCompiled {
					Menu, Tray, NoStandard
					Menu, Tray, Add
					Menu, Defaults, Standard
					Menu, Tray, Add, Standard Menu, :Defaults
				}
				continue
			
			default:
				MsgBox Default Header Error:`n`n %A_LoopField% is not valid
				continue
		}
	}
	return
}


MsgBox Default Header Error:`n`nThis MsgBox is to Prevent a Reload Loop

Reloader:
Run "%A_ScriptFullPath%" ; Reload
return


Editor:
Run notepad++.exe "%A_ScriptFullPath%"
return

Exitter:
ExitApp
return